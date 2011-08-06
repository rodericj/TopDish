package com.topdish.util;

import java.util.Iterator;
import java.util.Set;

import uk.ac.shef.wit.simmetrics.similaritymetrics.Levenshtein;

import com.topdish.jdo.Restaurant;

public class DuplicateChecker {

	/**
	 * Check if two {@link Restaurant}s are the same <br>
	 * Note: Compares name and addressLine1 currently.
	 * 
	 * @param first
	 *            - first {@link Restaurant}
	 * @param second
	 *            - second {@link Restaurant}
	 * @return true if they are equal, false otherwise
	 */
	public static boolean checkDuplicate(Restaurant first, Restaurant second) {
		final Levenshtein leve = new Levenshtein();

		// Current Levenshtein value
		float value = leve.getSimilarity(first.getName(), second.getName());

		// If name is greater than half, check address
		if (value > .5) {

			value = leve.getSimilarity(first.getAddressLine1(), second
					.getAddressLine1());

			// If address is more than half, do not add this one
			if (value > .8)
				return true;

		}

		return false;

	}

	/**
	 * Check if a {@link Restaurant} exists in a {@link Set} of
	 * {@link Restaurant}s
	 * 
	 * @param toCheck
	 *            - {@link Restaurant} to check
	 * @param restaurants
	 *            - {@link Set} of {@link Restaurant}s
	 * @return true if there is a duplicate, false otherwise
	 */
	public static boolean checkDuplicate(Restaurant toCheck,
			Set<Restaurant> restaurants) {
		final Iterator<Restaurant> iterator = restaurants.iterator();
		while (iterator.hasNext())
			if (checkDuplicate(toCheck, iterator.next()))
				return true;
		return false;
	}

	/**
	 * Get a duplicate {@link Restaurant} in a {@link Set} of {@link Restaurant}
	 * s
	 * 
	 * @param toCheck
	 *            - {@link Restaurant} to find duplicate of
	 * @param restaurants
	 *            - {@link Set} of {@link Restaurant}s
	 * @return the reference to the {@link Restaurant} in the {@link Set} or
	 *         <code>null</code>
	 */
	public static Restaurant getDuplicate(Restaurant toCheck,
			Set<Restaurant> restaurants) {

		final Iterator<Restaurant> iterator = restaurants.iterator();
		while (iterator.hasNext()) {
			Restaurant toReturn = iterator.next();
			if (checkDuplicate(toCheck, toReturn))
				return toReturn;
		}

		return null;

	}

}
