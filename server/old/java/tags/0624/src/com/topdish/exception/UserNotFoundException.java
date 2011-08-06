package com.topdish.exception;

/**
 * An exception thrown when a user is not found in the datastore
 * 
 * @author ralmand (Randy Almand)
 */
public class UserNotFoundException extends Exception{
	private static final long serialVersionUID = -435147642777113955L;
	
	public UserNotFoundException() {
		super("User was not found.");
	}

}
