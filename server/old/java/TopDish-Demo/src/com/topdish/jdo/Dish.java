package com.topdish.jdo;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Set;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.LocationCapable;
import com.beoui.geocell.model.Point;
import com.google.appengine.api.datastore.Key;
import com.topdish.search.AbstractSearch;
import com.topdish.util.DishLookupUtils;
import com.topdish.util.PMF;

/**
 * Dish Object <br>
 * 
 * All Setters return the current Object
 * 
 * @author Randy
 * 
 */
@PersistenceCapable
public class Dish implements TDPersistable, LocationCapable, Serializable {

	/**
	 * 
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
	private List<Key> tags;

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
	 * List of Reviews
	 */
	@Persistent
	private List<Key> reviews;

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
	public Dish(String name, String description, Key restaurant, String city,
			String state, String neighborhood, double latitude,
			double longitude, String restaurantName, Date dateCreated,
			Key creator, List<Key> tags) {
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
		this.searchTerms = AbstractSearch.getSearchTerms(name);
		this.tags = tags;
		this.geoCells = GeocellManager.generateGeoCell(new Point(this.latitude,
				this.longitude));
		this.reviews = new ArrayList<Key>();
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
	 */
	public Dish(String name, String description, Restaurant restaurant,
			Date dateCreated, Key creator, List<Key> tags) {
		// Redirect at the main constructor and deconstruct restaurant
		this(name, description, restaurant.getKey(), restaurant.getCity(),
				restaurant.getState(), restaurant.getNeighborhood(), restaurant
						.getLatitude(), restaurant.getLongitude(), restaurant
						.getName(), dateCreated, creator, tags);
	}
	
	/**
	 * Default constructor <br />
	 * 
	 * Note: do not use for creating a Dish object.  Specifically created for generic operations.
	 */
	public Dish(){}

	public Dish(String name, String description, Key restaurant, Key creator,
			List<Key> tags) {
		// Redirect at the main constructor and deconstruct restaurant
		this(name, description, (Restaurant) PMF.get().getPersistenceManager()
				.getObjectById(restaurant), new Date(), creator, tags);
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
		this.searchTerms = AbstractSearch.getSearchTerms(name);

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
	public List<Key> getTags() {
		return this.tags == null ? new ArrayList<Key>() : this.tags;
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
			this.tags = new ArrayList<Key>();

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
	 * @deprecated Not necessary any more since getReviews() uses GQL
	 */
	@Deprecated
	public Dish addReview(Review review) {
		// Check direction
		switch (review.getDirection()) {
		// Handle Positive Vote
		case Review.POSITIVE_DIRECTION:
			if (null == this.posReviews)
				posReviews = 0;
			posReviews++;
			break;
		// Handle Negative Vote
		case Review.NEGATIVE_DIRECTION:
			if (null == this.negReviews)
				negReviews = 0;
			negReviews++;
			break;
		}
		this.reviews.add(review.getKey());
		
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
		this.geoCells = GeocellManager.generateGeoCell(new Point(this.latitude,
				this.longitude));

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
	public Dish setLocation(double latitude, double longitude,
			List<String> geoCells) {
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
	 * Remove a tag from this dish
	 * 
	 * @param k
	 *            - the key of the tag to be removed
	 * @return the current dish
	 */
	public Dish removeTag(Key k) {
		// Handled because key object compareTo compares more than the id
		for (Key tagKey : this.tags)
			if (tagKey.getId() == k.getId())
				this.tags.remove(tagKey);

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
	 * @param r
	 *            - review to be removed
	 * @return the current dish
	 */
	public Dish removeReview(Review r) {
		if (this.reviews.contains(r)) {
			if (r.getDirection() == Review.POSITIVE_DIRECTION) {
				this.posReviews--;
			} else if (r.getDirection() == Review.NEGATIVE_DIRECTION) {
				this.negReviews--;
			}
			this.reviews.remove(r.getKey());
		}
		return this;
	}

	/**
	 * Remove a Review given a Key
	 * 
	 * @param k
	 *            - key of review to be removed
	 * @return the current dish
	 */
	public Dish removeReview(Key k) {
		this.reviews.remove(k);
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
	 * @return the number of reviews
	 */
	public Integer getNumReviews(){
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
	 * Get the Category key for this dish
	 * 
	 * @return the key for catagory for this dish
	 */
	public Key getCategory() {
		if (this.category != null) {
			return this.category;
		} else {
			this.category = DishLookupUtils.getCategoryKey(this.key);
			return this.category;
		}
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
	 * Get the price of the key
	 * 
	 * @return the price range of this dish
	 */
	public Key getPrice() {
		if (this.price != null) {
			return this.price;
		} else {
			this.price = DishLookupUtils.getPriceKey(this.key);
			return this.price;
		}
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
	 * @param k - the key of the cuisine tag
	 * @return the current dish
	 */
	public Dish setCuisine(Key k) {
		addTag(k);
		System.out.println("cuisines present: " + this.cuisine);
		this.cuisine = k;
		System.out.println("new cuisines present: " + this.cuisine);
		return this;
	}

	public Key getCuisine() {
		return cuisine;
	}

	public void addFlag(Flag flag) {
		switch (flag.getType()) {
		case Flag.COPYRIGHTED_PICTURE:
			if(this.numFlagsCopyrightedPicture==null)
				this.numFlagsCopyrightedPicture = 0;
			this.numFlagsCopyrightedPicture++;
			break;
		case Flag.DISH_NOT_ON_MENU:
			if(this.numFlagsDishNotOnMenu==null)
				this.numFlagsDishNotOnMenu=0;
			this.numFlagsDishNotOnMenu++;
			break;
		case Flag.INCORRECT_ALLERGY_TAG:
			if(this.numFlagsIncorrectAllergy==null)
				this.numFlagsIncorrectAllergy=0;
			this.numFlagsIncorrectAllergy++;
			break;
		case Flag.INCORRECT_DESCRIPTION:
			if(this.numFlagsIncorrectDescription==null)
				this.numFlagsIncorrectDescription=0;
			this.numFlagsIncorrectDescription++;
			break;
		case Flag.INCORRECT_LIFESTYLE_TAG:
			if(this.numFlagsIncorrectLifestyle==null)
				this.numFlagsIncorrectLifestyle = 0;
			this.numFlagsIncorrectLifestyle++;
			break;
		case Flag.OTHER:
			if(this.numFlagsOther==null)
				this.numFlagsOther=0;
			this.numFlagsOther++;
			break;
		}
		if(this.numFlagsTotal==null)
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
}