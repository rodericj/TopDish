package com.topdish.jdo;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.LocationCapable;
import com.beoui.geocell.model.Point;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.google.appengine.api.datastore.PostalAddress;
import com.topdish.util.BatchDishUpdate;
import com.topdish.util.SearchUtils;
import com.topdish.util.TDQueryUtils;

/**
 * Class representing a restaurant object.
 * 
 * @author ralmand (Randy Almand)
 */
@PersistenceCapable
public class Restaurant implements TDPersistable, LocationCapable, Serializable, TDSourceable {
	/**
	 * Serial
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * The datastore key of this object
	 */
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	/**
	 * The name of this restaurant
	 */
	@Persistent
	private String name;

	@Persistent
	private PostalAddress address;

	@Persistent
	private String addressLine1;

	@Persistent
	private String addressLine2;

	@Persistent
	private String city;

	@Persistent
	private String state;

	@Persistent
	private String neighborhood;

	@Persistent
	private Key cuisine;

	/**
	 * The latitude of this restaurant
	 */
	@Persistent
	private double latitude;

	/**
	 * The longitude of this restaurant
	 */
	@Persistent
	private double longitude;

	/**
	 * The phone number of this restaurant
	 */
	@Persistent
	private PhoneNumber phone;

	/**
	 * The Google Maps ID of this restaurant
	 */
	@Persistent
	private String gid;

	/**
	 * The date this restaurant was created
	 */
	@Persistent
	private Date dateCreated;

	/**
	 * The date this restaurant was last modified
	 */
	@Persistent
	private Date dateModified;

	/**
	 * The key of the creator of this object
	 */
	@Persistent
	private Key creator;

	/**
	 * The key of the last editor of this object
	 */
	@Persistent
	private Key lastEditor;

	/**
	 * The url of this restaurant
	 */
	@Persistent
	private Link url;

	/**
	 * A set of search term strings
	 */
	@Persistent
	private Set<String> searchTerms;

	/**
	 * A list of geocell search terms
	 */
	@Persistent
	private List<String> geoCells;

	/**
	 * A set of address search term strings
	 */
	@Persistent
	private Set<String> addressTerms;

	@Persistent
	private List<Key> photos;

	@Persistent
	private Integer numDishes;

	@Persistent
	private Integer numFlagsIncorrectCuisineType = 0;

	@Persistent
	private Integer numFlagsIncorrectAddress = 0;

	@Persistent
	private Integer numFlagsIncorrectContactDetail = 0;

	@Persistent
	private Integer numFlagsRestaurantClosed = 0;

	@Persistent
	private Integer numFlagsCopyrightedPicture = 0;

	@Persistent
	private Integer numFlagsOther = 0;

	@Persistent
	private Integer numFlagsTotal = 0;

	@Persistent
	private List<Key> flags;

	/**
	 * Source of the data
	 */
	@Persistent(serialized = "true")
	private Map<Key, String> sources;

	/**
	 * Class constructor mainly used when populating from the Google Local API.
	 * 
	 * @param name
	 *            - the restaurant name
	 * @param addressLine1
	 *            - first address line
	 * @param addressLine2
	 *            - second address line
	 * @param city
	 *            - city the restaurant is located in
	 * @param state
	 *            - state the restaurant is loceted in
	 * @param neighborhood
	 *            - neighborhood the restaurant is located in
	 * @param latitude
	 *            - geo lcatitude of the restaurant
	 * @param longitude
	 *            - geo longitude of the restaurant
	 * @param phone
	 *            - phone number of the restaurant
	 * @param gid
	 *            - Google Map ID (not required)
	 * @param url
	 *            - website of the restaurant
	 * @param dateCreated
	 *            - date this object was created
	 * @param creator
	 *            - who created it
	 */
	public Restaurant(String name, String addressLine1, String addressLine2, String city,
			String state, String neighborhood, double latitude, double longitude,
			PhoneNumber phone, String gid, Link url, Date dateCreated, Key creator) {
		this.name = name;
		this.addressLine1 = addressLine1;
		this.addressLine2 = addressLine2;
		this.city = city;
		this.state = state;
		this.neighborhood = neighborhood;
		this.latitude = latitude;
		this.longitude = longitude;
		this.phone = phone;
		this.gid = gid;
		this.url = url;
		this.dateCreated = dateCreated;
		this.creator = creator;
		this.searchTerms = SearchUtils.getSearchTerms(this.name);
		this.addressTerms = new HashSet<String>();
		this.addressTerms.add(city);
		this.addressTerms.add(state);
		this.addressTerms.add(neighborhood);
		this.geoCells = GeocellManager.generateGeoCell(new Point(this.latitude, this.longitude));
		this.numDishes = 0;
		this.sources = new HashMap<Key, String>();
	}

