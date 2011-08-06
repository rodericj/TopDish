package com.topdish.jdo;

import java.util.ArrayList;
import java.util.List;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;
import com.topdish.jdo.TDUserRole;

/**
 * Class representing a TopDish user. Created as a wrapper for the built-in
 * {@link User} class to provide more flexibility and detail.
 * 
 * @author ralmand (Randy Almand)
 */

@PersistenceCapable
public class TDUser {

	/**
	 * The datastore key of this object
	 */
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	/**
	 * The {@link User} object of this ExUser
	 */
	@Persistent
	private User userObj;

	/**
	 * The ID string of the user object
	 */
	@Persistent
	private String userID;

	/**
	 * The user's nickname
	 */
	@Persistent
	private String nickname;

	/**
	 * The user's email address
	 */
	@Persistent
	private String email;

	/**
	 * User's photo
	 */
	@Persistent
	private Key photo;

	/**
	 * The "foodie bio"
	 */
	@Persistent
	private String bio;

	/**
	 * Reviews
	 */
	@Persistent
	private List<Key> reviews;

	@Persistent
	private Integer numReviews;

	@Persistent
	private Integer numPosReviews;

	@Persistent
	private Integer numNegReviews;

	@Persistent
	private List<Key> dishes;

	@Persistent
	private Integer numDishes;

	@Persistent
	private List<Key> restaurants;

	@Persistent
	private Integer numRestaurants;

	@Persistent
	private Integer numFlagsInappropriate;

	@Persistent
	private Integer numFlagsSpam;

	@Persistent
	private Integer numFlagsInaccurate;

	@Persistent
	private Integer numFlagsTotal;

	@Persistent
	private List<Key> flags;

	@Persistent
	private List<Key> lifestyles;

	@Persistent
	private List<Key> allergens;

	/**
	 * User's API Key
	 */
	@Persistent
	private String ApiKey;

	/**
	 * Facebook ID Key
	 */
	@Persistent
	private String facebookId;
	
	
	/**
	 * user role
	 */
	@Persistent
	private Integer role = 0;

	/**
	 * Class constructor that takes a user object, nickname, email address, and
	 * photo and default role(standard)
	 * 
	 * @param userObj
	 *            a {@link User} object
	 * @param nickname
	 *            a nickname chosen by the user to be displayed instead of their
	 *            email address
	 * @param email
	 *            an email address that the user provided
	 * @param photo
	 *            key of photo objec to set as avatar
	 * 
	 */
	public TDUser(User userObj, String nickname, String email, Key photo) {
		this.userObj = userObj;
		this.userID = userObj.getUserId();
		this.nickname = nickname;
		this.email = email;
		this.photo = photo;
		this.role=TDUserRole.ROLE_STANDARD;
	}
	
	/**
	 * Class constructor that takes a user object, nickname, email address, and
	 * photo and role
	 * 
	 * @param userObj
	 *            a {@link User} object
	 * @param nickname
	 *            a nickname chosen by the user to be displayed instead of their
	 *            email address
	 * @param email
	 *            an email address that the user provided
	 * @param photo
	 *            key of photo objec to set as avatar
	 *  @param role
	 *            role of a user
	 */
	public TDUser(User userObj, String nickname, String email, Key photo,int role) {
		this.userObj = userObj;
		this.userID = userObj.getUserId();
		this.nickname = nickname;
		this.email = email;
		this.photo = photo;
		this.role=role;
	}
	
	
	/**
	 * Class constructor that takes a user object, nickname, email address, and
	 *  role
	 * 
	 * @param userObj
	 *            a {@link User} object
	 * @param nickname
	 *            a nickname chosen by the user to be displayed instead of their
	 *            email address
	 * @param email
	 *            an email address that the user provided
	 * @param photo
	 *            key of photo objec to set as avatar
	 *  @param role
	 *            role of a user
	 */
	public TDUser(User userObj, String nickname, String email, int role) {
		this(userObj,nickname,email,null,role);
	}

	/**
	 * Class constructor that takes a user object, nickname, and email address.
	 * 
	 * @param userObj
	 *            a {@link User} object
	 * @param nickname
	 *            a nickname chosen by the user to be displayed instead of their
	 *            email address
	 * @param email
	 *            an email address that the user provided
	 * 
	 */
	public TDUser(User userObj, String nickname, String email) {
		this(userObj, nickname, email, null);
		// this.userObj = userObj;
		// this.userID = userObj.getUserId();
		// this.nickname = nickname;
		// this.email = email;
		// this.photo = null;
	}

