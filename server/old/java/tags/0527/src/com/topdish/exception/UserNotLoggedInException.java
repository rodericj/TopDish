package com.topdish.exception;

/**
 * An exception thrown when a user is not logged in
 * 
 * @author ralmand (Randy Almand)
 */
public class UserNotLoggedInException extends Exception {
	private static final long serialVersionUID = 8471276675467836196L;

	public UserNotLoggedInException() {
		super("User was not logged in.");
	}
}