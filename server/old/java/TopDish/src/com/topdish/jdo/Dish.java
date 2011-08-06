package com.topdish.jdo;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.NotPersistent;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.LocationCapable;
import com.beoui.geocell.model.Point;
import com.google.appengine.api.datastore.Key;
import com.topdish.util.Datastore;
import com.topdish.util.SearchUtils;

/**
 * {@link Dish} Object <br>
 * 
 * All Setters return the current instances of the {@link Dish} Object
 * 
 * @author Randy
 * 
 */
@PersistenceCapable
public class Dish implements TDPersistable, LocationCapable, Serializable, TDSourceable {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * JDO Key for this Object
	 */
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	/**
	 * Name of the Dish
	 */
	@Persistent
	private String name;

	/**
	 * Description of the Dish in the Menu
	 */
	@Persistent
	private String description;

	/**
	 * Restaurant this Dish is served at
	 */
	@Persistent
	private Key restaurant;

	/**
	 * Latitude of the location of the Dish
	 */
	@Persistent
	private Double latitude;

	/**
	 * Longitude of the location of the Dish
	 */
	@Persistent
	private Double longitude;

	/**
	 * Name of the restaurant
	 */
	@Persistent
	private String restaurantName;

	/**
	 * City the dish is located in
	 */
	@Persistent
	private String city;

	/**
	 * State the dish is located in
	 */
	@Persistent
	private String state;

	/**
	 * Neighborhood the dish is located in
	 */
	@Persistent
	private String neighborhood;

	/**
	 * Date the dish was created on
	 */
	@Persistent
	private Date dateCreated;

	/**
	 * Last modification of the dish
	 */
	@Persistent
	private Date dateModified;

	/**
	 * User who uploaded the dish
	 */
	@Persistent
	private Key creator;

	/**
	 * Last user to edit the dish
	 */
	@Persistent
	private Key lastEditor;

	/**
	 * Tags associated with the dish
	 */
	@Persistent
	private Set<Key> tags;

	/**
	 * Number of positive reviews
	 */
	@Persistent
	private Integer posReviews;

	/**
	 * Number of negative reviews
	 */
	@Persistent
	private Integer negReviews;

	/**
	 * Photos for this dish
	 */
	@Persistent
	private List<Key> photos;

	/**
	 * Search Terms related to this dish
	 */
	@Persistent
	private Set<String> searchTerms;

	/**
	 * String representation of map tile <br>
	 * Note: generated by {@link GeocellManager}
	 */
	@Persistent
	private List<String> geoCells;

	/**
	 * Categories for this dish
	 */
	@Persistent
	private Key category;

	/**
	 * Price range of the dish
	 */
	@Persistent
	private Key price;

	/**
	 * Cuisine of the dish
	 */
	@Persistent
	private Key cuisine;

	@Persistent
	private Integer numFlagsIncorrectLifestyle;

	@Persistent
	private Integer numFlagsIncorrectAllergy;

	@Persistent
	private Integer numFlagsIncorrectDescription;

	@Persistent
	private Integer numFlagsDishNotOnMenu;

	@Persistent
	private Integer numFlagsCopyrightedPicture;

	@Persistent
	private Integer numFlagsOther;

	@Persistent
	private Integer numFlagsTotal = 0;

	@Persistent
	private List<Key> flags;

	/**
	 * Source of the data
	 */
	@Persistent(serialized = "true")
	private Map<Key, String> sources;
	
	@NotPersistent
	private String creatorName;

	@NotPersistent
	private Integer totalReviews;

	@NotPersistent
	private String tagString;

