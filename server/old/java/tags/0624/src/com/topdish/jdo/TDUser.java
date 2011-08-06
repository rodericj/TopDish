package com.topdish.jdo;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;

/**
 * Class representing a TopDish user. Created as a wrapper for the built-in
 * {@link User} class to provide more flexibility and detail.
 * 
 * @author ralmand (Randy Almand)
 */

@PersistenceCapable
public class TDUser implements TDPersistable, Serializable {
	private static final long serialVersionUID = 1L;

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

	@Persistent
	private Integer numReviews;

	@Persistent
	private Integer numPosReviews;

	@Persistent
	private Integer numNegReviews;

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
	private String ApiKey = UUID.randomUUID().toString();

	/**
	 * user role
	 */
	@Persistent
	private Integer role = 0;

	/**
	 * Facebook ID
	 */
	@Persistent
	private String facebookId;

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
		this(userObj, nickname, email, photo, TDUserRole.ROLE_STANDARD);
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
	 * @param role
	 *            role of a user
	 */
	public TDUser(User userObj, String nickname, String email, Key photo,
			int role) {
		this.userObj = userObj;
		this.userID = userObj.getUserId();
		this.nickname = nickname;
		this.email = email;
		this.photo = photo;
		this.role = role;
	}

	/**
	 * Class constructor that takes a user object, nickname, email address, and
	 * role
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
	 * @param role
	 *            role of a user
	 */
	public TDUser(User userObj, String nickname, String email, int role) {
		this(userObj, nickname, email, null, role);
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
	}

	/**
	 * Class constructor for creating a user with only a user object.
	 * 
	 * @param userObj
	 *            a com.google.appengine.api.users.User object
	 */
	public TDUser(User userObj) {
		this(userObj, userObj.getNickname(), userObj.getEmail(), null);
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
	 * Sets the {@link User} object
	 * 
	 * @return the current {@link TDUser} object
	 */
	public TDUser setUserObj(User userObj) {
		this.userObj = userObj;
		this.userID = userObj.getUserId();
		return this;
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
	 * Remove dish to correct user's stats.
	 */
	public void removeDish() {
		if (this.numDishes > 0) {
			this.numDishes--;
		}
	}

	/**
	 * Remove a review that a user wrote to correct their stats.
	 * 
	 * @param r
	 *            review to remove
	 */
	public void removeReview(Review r) {
		if (r.getDirection() == Review.POSITIVE_DIRECTION) {
			if (this.numPosReviews > 0) {
				this.numPosReviews--;
			}
		} else if (r.getDirection() == Review.NEGATIVE_DIRECTION) {
			if (this.numNegReviews > 0) {
				this.numNegReviews--;
			}
		}
	}

	/**
	 * Add a review to increase the user's stats.
	 * 
	 * @param r
	 *            review to add
	 */
	public void addReview(Review r) {
		if (this.numReviews == null) {
			this.numReviews = 0;
		}
		if (this.numPosReviews == null) {
			this.numPosReviews = 0;
		}
		if (this.numNegReviews == null) {
			this.numNegReviews = 0;
		}

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
	 * Add dish to increase user's stats.
	 * 
	 * @param d
	 *            dish to add
	 */
	public void addDish() {
		if (this.numDishes == null) {
			this.numDishes = 0;
		}

		this.numDishes++;
	}

	public Integer getNumDishes() {
		if (null == numDishes)
			return 0;
		else
			return this.numDishes;
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
		this.ApiKey = apiKey;
		return this;
	}

	/**
	 * Get the API Key
	 * 
	 * @return user's api key
	 */
	public String getApiKey() {

		if (null == this.ApiKey)
			this.ApiKey = UUID.randomUUID().toString();

		return this.ApiKey;
	}

	/**
	 * Fetches the user's role
	 * 
	 * @return the user's role
	 */
	public Integer getRole() {
		if (null == this.role)
			return (this.role = TDUserRole.ROLE_STANDARD);
		return this.role;
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

	/**
	 * Get the Facebook ID
	 * 
	 * @return the facebook id
	 */
	public String getFacebookId() {
		return this.facebookId;
	}

	/**
	 * Set the Facebook Id
	 * 
	 * @param facebookId
	 *            - the facebook id
	 * @return the current {@link TDUser} instance
	 */
	public TDUser setFacebookId(String facebookId) {
		this.facebookId = facebookId;
		return this;
	}

	@Override
	public Date getDateCreated() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Date getDateModified() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void setDateModified(Date dateModified) {
		// TODO Auto-generated method stub

	}

	@Override
	public Key getCreator() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void setLastEditor(Key lastEditor) {
		// TODO Auto-generated method stub

	}

	@Override
	public Key getLastEditor() {
		// TODO Auto-generated method stub
		return null;
	}

}
