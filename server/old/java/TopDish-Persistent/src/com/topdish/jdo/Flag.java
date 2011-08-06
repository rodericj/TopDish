package com.topdish.jdo;

import java.util.Date;
import java.util.HashMap;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.NotPersistent;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.appengine.api.datastore.Key;

/**
 * Flag Object
 * 
 * @author Randy
 * 
 */
@PersistenceCapable
public class Flag {

	/**
	 * Not to be persisted. Used to store the username string of the user who created this flag
	 */
	@NotPersistent
	private String creatorUsername;
	
	/**
	 * Not to be persisted. Used to store the string value of the flag type
	 */
	@NotPersistent
	private String typeStringValue;
	
	/**
	 * Flagged as Inaccurate
	 */
	public final static int INACCURATE = 0;

	/**
	 * Flagged as Spam
	 */
	public final static int SPAM = 1;

	/**
	 * Flagged as Inappropriate
	 */
	public final static int INAPPROPRIATE = 2;
	/**
	 * Flagged as incorrect lifestyle tag 
	 */
	public final static int INCORRECT_LIFESTYLE_TAG = 3;
	/**
	 * Flagged as incorrect allergy tag 
	 */
	public final static int INCORRECT_ALLERGY_TAG = 4;
	/**
	 * Flagged as incorrect description 
	 */
	public final static int INCORRECT_DESCRIPTION = 5;
	/**
	 * Flagged as copyrighted picture 
	 */
	public final static int COPYRIGHTED_PICTURE = 6;
	/**
	 * Flagged as incorrect cuisine type 
	 */
	public final static int INCORRECT_CUISINE_TYPE = 7;
	/**
	 * Flagged as incorrect address 
	 */
	public final static int INCORRECT_ADDRESS = 8;
	/**
	 * Flagged as incorrect contact detail 
	 */
	public final static int INCORRECT_CONTACT_DETAIL = 9;
	/**
	 * Flagged as restaurant closed 
	 */
	public final static int RESTAURANT_CLOSED = 10;
	/**
	 * Flagged as dish not on menu 
	 */
	public final static int DISH_NOT_ON_MENU = 11;
	/**
	 * Flagged as other reasons 
	 */
	public final static int OTHER = 12;
	
	/**
	 * A map containing names of all the flag types
	 * Used to get the flag type name based on the type value
	 */
	public static HashMap<String,String> FLAG_TYPE_NAME;
	static{
		FLAG_TYPE_NAME = new HashMap<String,String>();
		FLAG_TYPE_NAME.put("0", "Inaccurate");
		FLAG_TYPE_NAME.put("1", "Spam");
		FLAG_TYPE_NAME.put("2", "Inappropriate");
		FLAG_TYPE_NAME.put("3", "Incorrect lifestyle tag");
		FLAG_TYPE_NAME.put("4", "Incorrect allergy tag");
		FLAG_TYPE_NAME.put("5", "Incorrect description");
		FLAG_TYPE_NAME.put("6", "Copyrighted picture");
		FLAG_TYPE_NAME.put("7", "Incorrect cuisine type");
		FLAG_TYPE_NAME.put("8", "Incorrect address");
		FLAG_TYPE_NAME.put("9", "Incorrect contact detail");
		FLAG_TYPE_NAME.put("10", "Restaurant closed");
		FLAG_TYPE_NAME.put("11", "Dish not on Menu");
		FLAG_TYPE_NAME.put("12", "Othe");
	}
	

	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	/**
	 * Type of flagging <br>
	 * Examples: Inaccurate, Spam, Inappropriate
	 */
	@Persistent
	private Integer type;

	/**
	 * Person who is doing the blaming
	 */
	@Persistent
	private Key creator;

	/**
	 * Contains reference to dish the corresponding dish object if this flag is for a dish
	 */
	@Persistent
	private Key dish;
	
	/**
	 * Contains reference to restaurant the corresponding restaurant object if this flag is for a restaurant
	 */
	@Persistent
	private Key restaurant;
	
	/**
	 * Contains reference to review the corresponding review object if this flag is for a review
	 */
	@Persistent
	private Key review;
	
	/**
	 * Contains reference to photo the corresponding photo object if this flag is for a photo
	 */
	@Persistent
	private Key photo;
	