	/**
	 * Constructor that takes every peice of Dish
	 * 
	 * @param name
	 *            - name of the dish
	 * @param description
	 *            - dish description as on menu
	 * @param restaurant
	 *            - restaurant key for the restaurant the dish is served at
	 * @param city
	 *            - city the restaurant is at
	 * @param state
	 *            - state the restaurant is in
	 * @param neighborhood
	 *            - neighborhood the restaurant is in
	 * @param latitude
	 *            - latitude of the restaurant the dish is served at
	 * @param longitude
	 *            - longitude of the restaurant the dish is served at
	 * @param restaurantName
	 *            - name of the restaurant the dish is served at
	 * @param dateCreated
	 *            - date the dish was created
	 * @param creator
	 *            - the user who uploaded the dish
	 * @param tags
	 *            - tags associated with this dish
	 */
	public Dish(String name, String description, Key restaurant, String city, String state,
			String neighborhood, double latitude, double longitude, String restaurantName,
			Date dateCreated, Key creator, Set<Key> tags) {
		this.name = name;
		this.description = description;
		this.restaurant = restaurant;
		this.city = city;
		this.state = state;
		this.neighborhood = neighborhood;
		this.restaurantName = restaurantName;
		this.latitude = latitude;
		this.longitude = longitude;
		this.dateCreated = dateCreated;
		this.creator = creator;
		this.searchTerms = SearchUtils.getSearchTerms(name);
		this.tags = new HashSet<Key>(tags);
		this.geoCells = GeocellManager.generateGeoCell(new Point(this.latitude, this.longitude));
	}

	/**
	 * Dish Constructor that takes dish data and a {@link Restaurant} and
	 * deconstructs it for City, State, Location, etc
	 * 
	 * @param name
	 *            - the name of the dish
	 * @param description
	 *            - the description of the dish on a menu
	 * @param restaurant
	 *            - the restuarant the dish is served at
	 * @param dateCreated
	 *            - date the upload occured
	 * @param creator
	 *            - the user who uploaded the dish
	 * @param tags
	 *            - tags associated with the dish
	 * @deprecated Use {@link Dish#Dish(String, String, Restaurant, Key, Set)}
	 *             instead.
	 */
	@Deprecated
	public Dish(String name, String description, Restaurant restaurant, Date dateCreated,
			Key creator, Set<Key> tags) {
		// Redirect at the main constructor and deconstruct restaurant
		this(name, description, restaurant.getKey(), restaurant.getCity(), restaurant.getState(),
				restaurant.getNeighborhood(), restaurant.getLatitude(), restaurant.getLongitude(),
				restaurant.getName(), dateCreated, creator, tags);
	}

	/**
	 * Dish Constructor that takes dish data and a {@link Restaurant} and
	 * deconstructs it for City, State, Location, etc
	 * 
	 * @param name
	 *            - the name of the dish
	 * @param description
	 *            - the description of the dish on a menu
	 * @param restaurant
	 *            - the restuarant the dish is served at
	 * @param creator
	 *            - the user who uploaded the dish
	 * @param tags
	 *            - tags associated with the dish
	 */
	public Dish(String name, String description, Restaurant restaurant, Key creator, Set<Key> tags) {
		// Redirect at the main constructor and deconstruct restaurant
		this(name, description, restaurant.getKey(), restaurant.getCity(), restaurant.getState(),
				restaurant.getNeighborhood(), restaurant.getLatitude(), restaurant.getLongitude(),
				restaurant.getName(), new Date(), creator, tags);
	}

	/**
	 * Default constructor <br />
	 * 
	 * Note: do not use for creating a Dish object. Specifically created for
	 * generic operations.
	 */
	public Dish() {
	}

	public Dish(String name, String description, Key restaurant, Key creator, Set<Key> tags) {
		// Redirect at the main constructor and deconstruct restaurant
		this(name, description, (Restaurant) Datastore.get(restaurant), new Date(), creator, tags);
	}

	/**
	 * Get the name of the dish
	 * 
	 * @return the name of the dish
	 */
	public String getName() {
		return this.name;
	}

	/**
	 * Set the dish name
	 * 
	 * @param name
	 *            - the new name
	 * @return the current dish
	 */
	public Dish setName(String name) {
		this.name = name;

		// Look up and store search terms related to new name
		this.searchTerms = SearchUtils.getSearchTerms(name);

		return this;
	}

	/**
	 * Get the description of this dish
	 * 
	 * @return the dish's description
	 */
	public String getDescription() {
		return this.description;
	}

