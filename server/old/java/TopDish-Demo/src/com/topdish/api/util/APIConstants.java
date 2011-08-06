package com.topdish.api.util;

import javax.servlet.http.HttpServlet;

import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Tag;

public class APIConstants {
	
	/**
	 * Return Code = "rc"
	 */
	public static final String RETURN_CODE = "rc";

	/**
	 * Return Message = "message"
	 */
	public static final String RETURN_MESSAGE = "message";

	/**
	 * Return Success Code = 0
	 */
	public static final int RETURN_SUCCESS = 0;

	/**
	 * Return Failure Code = 1
	 */
	public static final int RETURN_FAILURE = 1;

	/**
	 * API Key Text = "apiKey"
	 */
	public static final String API_KEY = "apiKey";

	/**
	 * Name = "name" <br>
	 * Note: Used for {@link Dish}, {@link Tag}, or {@link Restaurant} name
	 */
	public static final String NAME = "name";

	/**
	 * Description = "description" <br>
	 * Note: Used for {@link Dish} and {@link Tag}
	 */
	public static final String DESCRIPTION = "description";

	/**
	 * URL = "url"
	 */
	public static final String URL = "url";
	
	/**
	 * ID Array = "id[]" <br>
	 * Note: Used for Arrays of IDs for {@link HttpServlet}sF
	 */
	public static final String ID_ARRAY = "id[]";
	
	/**
	 * Latitude = "lat"
	 */
	public static final String LAT = "lat";
	
	/**
	 * Longitude = "lng"
	 */
	public static final String LNG = "lng";
	
	/**
	 * Distance = "distance"
	 */
	public static final String DISTANCE = "distance";
	
	/**
	 * Limit = "limit"
	 */
	public static final String LIMIT = "limit";
	
	/**
	 * Query = "q"
	 */
	public static final String QUERY = "q";

}