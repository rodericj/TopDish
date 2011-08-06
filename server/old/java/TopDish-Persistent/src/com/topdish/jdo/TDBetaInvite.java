package com.topdish.jdo;

import java.util.UUID;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;

@PersistenceCapable
public class TDBetaInvite {
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	/**
	 * The ID string of the user object
	 */
	@Persistent
	private String userID;

	/**
	 * The ID string of the user object
	 */
	@Persistent
	private String hashKey;

	/**
	 * Has the key been used?
	 */
	@Persistent
	private boolean active;

	/**
	 * Constructor to accept a User
	 * 
	 * @param userObj
	 */
	public TDBetaInvite(User userObj) {
		this.userID = userObj.getUserId();
		this.hashKey = UUID.randomUUID().toString();
		this.active = true;
	}

	/**
	 * Constructor to accept a TD User
	 * 
	 * @param userObj
	 */
	public TDBetaInvite(TDUser userObj) {
		this(userObj.getUserObj());
	}

	public TDBetaInvite() {
		this.hashKey = UUID.randomUUID().toString();
		this.active = false;
		this.userID = null;
	}

	/**
	 * Fetches the datastore object {@link Key}
	 * 
	 * @return the datastore object {@link Key}
	 */
	public Key getKey() {
		return this.key;
	}

	public String getUserID() {
		return this.userID;
	}

	public void setUserID(String userid) {
		this.userID = userid;
	}

	public String getHash() {
		return this.hashKey;
	}

	public void setHash(String hash) {
		this.hashKey = hash;
	}

	public boolean getActive() {
		return this.active;
	}

	public void setActive(boolean active) {
		this.active = active;
	}
	
	public static TDBetaInvite getNewInvite() {
		return new TDBetaInvite();
	}
}