	/**
	 * Set the description of this dish
	 * 
	 * @param description
	 *            - the description of the dish on the menu
	 * @return the current dish
	 */
	public Dish setDescription(String description) {
		this.description = description;
		return this;
	}

	/**
	 * Get the restaurant key
	 * 
	 * @return the key of the restaurant
	 */
	public Key getRestaurant() {
		return this.restaurant;
	}

	/**
	 * Set the restaurant key
	 * 
	 * @param restaurant
	 * @return the current dish
	 */
	public Dish setRestaurant(Key restaurant) {
		this.restaurant = restaurant;

		return this;
	}

	/**
	 * Get the city
	 * 
	 * @return the city the dish is in
	 */
	public String getCity() {
		return this.city;
	}

	/**
	 * Set the City the dish is in
	 * 
	 * @param city
	 * @return the current dish
	 */
	public Dish setCity(String city) {
		this.city = city;

		return this;
	}

	/**
	 * Get the state the dish is served in
	 * 
	 * @return the state the dish is in
	 */
	public String getState() {
		return this.state;
	}

	/**
	 * Set the state the dish is served in
	 * 
	 * @param state
	 * @return the current dish
	 */
	public Dish setState(String state) {
		this.state = state;

		return this;
	}

	/**
	 * Get the neighborhood the dish is served in
	 * 
	 * @return the neighborhood the restaurant that serves the dish is in
	 */
	public String getNeighborhood() {
		return this.neighborhood;
	}

	/**
	 * Set the neighborhood
	 * 
	 * @param neighborhood
	 *            - neighborhood of the restaurant the dish is served in
	 * @return the current dish
	 */
	public Dish setNeighborhood(String neighborhood) {
		this.neighborhood = neighborhood;

		return this;
	}

	public Date getDateCreated() {
		return this.dateCreated;
	}

	public Date getDateModified() {
		return this.dateModified;
	}

	public void setDateModified(Date dateModified) {
		this.dateModified = dateModified;
	}

	public Key getCreator() {
		return this.creator;
	}

	public Key getLastEditor() {
		return this.lastEditor;
	}

	public void setLastEditor(Key lastEditor) {
		this.lastEditor = lastEditor;

	}

	/**
	 * Get tags related to this dish
	 * 
	 * @return list of tags for this dish
	 */
	public Set<Key> getTags() {
		if (null == this.tags) {
			return new HashSet<Key>();
		} else {
			return this.tags;
		}
	}

	/**
	 * Add a Tag to this Dish
	 * 
	 * @param tag
	 * @return the current dish
	 */
	public Dish addTag(Key tag) {
		// Check null list
		if (this.tags == null)
			this.tags = new HashSet<Key>();

		// We do this because compareTo compares too many things
		for (Key k : this.tags)
			if (k.getId() == tag.getId())
				return this;

		// If no duplicate was found add it and return
		this.tags.add(tag);
		return this;
	}

	/**
	 * Add a set of tags
	 * 
	 * @param tags
	 * @return the current dish
	 */
	public Dish addTags(Collection<Key> tags) {

		for (Key curKey : tags)
			addTag(curKey);

		return this;
	}

	/**
	 * Get the dish's key
	 * 
	 * @return the key associated with this dish
	 */
	public Key getKey() {
		return this.key;
	}

	/**
	 * Get the number of Positive Reviews
	 * 
	 * @return the number of positive reviews for this dish
	 */
	public Integer getNumPosReviews() {
		return this.posReviews == null ? 0 : this.posReviews;
	}

	/**
	 * Get the number of Negative Reviews
	 * 
	 * @return the number of negative reviews for this dish
	 */
	public Integer getNumNegReviews() {
		return this.negReviews == null ? 0 : this.negReviews;
	}

	/**
	 * Get the net rating.
	 * 
	 * @return total reviews defined by (postive reviews + negative reviews)
	 */
	public Integer getNetRating() {
		return getNumPosReviews() + getNumNegReviews();
	}