	/**
	 * Default constructor <br />
	 * 
	 * Note: do not use for creating a Restaurant object. Specifically created
	 * for generic operations.
	 */
	public Restaurant() {
	}

	/**
	 * Fetches this object's key from the datastore
	 * 
	 * @return this object's key from the datastore
	 */
	public Key getKey() {
		return this.key;
	}

	/**
	 * Fetches the restaurant name
	 * 
	 * @return the restaurant name
	 */
	public String getName() {
		return this.name;
	}

	/**
	 * Gets the number of dishes at this restaurant.
	 * 
	 * @return number of dishes
	 */
	public Integer getNumDishes() {
		if (this.numDishes == null) {
			this.numDishes = 0;
			return 0;
		} else {
			return this.numDishes;
		}
	}

	/**
	 * Sets the restaurant name
	 * 
	 * @param name
	 *            the name to set
	 */
	public void setName(String name) {
		this.name = name;
		this.searchTerms = SearchUtils.getSearchTerms(this.name);
		BatchDishUpdate.setRestaurantName(name, this.key);
	}

	/**
	 * Fetches the restaurant address
	 * 
	 * @return the restaurant's address
	 */
	public PostalAddress getAddress() {
		return address;
	}

	public String getAddressLine1() {
		return this.addressLine1;
	}

	public void setAddressLine1(String addressLine1) {
		this.addressLine1 = addressLine1;
	}

	public String getAddressLine2() {
		return this.addressLine2;
	}

	public void setAddressLine2(String addressLine2) {
		this.addressLine2 = addressLine2;
	}

	public String getCity() {
		return this.city;
	}

	public void setCity(String city) {
		if (this.city == null || this.city.equals("")) {
			// city not set therefore not yet in search terms
			this.addressTerms.add(city);
		} else {
			// city previously set and added to search terms
			this.addressTerms.remove(this.city);
			this.addressTerms.add(city);
		}

		this.city = city;

		BatchDishUpdate.setCity(city, this.key);
	}

	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		if (this.state == null || this.state.equals("")) {
			// state not set therefore not yet in search terms
			this.addressTerms.add(state);
		} else {
			// state previously set and added to search terms
			this.addressTerms.remove(this.state);
			this.addressTerms.add(state);
		}

