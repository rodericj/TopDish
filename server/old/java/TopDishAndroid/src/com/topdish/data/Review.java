package com.topdish.data;

import java.util.Date;

import com.google.gson.Gson;

public class Review {
	/**
	 * Direction of Review <br>
	 * Positive = 1 <br>
	 * Negative = -1 <br>
	 */
	public int direction;

	/**
	 * Associated Comment
	 */
	public String comment;

	/**
	 * User who created the review
	 */
	public String creator;

	/**
	 * Date Review was created
	 */
	public Date dateCreated;

	/**
	 * Default Constructor <br>
	 * Note: Required to use {@link Gson}
	 */
	public Review() {

	}

	/**
	 * @param direction
	 * @param comment
	 * @param creator
	 * @param dateCreated
	 */
	public Review(int direction, String comment, String creator,
			Date dateCreated) {
		super();
		this.direction = direction;
		this.comment = comment;
		this.creator = creator;
		this.dateCreated = dateCreated;
	}

}
