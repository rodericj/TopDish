package com.topdish.jdo;

import java.io.Serializable;

import com.beoui.geocell.model.Point;

/**
 * {@link TDPoint} is an extension of {@link Point} to add other fields such as
 * Address, City, and State
 * 
 * @author Salil
 * 
 */
public class TDPoint extends Point implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -6299086309151539724L;

	/**
	 * The address associated with this point
	 */
	private String address;

	/**
	 * The city
	 */
	private String city;

	/**
	 * The state
	 */
	private String state;

	/**
	 * Default constructor
	 */
	public TDPoint() {
	}

	/**
	 * Create the {@link TDPoint}
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
		this.city = "";
		this.state = "";
	}

	/**
	 * Create the {@link TDPoint}
	 * 
	 * @param lat
	 *            - latitude
	 * @param lon
	 *            - longitude
	 * @param address
	 *            - full qualified address
	 * @param city
	 *            - the city
	 * @param state
	 *            - the state
	 */
	public TDPoint(double lat, double lon, String address, String city, String state) {
		super(lat, lon);
		this.address = address;
		this.city = city;
		this.state = state;
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
	 * Get this as a {@link Point}
	 * 
	 * @return the {@link Point} representation
	 */
	public Point getPoint() {
		return this;
	}

	/**
	 * Get the city
	 * 
	 * @return the city
	 */
	public String getCity() {
		return city;
	}

	/**
	 * Get the state
	 * 
	 * @return the state
	 */
	public String getState() {
		return state;
	}

	@Override
	public String toString() {
		return "LAT : " + this.getLat() + "\nLON : " + this.getLon() + "\nADDRESS : "
				+ this.address + "\nCITY : " + this.city + "\nSTATE : " + this.state;
	}

	@Override
	public boolean equals(Object obj) {
		final TDPoint p = (TDPoint) obj;
		return super.equals(p.getPoint()) && p.getAddress().equals(this.address)
				&& p.getCity().equals(this.city) && p.getState().equals(this.state);
	}

}
