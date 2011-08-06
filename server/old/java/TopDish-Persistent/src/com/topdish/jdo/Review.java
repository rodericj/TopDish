package com.topdish.jdo;

import java.util.Date;
import java.util.List;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.NotPersistent;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.appengine.api.datastore.Key;

@PersistenceCapable
public class Review implements TDPersistable {

	/**
	 * Positive Review = 1
	 */
	public static final int POSITIVE_DIRECTION = 1;

	/**
	 * Negative Review = -1
	 */
	public static final int NEGATIVE_DIRECTION = -1;

	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	@Persistent
	private Key dish;

	@Persistent
	private int direction;

	@Persistent
	private String comment;

	@Persistent
	private Date dateCreated;

	@Persistent
	private Date dateModified;

	@Persistent
	private Key creator;

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
	
	@NotPersistent
	private String dishName;
	
	@NotPersistent
	private String creatorName;
	
	/**
	 * Constructor to create a review
	 * 
	 * @param dish
	 * @param direction
	 * @param comment
	 * @param creator
	 */
	public Review(Key dish, int direction, String comment, Key creator) {
		this.dish = dish;
		this.direction = direction;
		this.comment = comment;
		this.dateCreated = new Date();
		this.creator = creator;
	}

	/**
	 * Default constructor
	 */
	public Review(){}
	
	
	public Key getDish() {
		return dish;
	}

	public int getDirection() {
		return direction;
	}

	public void setDirection(int direction) {
		this.direction = direction;
	}

	public String getComment() {
		return comment;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}

	public Date getDateCreated() {
		return dateCreated;
	}

	public Date getDateModified() {
		return dateModified;
	}

	public void setDateModified(Date dateModified) {
		this.dateModified = dateModified;
	}

	public Key getCreator() {
		return creator;
	}

	public Key getKey() {
		return key;
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

	@Override
	public void setLastEditor(Key lastEditor) {
		// TODO Auto-generated method stub

	}

	@Override
	public Key getLastEditor() {
		// TODO Auto-generated method stub
		return null;
	}

	public String getDishName() {
		return dishName;
	}

	public void setDishName(String dishName) {
		this.dishName = dishName;
	}

	public String getCreatorName() {
		return creatorName;
	}

	public void setCreatorName(String creatorName) {
		this.creatorName = creatorName;
	}
	
	
}