	/**
	 * Get the percentage of Positive Reviews
	 * 
	 * @return the percentage of Positive reviews out of total number of reviews
	 */
	public Double getPosReviewPercentage() {
		return (double) (getNumPosReviews() / (getNumPosReviews() + getNumNegReviews()));
	}

	/**
	 * Get the percentage of Negative Reviews
	 * 
	 * @return the percentage of Negative reviews out of total number of reviews
	 */
	public Double getNegReviewPercentage() {
		return (double) (getNumNegReviews() / (getNumPosReviews() + this.negReviews));
	}

	/**
	 * Add a review to this dish
	 * 
	 * @param review
	 *            - the review
	 * @return the current dish
	 * 
	 */
	public Dish addReview(Review review) {
		// Check direction
		switch (review.getDirection()) {
		// Handle Positive Vote
		case Review.POSITIVE_DIRECTION:
			if (null == this.posReviews)
				this.posReviews = 0;
			this.posReviews++;
			break;
		// Handle Negative Vote
		case Review.NEGATIVE_DIRECTION:
			if (null == this.negReviews)
				this.negReviews = 0;
			this.negReviews++;
			break;
		}

		return this;
	}

	/**
	 * Get the dish's search terms
	 * 
	 * @return set of search terms associated with this dish
	 */
	public Set<String> getSearchTerms() {
		return this.searchTerms;
	}

	/**
	 * Set the location of this dish
	 * 
	 * @param latitude
	 * @param longitude
	 * @return the current dish
	 */
	public Dish setLocation(double latitude, double longitude) {
		this.longitude = longitude;
		this.latitude = latitude;
		this.geoCells = GeocellManager.generateGeoCell(new Point(this.latitude, this.longitude));

		return this;
	}

	/**
	 * Set the location of this dish
	 * 
	 * @param latitude
	 * @param longitude
	 * @param geoCells
	 * @return the current dish
	 */
	public Dish setLocation(double latitude, double longitude, List<String> geoCells) {
		this.longitude = longitude;
		this.latitude = latitude;
		this.geoCells = geoCells;

		return this;
	}

	public List<String> getGeocells() {
		return this.geoCells;
	}

	public String getKeyString() {
		return Long.valueOf(this.key.getId()).toString();
	}

	public Point getLocation() {
		return new Point(this.latitude, this.longitude);
	}

	/**
	 * Remove a {@link Tag} from this {@link Dish} <br>
	 * NOTE: Checks if the {@link Tag} is this {@link Dish}'s category, cusine,
	 * or price and sets it to null if a match is found.
	 * 
	 * @param k
	 *            - the key of the tag to be removed
	 * @return the current dish
	 */
	public Dish removeTag(Key k) {
		this.tags.remove(k);

		if (k.equals(this.category))
			this.category = null;
		else if (k.equals(this.cuisine))
			this.cuisine = null;
		else if (k.equals(this.price))
			this.price = null;

		return this;
	}

	/**
	 * Removes a list of tags from this dish
	 * 
	 * @param keys
	 *            the keys to be removed
	 * @return the current dish
	 */
	public Dish removeTags(List<Tag> tags) {
		for (Tag t : tags) {
			this.removeTag(t.getKey());
		}
		return this;
	}

	/**
	 * Removes all tags
	 * 
	 * @return the current dish
	 */
	public Dish removeAllTags() {
		this.tags.clear();
		return this;
	}

	/**
	 * Remove a given review from this dish
	 * 
	 * @return the current dish
	 */
	public Dish removeReview(Review r) {
		switch (r.getDirection()) {
		case Review.POSITIVE_DIRECTION:
			if (null != this.posReviews && this.posReviews > 0) {
				this.posReviews--;
			}
			break;
		case Review.NEGATIVE_DIRECTION:
			if (null != this.negReviews && this.negReviews > 0) {
				this.negReviews--;
			}
		}
		return this;
	}

	/**
	 * Add a photo to this dish given a key
	 * 
	 * @param k
	 *            - key of photo to be added
	 * @return the current dish
	 */
	public Dish addPhoto(Key k) {
		if (this.photos == null)
			this.photos = new ArrayList<Key>();

		this.photos.add(k);

		return this;
	}