	/**
	 * Class constructor for creating a user with only a user object.
	 * 
	 * @param userObj
	 *            a com.google.appengine.api.users.User object
	 */
	public TDUser(User userObj) {
		this(userObj, userObj.getNickname(), userObj.getEmail(), null);
		// this.userObj = userObj;
		// this.userID = userObj.getUserId();
		// this.nickname = userObj.getNickname();
		// this.email = userObj.getEmail();
		// this.photo = null;
	}

	/**
	 * Fetches the user's nickname
	 * 
	 * @return the user's nickname
	 */
	public String getNickname() {
		return this.nickname;
	}

	/**
	 * Sets the user's nickname
	 * 
	 * @param nickname
	 *            nickname to set
	 */
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	/**
	 * Fetches the user's email address
	 * 
	 * @return the user's email address
	 */
	public String getEmail() {
		return this.email;
	}

	/**
	 * Sets the user's email address
	 * 
	 * @param email
	 *            address to set
	 */
	public void setEmail(String email) {
		this.email = email;
	}

	/**
	 * Fetches the {@link User} object
	 * 
	 * @return the {@link User} object
	 */
	public User getUserObj() {
		return this.userObj;
	}

	/**
	 * Fetches the datastore object {@link Key}
	 * 
	 * @return the datastore object {@link Key}
	 */
	public Key getKey() {
		return this.key;
	}

	/**
	 * Fetches the {@link User} ID
	 * 
	 * @return the {@link User} ID
	 */
	public String getUserID() {
		return this.userID;
	}

	public void setPhoto(Key p) {
		this.photo = p;
	}

	public Key getPhoto() {
		return this.photo;
	}

	public void setBio(String bio) {
		this.bio = bio;
	}

	public String getBio() {
		return this.bio;
	}

	public List<Key> getLifestyles() {
		return this.lifestyles;
	}

	public void setLifestyles(List<Key> lifestyles) {
		this.lifestyles = lifestyles;
	}

	public List<Key> getAllergens() {
		return this.allergens;
	}

	public void setAllergens(List<Key> allergens) {
		this.allergens = allergens;
	}

	public void removePhoto() {
		this.photo = null;
	}

	/**
	 * 
	 * @param r
	 *            restaurant to add
	 * 
	 * @deprecated Not necessary any more since getDishes now uses GQL query
	 */
	public void addReview(Review r) {
		if (this.reviews == null) {
			this.reviews = new ArrayList<Key>();
		}
		if (this.numReviews == null) {
			this.numReviews = 0;
		}
		if (this.numPosReviews == null) {
			this.numPosReviews = 0;
		}
		if (this.numNegReviews == null) {
			this.numNegReviews = 0;
		}

		this.reviews.add(r.getKey());
		this.numReviews++;

		if (r.getDirection() == Review.POSITIVE_DIRECTION) {
			this.numPosReviews++;
		} else if (r.getDirection() == Review.NEGATIVE_DIRECTION) {
			this.numNegReviews++;
		}
	}

	public Integer getNumReviews() {
		if (this.numReviews == null)
			return 0;
		return this.numReviews;
	}

	/**
	 * Add dish to this user's profile
	 * 
	 * @param d
	 *            dish to add
	 * 
	 * @deprecated Not necessary any more since getDishes now uses GQL query
	 */
	public void addDish(Dish d) {
		if (this.dishes == null) {
			this.dishes = new ArrayList<Key>();
		}
		if (this.numDishes == null) {
			this.numDishes = 0;
		}

		this.dishes.add(d.getKey());
		this.numDishes++;
	}

	public Integer getNumDishes() {
		if(null==numDishes)
			return 0;
		else
			return this.numDishes;
		//return this.getNumDishes();
	}

	public void setNumDishes(Integer numDishes) {
		this.numDishes = numDishes;
	}

	public Integer getNumRestaurants() {
		if(numRestaurants == null)
			return 0;
		else
			return this.numRestaurants;
	}

	public void setNumRestaurants(Integer numRestaurants) {
		this.numRestaurants = numRestaurants;
	}

