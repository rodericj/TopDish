package com.topdish;

import com.topdish.jdo.TDPoint;

/**
 * Class to reverse geocode given certain parameters
 * 
 * @author Salil (salil@topdish.com)
 * 
 */
public class GeoUtils {

	/**
	 * Reverse GeoCode
	 * 
	 * @param ipAddress
	 *            -to reverse code
	 * @return the point as a {@link TDPoint}
	 */
	public static TDPoint reverseIP(String ipAddress) {

		return new TDPoint(37.77825, -122.42555, "San Francisco CA");
	}

	/**
	 * Reverse Address
	 * 
	 * @param streetAddress
	 *            - the street level address
	 * @return the point as a {@link TDPoint}
	 */
	public static TDPoint reverseAddress(String streetAddress) {
		return new TDPoint(37.77825, -122.42555, streetAddress);
	}

	/**
	 * Reverse a Lat Lon
	 * 
	 * @param lat
	 *            - latitude
	 * @param lon
	 *            - longitude
	 * @return the point as {@link TDPoint}
	 */
	public static TDPoint reverseLatLon(double lat, double lon) {
		return new TDPoint(lat, lon, "San Francisco CA");
	}

}
