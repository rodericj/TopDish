package com.topdish.exception;
/**
 * An exception thrown when a tag is set as a cuisine and a parent is added
 * or when a cuisine has a parent and is set as a cuisine.
 * 
 * @author ralmand (Randy Almand)
 */
public class CuisineCannotHaveParentException extends Exception{
	private static final long serialVersionUID = -8860474547777882662L;

}