	/**
	 * Remove a photo given a key
	 * 
	 * @param k
	 *            - key to be removed
	 * @return the current dish
	 */
	public Dish removePhoto(Key k) {
		this.photos.remove(k);
		return this;
	}

	/**
	 * Get photos for this dish
	 * 
	 * @return list of photos for this dish
	 */
	public List<Key> getPhotos() {
		return this.photos;
	}

	/**
	 * Get the total number of reviews for this dish without querying.
	 * 
	 * @return the number of reviews
	 */
	public Integer getNumReviews() {
		return Math.abs(this.getNumNegReviews()) + this.getNumPosReviews();
	}

	/**
	 * Set the dish creator
	 * 
	 * @param creator
	 *            - key of the user who created
	 * @return the current dish
	 */
	public Dish setCreator(Key creator) {
		this.creator = creator;
		return this;
	}

	/**
	 * Get the name of the restaurant this dish is served at
	 * 
	 * @return the restaurant name
	 */
	public String getRestaurantName() {
		return this.restaurantName;
	}

	/**
	 * Set the restaurant name this dish is served at
	 * 
	 * @param restName
	 * @return the current dish
	 */
	public Dish setRestaurantName(String restName) {
		this.restaurantName = restName;

		return this;
	}

	/**
	 * Set the category for this dish
	 * 
	 * @param k
	 *            - the key for the category
	 * @return the dish
	 */
	public Dish setCategory(Key k) {
		addTag(k);
		this.category = k;
		return this;
	}

	/**
	 * Set the price of this dish as the key
	 * 
	 * @param k
	 *            - the key of the price range
	 * @return the current dish
	 */
	public Dish setPrice(Key k) {
		addTag(k);
		this.price = k;
		return this;
	}

	/**
	 * Set the cuisine of this dish as the key
	 * 
	 * @param k
	 *            - the key of the cuisine tag
	 * @return the current dish
	 */
	public Dish setCuisine(Key k) {
		addTag(k);
		this.cuisine = k;
		return this;
	}

	public Key getCuisine() {
		return cuisine;
	}