	/**
	 * 
	 * @param r
	 *            restaurant to add
	 * 
	 * @deprecated Not necessary any more since getDishes now uses GQL query
	 */
	public void addRestaurant(Restaurant r) {
		if (this.restaurants == null) {
			this.restaurants = new ArrayList<Key>();
		}
		if (this.numRestaurants == null) {
			this.numRestaurants = 0;
		}

		this.restaurants.add(r.getKey());
		this.numRestaurants++;
	}

	public Integer getNumPosReviews() {
		if (this.numPosReviews == null)
			return 0;
		else
			return this.numPosReviews;
	}

	public Integer getNumNegReviews() {
		if (this.numNegReviews == null)
			return 0;
		else
			return this.numNegReviews;
	}

	/**
	 * 
	 * @return Key of last review or NULL if none found
	 */
	public Key getLastReview() {
		if (this.reviews.size() > 0) {
			return this.reviews.get(this.reviews.size() - 1);
		} else {
			return null;
		}
	}

	public void removeReview(Review r) {
		if (this.reviews.contains(r)) {
			if (r.getDirection() == Review.POSITIVE_DIRECTION) {
				this.numPosReviews--;
			} else if (r.getDirection() == Review.NEGATIVE_DIRECTION) {
				this.numNegReviews--;
			}
			this.reviews.remove(r.getKey());
		}
	}

	/**
	 * Only to be used when review object not found!
	 * 
	 * @param k
	 *            Key to remove
	 */
	public void removeReviewKey(Key k) {
		this.reviews.remove(k);
	}

	public void addFlag(Flag flag) {
		if (this.numFlagsInaccurate == null) {
			this.numFlagsInaccurate = 0;
		}
		if (this.numFlagsInappropriate == null) {
			this.numFlagsInappropriate = 0;
		}
		if (this.numFlagsSpam == null) {
			this.numFlagsSpam = 0;
		}
		if (this.numFlagsTotal == null) {
			this.numFlagsTotal = 0;
		}

		switch (flag.getType()) {
		case Flag.INACCURATE:
			this.numFlagsInaccurate++;
			break;
		case Flag.INAPPROPRIATE:
			this.numFlagsInappropriate++;
			break;
		case Flag.SPAM:
			this.numFlagsSpam++;
			break;
		}
		this.numFlagsTotal++;
		this.flags.add(flag.getKey());
	}

	public Integer getNumFlagsInaccurate() {
		if (this.numFlagsInaccurate == null) {
			return 0;
		} else {
			return this.numFlagsInaccurate;
		}
	}

	public Integer getNumFlagsInappropriate() {
		if (this.numFlagsInappropriate == null) {
			return 0;
		} else {
			return this.numFlagsInappropriate;
		}
	}

	public Integer getNumFlagsSpam() {
		if (this.numFlagsSpam == null) {
			return 0;
		} else {
			return this.numFlagsSpam;
		}
	}

	public Integer getNumFlagsTotal() {
		if (this.numFlagsTotal == null) {
			return 0;
		} else {
			return this.numFlagsTotal;
		}
	}

	/**
	 * Set the API Key
	 * 
	 * @param apiKey
	 *            - the API key to set
	 * @return the current user
	 */
	public TDUser setApiKey(String apiKey) {
		ApiKey = apiKey;
		return this;
	}

	/**
	 * Get the API Key
	 * 
	 * @return user's api key
	 */
	public String getApiKey() {
		return ApiKey;
	}

	/**
	 * Get this user's Facebook Id
	 * 
	 * @return the id or an empty string
	 */
	public String getFacebookId() {
		if (null == facebookId)
			this.facebookId = new String();

		return this.facebookId;
	}

	/**
	 * Set the Id
	 * 
	 * @param id
	 *            - id to set
	 * @return the current user
	 */
	public TDUser setFacebookId(String id) {
		this.facebookId = id;
		return this;
	}

	
	/**
	 * Fetches the user's role
	 * 
	 * @return the user's role
	 */
	public Integer getRole() {
		if(null==role)
			return TDUserRole.ROLE_STANDARD;
		return role;
	}

	/**
	 * Set the role
	 * 
	 * @param role
	 *            - role to set
	 */
	public void setRole(Integer role) {
		this.role = role;
	}
	
	
}
