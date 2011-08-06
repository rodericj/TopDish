package com.topdish.data;

import java.util.List;

import com.google.gson.Gson;
import com.topdish.utils.TDUtils;

public class Restaurant {

	/**
	 * Restaurant ID
	 */
	public Long id;

	/**
	 * Name
	 */
	public String name;

	/**
	 * First Address Line
	 */
	public String addressLine1;

	/**
	 * Second Address Line
	 */
	public String addressLine2;

	/**
	 * City
	 */
	public String city;

	/**
	 * State
	 */
	public String state;

	/**
	 * Neighborhood
	 */
	public String neighborhood;

	/**
	 * Latitude
	 */
	public Double latitude;

	/**
	 * Longitude
	 */
	public Double longitude;

	/**
	 * Phone number
	 */
	public String phone;

	/**
	 * Number of dishes
	 */
	public Integer numDishes;

	/**
	 * Associated Photo URL
	 */
	public String photoURL;

	/**
	 * List of Dishes
	 */
	public List<Dish> dishes;

	/**
	 * Default Constructor <br>
	 * Note: Required to use {@link Gson}
	 */
	public Restaurant() {
	}

	/**
	 * @param id
	 * @param name
	 * @param addressLine1
	 * @param addressLine2
	 * @param city
	 * @param state
	 * @param neighborhood
	 * @param latitude
	 * @param longitude
	 * @param phone
	 * @param numDishes
	 * @param photoURL
	 * @param dishes
	 */
	public Restaurant(Long id, String name, String addressLine1, String addressLine2, String city, String state,
			String neighborhood, Double latitude, Double longitude, String phone, Integer numDishes, String photoURL,
			List<Dish> dishes) {
		super();
		this.id = id;
		this.name = TDUtils.stringDecode(name);
		this.addressLine1 = addressLine1;
		this.addressLine2 = addressLine2;
		this.city = city;
		this.state = state;
		this.neighborhood = neighborhood;
		this.latitude = latitude;
		this.longitude = longitude;
		this.phone = phone;
		this.numDishes = numDishes;
		this.photoURL = photoURL;
		this.dishes = dishes;
	}

	@Override
	public String toString() {
		return "Restaurant [addressLine1=" + addressLine1 + ", addressLine2=" + addressLine2 + ", city=" + city
				+ ", dishes=" + dishes + ", id=" + id + ", latitude=" + latitude + ", longitude=" + longitude
				+ ", name=" + name + ", neighborhood=" + neighborhood + ", numDishes=" + numDishes + ", phone=" + phone
				+ ", photoURL=" + photoURL + ", state=" + state + "]";
	}

}
