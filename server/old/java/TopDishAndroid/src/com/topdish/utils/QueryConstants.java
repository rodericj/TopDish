package com.topdish.utils;

/**
 * Class to handle Query Constants
 * 
 * @author Salil
 * 
 */
public class QueryConstants {

	/**
	 * Max Distance
	 */
	public static final int MAX_DISTANCE = 32 * 1000;

	/**
	 * Seperator between entries
	 */
	public static final String AND = "&";

	/**
	 * Key EQUALS Value
	 */
	public static final String EQUALS = "=";

	/**
	 * Latitude = "lat"
	 */
	public static final String LATITUDE = "lat";

	/**
	 * Longitude = "lng"
	 */
	public static final String LONGITUDE = "lng";

	/**
	 * Limit = "limit"
	 */
	public static final String LIMIT = "limit";

	/**
	 * Query = "q"
	 */
	public static final String QUERY = "q";

	/**
	 * Distance = "distance"
	 */
	public static final String DISTANCE = "distance";

	/**
	 * Foreign = "foreign"
	 */
	public static final String FOREIGN = "foreign";

	/**
	 * Create a url entity given constant and value
	 * 
	 * @param key
	 *            - the entry key
	 * @param value
	 *            - the entry value
	 * @param and
	 *            - is a preceding "&" required?
	 * @return the formatted string
	 */
	public static String formed(String key, String value, boolean and) {

		final String toReturn = key + EQUALS + value;

		return (and ? AND + toReturn : toReturn);
	}

	/**
	 * Create a URL entity given constant and value, assumes true for AND
	 * 
	 * @param key
	 *            - the entry key
	 * @param value
	 *            - the entry value
	 * @return the formatted string
	 */
	public static String formed(String key, String value) {
		return formed(key, value, true);
	}

	/**
	 * Create a URL entity given constant and value, assumes true for AND
	 * 
	 * @param key
	 *            - the entry key
	 * @param value
	 *            - the entry value
	 * @return the formatted string
	 */
	public static String formed(String key, boolean value) {
		return formed(key, String.valueOf(value));
	}

	/**
	 * 
	 * Create a URL entity given constant and value, assumes true for AND
	 * 
	 * @param key
	 *            - the entry key
	 * @param value
	 *            - the entry value
	 * @return the formatted string
	 */
	public static String formed(String key, double value) {
		return formed(key, String.valueOf(value));
	}

	/**
	 * Create a URL entity given constant and value, assumes true for AND <br>
	 * <b>Note:</b> Use {@link #formed(String, String, boolean)} if you do not
	 * want a AND
	 * 
	 * @param key
	 *            - the entry key
	 * @param value
	 *            - the entry value
	 * @return the formatted string
	 */
	public static String formed(String key, int value) {
		return formed(key, String.valueOf(value));
	}

	/**
	 * Clean the Distance based on the {@link #MAX_DISTANCE}
	 * 
	 * @param distance
	 *            - the distance in mi
	 * @return the distance as KM or {@link #MAX_DISTANCE}
	 */
	public static int cleanDistance(int distance) {
		return (QueryConstants.MAX_DISTANCE > (distance * 1.6) ? distance : QueryConstants.MAX_DISTANCE);
	}

}
