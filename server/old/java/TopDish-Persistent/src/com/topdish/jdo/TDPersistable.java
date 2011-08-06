package com.topdish.jdo;

import java.util.Date;

import com.google.appengine.api.datastore.Key;

/**
 * Represents a persistable object
 * 
 * @author randy
 */
public interface TDPersistable{
	/**
	 * Fetches the date this object was created
	 * @return the date this object was created
	 */
	Date getDateCreated();

	/**
	 * Fetches the date this object was last modified
	 * @return the date this object was last modified
	 */
	Date getDateModified();
	
	/**
	 * Sets the date this object was modified
	 * @param dateModified the date this object was modified
	 */
	void setDateModified(Date dateModified);

	/**
	 * Fetches the {@link Key} to the {@link TDUser} that created this object
	 * @return the {@link Key} to the {@link TDUser} that created this object
	 */
	Key getCreator();
	
	/**
	 * Sets the {@link Key} of the {@link TDUser} that last edited this object
	 * @param lastEditor the {@link Key} to the {@link TDUser} that last edited this object
	 */
	void setLastEditor(Key lastEditor);
	
	/**
	 * Fetches the {@link Key} of the {@link TDUser} that last edited this object
	 * @return the {@link Key} of the {@link TDUser} that last edited this object
	 */
	Key getLastEditor();
}