	/**
	 * Identifies for which entity this flag is for
	 * Possible values:
	 * dish, restaurant, review, photo
	 */
	@Persistent
	private String flagFor;
	
	/**
	 * Status of the flag
	 * At present used by admin module to determine whether this flag has been reviewed by admin
	 * Possible values:
	 * 1 - This is a new flag yet to be reviewed by admin
	 * 0 - This flag has been reviewed by admin
	 */
	@Persistent
	private Integer status;
	
	/**
	 * The comment added by admin while resolving this flag
	 */
	@Persistent
	private String adminComment;
	
	/**
	 * The date on which the admin marks this flag as resolved
	 */
	@Persistent
	private transient Date resolvedDate;
	
	/**
	 * Admin user who marks this flag as resolved
	 */
	@Persistent
	private Key resolvedBy;
	/**
	 * Person at fault
	 */
	@Persistent
	private Key recipient;

	/**
	 * Comment added by the user when flagging an entity
	 */
	@Persistent
	private String comment;
	
	
	/**
	 * Constructor for all fields
	 * 
	 * @param type
	 *            - the type as defined by the {@link Flag} statics
	 * @param creator
	 *            - the key of the person who is doing the blaming
	 * @param recipient
	 *            - the key of the person at fault
	 */
	public Flag(Integer type, Key creator, Key recipient) {
		this.type = type;
		this.creator = creator;
		this.recipient = recipient;
	}
	
	/**
	 * Constructor for all fields
	 * 
	 * @param type
	 *            - the type as defined by the {@link Flag} statics
	 * @param creator
	 *            - the key of the person who is doing the blaming
	 * @param recipient
	 *            - the key of the person at fault
	 * @param comment
	 *            - the flagging comment entered 
	 */
	public Flag(Integer type, Key creator, Key recipient, String comment) {
		this.type = type;
		this.creator = creator;
		this.recipient = recipient;
		this.comment = comment;
	}

	/**
	 * Get the Key
	 * 
	 * @return the {@link Key}
	 */
	public Key getKey() {
		return this.key;
	}

	/**
	 * Get Flag type <br>
	 * Note: See {@link Flag} statics
	 * 
	 * @return the type
	 */
	public Integer getType() {
		return this.type;
	}

	/**
	 * Get the key of the person who is doing the blaming
	 * 
	 * @return the persons {@link Key}
	 */
	public Key getCreator() {
		return this.creator;
	}

	/**
	 * Get the key of the person being blamed
	 * 
	 * @return the person's {@link Key}
	 */
	public Key getRecipient() {
		return this.recipient;
	}
	
	/**
	 * Get the flagging comment entered by the user
	 * 
	 * @return the comment
	 */
	public String getComment(){
		return this.comment;
	}

	public Key getDish() {
		return dish;
	}

	public void setDish(Key dish) {
		this.dish = dish;
	}

	public Key getRestaurant() {
		return restaurant;
	}

	public void setRestaurant(Key restaurant) {
		this.restaurant = restaurant;
	}

	public Key getReview() {
		return review;
	}

	public void setReview(Key review) {
		this.review = review;
	}

	public Key getPhoto() {
		return photo;
	}

	public void setPhoto(Key photo) {
		this.photo = photo;
	}

	public String getFlagFor() {
		return flagFor;
	}

	public void setFlagFor(String flagFor) {
		this.flagFor = flagFor;
	}

	public Integer getStatus() {
		return status;
	}

	public void setStatus(Integer status) {
		this.status = status;
	}

	public String getCreatorUsername() {
		return creatorUsername;
	}

	public void setCreatorUsername(String creatorUsername) {
		this.creatorUsername = creatorUsername;
	}

	public String getTypeStringValue() {
		return typeStringValue;
	}

	public void setTypeStringValue(String typeStringValue) {
		this.typeStringValue = typeStringValue;
	}

	public String getAdminComment() {
		return adminComment;
	}

	public void setAdminComment(String adminComment) {
		this.adminComment = adminComment;
	}

	public Date getResolvedDate() {
		return resolvedDate;
	}

	public void setResolvedDate(Date resolvedDate) {
		this.resolvedDate = resolvedDate;
	}

	public Key getResolvedBy() {
		return resolvedBy;
	}

	public void setResolvedBy(Key resolvedBy) {
		this.resolvedBy = resolvedBy;
	}
	
}

	