		this.state = state;
		BatchDishUpdate.setState(state, this.key);
	}

	public String getNeighborhood() {
		return this.neighborhood;
	}

	public void setNeighborhood(String neighborhood) {
		if (this.neighborhood == null || this.neighborhood.equals("")) {
			// neighborhood not set therefore not yet in search terms
			this.addressTerms.add(neighborhood);
		} else {
			// neighborhood previously set and added to search terms
			this.addressTerms.remove(this.neighborhood);
			this.addressTerms.add(neighborhood);
		}

		this.neighborhood = neighborhood;
		BatchDishUpdate.setNeighborhood(neighborhood, this.key);
	}

	/**
	 * Fetches the restaurant location
	 * 
	 * @return the location {@link Point} of this restaurant
	 */
	public Point getLocation() {
		return new Point(this.latitude, this.longitude);
	}

	/**
	 * Sets the location and re-generates the geographical search terms.
	 * 
	 * @param latitude
	 *            the latitude to set
	 * @param longitude
	 *            the longitude to set
	 */
	public void setLocation(double latitude, double longitude) {
		this.latitude = latitude;
		this.longitude = longitude;
		this.geoCells = GeocellManager.generateGeoCell(new Point(this.latitude, this.longitude));
		BatchDishUpdate.setLocation(latitude, longitude, geoCells, this.key);
	}

	/**
	 * Fetches the restaurant's phone number
	 * 
	 * @return the restaurant's phone number
	 */
	public PhoneNumber getPhone() {
		return this.phone;
	}

	/**
	 * Sets the restaurant phone number
	 * 
	 * @param phone
	 *            the phone number to set
	 */
	public void setPhone(PhoneNumber phone) {
		this.phone = phone;
	}

	/**
	 * Fetches the Google Maps ID number
	 * 
	 * @return the Google Maps ID number
	 */
	public String getGid() {
		return this.gid;
	}

	/**
	 * Fetches the date this object was created
	 * 
	 * @return the date this object was created
	 */
	public Date getDateCreated() {
		return this.dateCreated;
	}

	/**
	 * Fetches the date this object was last modified
	 * 
	 * @return the date this object was last modified
	 */
	public Date getDateModified() {
		return this.dateModified;
	}

	/**
	 * Sets the date this object was modified
	 * 
	 * @param dateModified
	 *            the date this object was modified
	 */
	public void setDateModified(Date dateModified) {
		this.dateModified = dateModified;
	}

	/**
	 * Fetches the {@link Key} to the {@link TDUser} that created this object
	 * 
	 * @return the {@link Key} to the {@link TDUser} that created this object
	 */
	public Key getCreator() {
		if (null == this.creator) {
			this.creator = TDQueryUtils.getDefaultUser();
		}
		return this.creator;
	}

	/**
	 * Sets the {@link Key} of the {@link TDUser} that last edited this object
	 * 
	 * @param lastEditor
	 *            the {@link Key} to the {@link TDUser} that last edited this
	 *            object
	 */
	public void setLastEditor(Key lastEditor) {
		this.lastEditor = lastEditor;
	}

	/**
	 * Fetches the {@link Key} of the {@link TDUser} that last edited this
	 * object
	 * 
	 * @return the {@link Key} of the {@link TDUser} that last edited this
	 *         object
	 */
	public Key getLastEditor() {
		return this.lastEditor;
	}

	/**
	 * Sets the {@link Link} for this restaurant
	 * 
	 * @param url
	 *            {@link Link} to set
	 */
	public Link getUrl() {
		return this.url;
	}

	/**
	 * Sets the {@link Link} for this restaurant
	 * 
	 * @param url
	 *            {@link Link} to set
	 */
	public void setUrl(Link url) {
		this.url = url;
	}

	/**
	 * Adds a dish to this restaurant.
	 * 
	 */
	public void addDish() {
		if (this.numDishes == null) {
			this.numDishes = 0;
		} else {
			this.numDishes++;
		}
	}

	/**
	 * Fetches a {@link Set} of search term strings
	 * 
	 * @return a {@link Set} of search term strings
	 */
	public Set<String> getSearchTerms() {
		return this.searchTerms;
	}

	/**
	 * Fetches a {@link Set} of address search term strings
	 * 
	 * @return a {@link Set} of address search term strings
	 */
	public Set<String> getAddressTerms() {
		return this.addressTerms;
	}

	/**
	 * Fetches a {@link List} of geoCell search term strings
	 * 
	 * @return a {@link List} of geoCell search term strings
	 */
	public List<String> getGeocells() {
		return this.geoCells;
	}

	/**
	 * Fetches the string value of this object's key ID
	 * 
	 * @return the string value of this object's key ID
	 */
	public String getKeyString() {
		return Long.valueOf(this.key.getId()).toString();
	}

	/**
	 * Fetches the latitude of this restaurant
	 * 
	 * @return the latitude of this restaurant
	 */
	public double getLatitude() {
		return this.latitude;
	}

	/**
	 * Fetches the longitude of this restaurant
	 * 
	 * @return the longitude of this restaurant
	 */
	public double getLongitude() {
		return this.longitude;
	}

	public void addPhoto(Key k) {
		if (null == this.photos) {
			this.photos = new ArrayList<Key>();
		}
		this.photos.add(k);
	}

	public List<Key> getPhotos() {
		if (null == this.photos)
			this.photos = new ArrayList<Key>();

		return this.photos;
	}

	public void removePhoto(Key k) {
		this.photos.remove(k);
	}

	/**
	 * Decrease the dish count.
	 */
	public void removeDish() {
		if (null != this.numDishes && this.numDishes > 0) {
			this.numDishes--;
		}
	}

	public Integer getNumPosReviews() {
		// returns total number of positive reviews for all dishes
		// TODO: implement method using log sharder utility
		return 0;
	}

	public void setCuisine(Key cuisine) {
		this.cuisine = cuisine;
		BatchDishUpdate.setCuisine(cuisine, this.key);
	}

	public Key getCuisine() {
		return this.cuisine;
	}

	public void addFlag(Flag flag) {
		switch (flag.getType()) {
		case Flag.COPYRIGHTED_PICTURE:
			if (this.numFlagsCopyrightedPicture == null)
				this.numFlagsCopyrightedPicture = 0;
			this.numFlagsCopyrightedPicture++;
			break;
		case Flag.INCORRECT_ADDRESS:
			if (this.numFlagsIncorrectAddress == null)
				this.numFlagsIncorrectAddress = 0;
			this.numFlagsIncorrectAddress++;
			break;
		case Flag.INCORRECT_CONTACT_DETAIL:
			if (this.numFlagsIncorrectContactDetail == null)
				this.numFlagsIncorrectContactDetail = 0;
			this.numFlagsIncorrectContactDetail++;
			break;
		case Flag.INCORRECT_CUISINE_TYPE:
			if (this.numFlagsIncorrectCuisineType == null)
				this.numFlagsIncorrectCuisineType = 0;
			this.numFlagsIncorrectCuisineType++;
			break;
		case Flag.RESTAURANT_CLOSED:
			if (this.numFlagsRestaurantClosed == null)
				this.numFlagsRestaurantClosed = 0;
			this.numFlagsRestaurantClosed++;
			break;
		case Flag.OTHER:
			if (this.numFlagsOther == null)
				this.numFlagsOther = 0;
			this.numFlagsOther++;
			break;
		}
		if (this.numFlagsTotal == null)
			this.numFlagsTotal = 0;
		this.numFlagsTotal++;
		this.flags.add(flag.getKey());
	}

	public Integer getNumFlagsCopyrightedPicture() {
		if (this.numFlagsCopyrightedPicture == null) {
			return 0;
		} else {
			return this.numFlagsCopyrightedPicture;
		}
	}

	public Integer getNumFlagsIncorrectAddress() {
		if (this.numFlagsIncorrectAddress == null) {
			return 0;
		} else {
			return this.numFlagsIncorrectAddress;
		}
	}

	public Integer getNumFlagsIncorrectContactDetail() {
		if (this.numFlagsIncorrectContactDetail == null) {
			return 0;
		} else {
			return this.numFlagsIncorrectContactDetail;
		}
	}

	public Integer getNumFlagsIncorrectCuisineType() {
		if (this.numFlagsIncorrectCuisineType == null) {
			return 0;
		} else {
			return this.numFlagsIncorrectCuisineType;
		}
	}

	public Integer getNumFlagsRestaurantClosed() {
		if (this.numFlagsRestaurantClosed == null) {
			return 0;
		} else {
			return this.numFlagsRestaurantClosed;
		}
	}

	public Integer getNumFlagsTotal() {
		if (this.numFlagsTotal == null) {
			return 0;
		} else {
			return this.numFlagsTotal;
		}
	}

	@Override
	public Restaurant addSource(Key source, String objectId) {
		if (this.sources == null)
			this.sources = new HashMap<Key, String>();

		this.sources.put(source, objectId);

		return this;
	}

	@Override
	public String getForeignIdForSource(Key source) {
		if (this.sources == null)
			this.sources = new HashMap<Key, String>();

		return this.sources.get(source);
	}

	@Override
	public Map<Key, String> getSources() {
		return (null != this.sources ? this.sources : (this.sources = new HashMap<Key, String>()));
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("Restaurant [");
		if (address != null) {
			builder.append("address=");
			builder.append(address);
			builder.append(", ");
		}
		if (addressLine1 != null) {
			builder.append("addressLine1=");
			builder.append(addressLine1);
			builder.append(", ");
		}
		if (addressLine2 != null) {
			builder.append("addressLine2=");
			builder.append(addressLine2);
			builder.append(", ");
		}
		if (addressTerms != null) {
			builder.append("addressTerms=");
			builder.append(addressTerms);
			builder.append(", ");
		}
		if (city != null) {
			builder.append("city=");
			builder.append(city);
			builder.append(", ");
		}
		if (creator != null) {
			builder.append("creator=");
			builder.append(creator);
			builder.append(", ");
		}
		if (cuisine != null) {
			builder.append("cuisine=");
			builder.append(cuisine);
			builder.append(", ");
		}
		if (dateCreated != null) {
			builder.append("dateCreated=");
			builder.append(dateCreated);
			builder.append(", ");
		}
		if (dateModified != null) {
			builder.append("dateModified=");
			builder.append(dateModified);
			builder.append(", ");
		}
		if (flags != null) {
			builder.append("flags=");
			builder.append(flags);
			builder.append(", ");
		}
		if (geoCells != null) {
			builder.append("geoCells=");
			builder.append(geoCells);
			builder.append(", ");
		}
		if (gid != null) {
			builder.append("gid=");
			builder.append(gid);
			builder.append(", ");
		}
		if (key != null) {
			builder.append("key=");
			builder.append(key);
			builder.append(", ");
		}
		if (lastEditor != null) {
			builder.append("lastEditor=");
			builder.append(lastEditor);
			builder.append(", ");
		}
		builder.append("latitude=");
		builder.append(latitude);
		builder.append(", longitude=");
		builder.append(longitude);
		builder.append(", ");
		if (name != null) {
			builder.append("name=");
			builder.append(name);
			builder.append(", ");
		}
		if (neighborhood != null) {
			builder.append("neighborhood=");
			builder.append(neighborhood);
			builder.append(", ");
		}
		if (numDishes != null) {
			builder.append("numDishes=");
			builder.append(numDishes);
			builder.append(", ");
		}
		if (numFlagsCopyrightedPicture != null) {
			builder.append("numFlagsCopyrightedPicture=");
			builder.append(numFlagsCopyrightedPicture);
			builder.append(", ");
		}
		if (numFlagsIncorrectAddress != null) {
			builder.append("numFlagsIncorrectAddress=");
			builder.append(numFlagsIncorrectAddress);
			builder.append(", ");
		}
		if (numFlagsIncorrectContactDetail != null) {
			builder.append("numFlagsIncorrectContactDetail=");
			builder.append(numFlagsIncorrectContactDetail);
			builder.append(", ");
		}
		if (numFlagsIncorrectCuisineType != null) {
			builder.append("numFlagsIncorrectCuisineType=");
			builder.append(numFlagsIncorrectCuisineType);
			builder.append(", ");
		}
		if (numFlagsOther != null) {
			builder.append("numFlagsOther=");
			builder.append(numFlagsOther);
			builder.append(", ");
		}
		if (numFlagsRestaurantClosed != null) {
			builder.append("numFlagsRestaurantClosed=");
			builder.append(numFlagsRestaurantClosed);
			builder.append(", ");
		}
		if (numFlagsTotal != null) {
			builder.append("numFlagsTotal=");
			builder.append(numFlagsTotal);
			builder.append(", ");
		}
		if (phone != null) {
			builder.append("phone=");
			builder.append(phone);
			builder.append(", ");
		}
		if (photos != null) {
			builder.append("photos=");
			builder.append(photos);
			builder.append(", ");
		}
		if (searchTerms != null) {
			builder.append("searchTerms=");
			builder.append(searchTerms);
			builder.append(", ");
		}
		if (sources != null) {
			builder.append("sources=");
			builder.append(sources);
			builder.append(", ");
		}
		if (state != null) {
			builder.append("state=");
			builder.append(state);
			builder.append(", ");
		}
		if (url != null) {
			builder.append("url=");
			builder.append(url);
		}
		builder.append("]");
		return builder.toString();
	}

}
