package com.topdish.jdo;

import com.beoui.geocell.model.Point;

/**
 * Point to handle a
 * 
 * @author Salil
 * 
 */
public class TDPoint extends Point {

	/**
	 * The address associated with this point
	 */
	private final String address;

	/**
	 * Create the Point
	 * 
	 * @param lat
	 *            - latitude
	 * @param lon
	 *            - longitude
	 * @param address
	 *            - fully qualified address
	 */
	public TDPoint(double lat, double lon, String address) {
		super(lat, lon);
		this.address = address;
	}

	/**
	 * Convert a Point to a TD Point
	 * 
	 * @param pt
	 *            - the point
	 * @param address
	 *            - the current address
	 */
	public TDPoint(Point pt, String address) {
		this(pt.getLat(), pt.getLon(), address);
	}

	/**
	 * Get the address
	 * 
	 * @return the address
	 */
	public String getAddress() {
		return address;
	}

	/**
	 * Get this as a Point
	 * 
	 * @return the Point representation
	 */
	public Point getPoint() {
		return this;
	}

}