	public void addFlag(Flag flag) {
		switch (flag.getType()) {
		case Flag.COPYRIGHTED_PICTURE:
			if (this.numFlagsCopyrightedPicture == null)
				this.numFlagsCopyrightedPicture = 0;
			this.numFlagsCopyrightedPicture++;
			break;
		case Flag.DISH_NOT_ON_MENU:
			if (this.numFlagsDishNotOnMenu == null)
				this.numFlagsDishNotOnMenu = 0;
			this.numFlagsDishNotOnMenu++;
			break;
		case Flag.INCORRECT_ALLERGY_TAG:
			if (this.numFlagsIncorrectAllergy == null)
				this.numFlagsIncorrectAllergy = 0;
			this.numFlagsIncorrectAllergy++;
			break;
		case Flag.INCORRECT_DESCRIPTION:
			if (this.numFlagsIncorrectDescription == null)
				this.numFlagsIncorrectDescription = 0;
			this.numFlagsIncorrectDescription++;
			break;
		case Flag.INCORRECT_LIFESTYLE_TAG:
			if (this.numFlagsIncorrectLifestyle == null)
				this.numFlagsIncorrectLifestyle = 0;
			this.numFlagsIncorrectLifestyle++;
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

	public Integer getNumFlagsDishNotOnMenu() {
		if (this.numFlagsDishNotOnMenu == null) {
			return 0;
		} else {
			return this.numFlagsDishNotOnMenu;
		}
	}

	public Integer getNumFlagsIncorrectAllergy() {
		if (this.numFlagsIncorrectAllergy == null) {
			return 0;
		} else {
			return this.numFlagsIncorrectAllergy;
		}
	}

	public Integer getNumFlagsIncorrectDescription() {
		if (this.numFlagsIncorrectDescription == null) {
			return 0;
		} else {
			return this.numFlagsIncorrectDescription;
		}
	}

	public Integer getNumFlagsIncorrectLifestyle() {
		if (this.numFlagsIncorrectLifestyle == null) {
			return 0;
		} else {
			return this.numFlagsIncorrectLifestyle;
		}
	}

	public Integer getNumFlagsOther() {
		if (this.numFlagsOther == null) {
			return 0;
		} else {
			return this.numFlagsOther;
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
	public Dish addSource(Key source, String foriegnId) {

		if (null == this.sources)
			this.sources = new HashMap<Key, String>();

		this.sources.put(source, foriegnId);

		return this;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("Dish [");
		if (category != null) {
			builder.append("category=");
			builder.append(category);
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
		if (description != null) {
			builder.append("description=");
			builder.append(description);
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
		if (latitude != null) {
			builder.append("latitude=");
			builder.append(latitude);
			builder.append(", ");
		}
		if (longitude != null) {
			builder.append("longitude=");
			builder.append(longitude);
			builder.append(", ");
		}
		if (name != null) {
			builder.append("name=");
			builder.append(name);
			builder.append(", ");
		}
		if (negReviews != null) {
			builder.append("negReviews=");
			builder.append(negReviews);
			builder.append(", ");
		}
		if (neighborhood != null) {
			builder.append("neighborhood=");
			builder.append(neighborhood);
			builder.append(", ");
		}
		if (numFlagsCopyrightedPicture != null) {
			builder.append("numFlagsCopyrightedPicture=");
			builder.append(numFlagsCopyrightedPicture);
			builder.append(", ");
		}
		if (numFlagsDishNotOnMenu != null) {
			builder.append("numFlagsDishNotOnMenu=");
			builder.append(numFlagsDishNotOnMenu);
			builder.append(", ");
		}
		if (numFlagsIncorrectAllergy != null) {
			builder.append("numFlagsIncorrectAllergy=");
			builder.append(numFlagsIncorrectAllergy);
			builder.append(", ");
		}
		if (numFlagsIncorrectDescription != null) {
			builder.append("numFlagsIncorrectDescription=");
			builder.append(numFlagsIncorrectDescription);
			builder.append(", ");
		}
		if (numFlagsIncorrectLifestyle != null) {
			builder.append("numFlagsIncorrectLifestyle=");
			builder.append(numFlagsIncorrectLifestyle);
			builder.append(", ");
		}
		if (numFlagsOther != null) {
			builder.append("numFlagsOther=");
			builder.append(numFlagsOther);
			builder.append(", ");
		}
		if (numFlagsTotal != null) {
			builder.append("numFlagsTotal=");
			builder.append(numFlagsTotal);
			builder.append(", ");
		}
		if (photos != null) {
			builder.append("photos=");
			builder.append(photos);
			builder.append(", ");
		}
		if (posReviews != null) {
			builder.append("posReviews=");
			builder.append(posReviews);
			builder.append(", ");
		}
		if (price != null) {
			builder.append("price=");
			builder.append(price);
			builder.append(", ");
		}
		if (restaurant != null) {
			builder.append("restaurant=");
			builder.append(restaurant);
			builder.append(", ");
		}
		if (restaurantName != null) {
			builder.append("restaurantName=");
			builder.append(restaurantName);
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
		if (tags != null) {
			builder.append("tags=");
			builder.append(tags);
		}
		builder.append("]");
		return builder.toString();
	}

	@Override
	public String getForeignIdForSource(Key source) {
		if (null == this.sources)
			this.sources = new HashMap<Key, String>();
		return this.sources.get(source);
	}

	@Override
	public Map<Key, String> getSources() {
		return (null != this.sources ? this.sources : (this.sources = new HashMap<Key, String>()));
	}

	public String getCreatorName() {
		return creatorName;
	}

	public void setCreatorName(String creatorName) {
		this.creatorName = creatorName;
	}

	public Integer getTotalReviews() {
		return totalReviews;
	}

	public void setTotalReviews(Integer totalReviews) {
		this.totalReviews = totalReviews;
	}

	public String getTagString() {
		return tagString;
	}

	public void setTagString(String tagString) {
		this.tagString = tagString;
	}
}