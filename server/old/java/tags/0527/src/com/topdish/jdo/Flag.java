package com.topdish.jdo;

import java.io.Serializable;
import java.util.Date;

import javax.jdo.annotations.IdGeneratorStrategy;
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
public class Flag implements TDPersistable, Serializable{
	private static final long serialVersionUID = 1L;

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
	 * Person at fault
	 */
	@Persistent
	private Key recipient;

	@Persistent
	private String comment;
	
	@Persistent
	private Date dateCreated;
	
	@Persistent
	private Date dateModified;
	
	@Persistent
	private Key lastEditor;
	
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
		this(type, creator, recipient, new String());
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
		this.dateCreated = new Date();
		this.dateModified = new Date();
		this.lastEditor = creator;
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

	@Override
	public Date getDateCreated() {
		return this.dateCreated;
	}

	@Override
	public Date getDateModified() {
		return this.dateModified;
	}

	@Override
	public void setDateModified(Date dateModified) {
		this.dateModified = dateModified;
	}

	@Override
	public void setLastEditor(Key lastEditor) {
		this.lastEditor = lastEditor;
	}

	@Override
	public Key getLastEditor() {
		return this.lastEditor;
	}
}

	
