package com.topdish.util;

import java.util.List;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Tag;

public final class BatchDishUpdate {

	/**
	 * Update the city field of all {@link Dish}es belonging to a
	 * {@link Restaurant}
	 * 
	 * @param city
	 *            {@link String} city name to set
	 * @param restKey
	 *            {@link Key} of the {@link Restaurant} of which all of the
	 *            {@link Dish}es should be modified
	 */
	public static void setCity(String city, Key restKey) {
		for (Dish d : TDQueryUtils.getDishesByRestaurant(restKey)) {
			d.setCity(city);
			Datastore.put(d);
		}
	}

	/**
	 * Update the state field of all {@link Dish}es belonging to a
	 * {@link Restaurant}
	 * 
	 * @param state
	 *            {@link String} state name to set
	 * @param restKey
	 *            {@link Key} of the {@link Restaurant} of which all of the
	 *            {@link Dish}es should be modified
	 */
	public static void setState(String state, Key restKey) {
		for (Dish d : TDQueryUtils.getDishesByRestaurant(restKey)) {
			d.setState(state);
			Datastore.put(d);
		}
	}

	/**
	 * Update the neighborhood field of all {@link Dish}es belonging to a
	 * {@link Restaurant}
	 * 
	 * @param city
	 *            {@link String} neighborhood name to set
	 * @param restKey
	 *            {@link Key} of the {@link Restaurant} of which all of the
	 *            {@link Dish}es should be modified
	 */
	public static void setNeighborhood(String neighborhood, Key restKey) {
		for (Dish d : TDQueryUtils.getDishesByRestaurant(restKey)) {
			d.setNeighborhood(neighborhood);
			Datastore.put(d);
		}
	}

	/**
	 * Update the location of all {@link Dish}es belonging to a
	 * {@link Restaurant}
	 * 
	 * @param latitude
	 *            {@link double} latitude to set
	 * @param longitude
	 *            {@link double} longitude to set
	 * @param geoCells
	 *            {@link List} of {@link String} geocells to set
	 * @param restKey
	 *            {@link Key} of the {@link Restaurant} of which all of the
	 *            {@link Dish}es should be modified
	 */
	public static void setLocation(double latitude, double longitude, List<String> geoCells,
			Key restKey) {
		for (Dish d : TDQueryUtils.getDishesByRestaurant(restKey)) {
			d.setLocation(latitude, longitude, geoCells);
			Datastore.put(d);
		}
	}

	/**
	 * Update the restaurant name field of all {@link Dish}es belonging to a
	 * {@link Restaurant}
	 * 
	 * @param restName
	 *            {@link String} restaurant name to set
	 * @param restKey
	 *            {@link Key} of the {@link Restaurant} of which all of the
	 *            {@link Dish}es should be modified
	 */
	public static void setRestaurantName(String restName, Key restKey) {
		for (Dish d : TDQueryUtils.getDishesByRestaurant(restKey)) {
			d.setRestaurantName(restName);
			Datastore.put(d);
		}
	}

	/**
	 * Update the cuisine tag of all {@link Dish}es belonging to a
	 * {@link Restaurant}
	 * 
	 * @param cuisine
	 *            {@link Key} of the {@link Tag} to set
	 * @param restKey
	 *            {@link Key} of the {@link Restaurant} of which all of the
	 *            {@link Dish}es should be modified
	 */
	public static void setCuisine(Key cuisine, Key restKey) {
		for (Dish d : TDQueryUtils.getDishesByRestaurant(restKey)) {
			// Remove old Cuisine tag
			if (null != d.getCuisine())
				d.removeTag(d.getCuisine());
			d.setCuisine(cuisine);
			Datastore.put(d);
		}
	}
}
