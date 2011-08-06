package com.topdish.api.jdo;

import java.util.Date;

import com.topdish.jdo.Review;

@SuppressWarnings("unused")
public class ReviewLite {
	private int direction;
	private String comment;
	private String creator;
	private Date dateCreated;
	
	public ReviewLite(Review r, String creator){
		this.direction = r.getDirection();
		this.comment = r.getComment();
		this.creator = creator;
		this.dateCreated = r.getDateCreated();
	}
}
