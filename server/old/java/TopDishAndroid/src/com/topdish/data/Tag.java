package com.topdish.data;

import com.google.gson.Gson;

/**
 * Tag Class
 * 
 * @author Salil
 * 
 */
public class Tag implements Comparable<Tag> {

	/**
	 * General Name = "General"
	 */
	public final static String GENERAL_NAME = "General";

	/**
	 * Cusine Name = "Cuisine"
	 */
	public final static String CUISINE_NAME = "Cuisine";

	/**
	 * Price Name = "Price"
	 */
	public final static String PRICE_NAME = "Price";

	/**
	 * Lifestyle Name = "Lifestyle"
	 */
	public final static String LIFESTYLE_NAME = "Lifestyle";

	/**
	 * Allergen Name = "Allergen"
	 */
	public final static String ALLERGEN_NAME = "Allergen";

	/**
	 * Ingredient Name = "Ingredient"
	 */
	public final static String INGREDIENT_NAME = "Ingredient";

	/**
	 * Meal Type Name = "Meal Type"
	 */
	public final static String MEALTYPE_NAME = "Meal Type";

	/**
	 * Tag ID
	 */
	public long id;

	/**
	 * Name
	 */
	public String name;

	/**
	 * Type <br>
	 * Example: Meal Type, Price, etc
	 */
	public String type;

	/**
	 * Order to display
	 */
	public long order;

	/**
	 * Default Constructor <br>
	 * Note: Required to use {@link Gson}
	 */
	public Tag() {

	}

	/**
	 * Constructor to build a {@link Tag}
	 * 
	 * @param id
	 *            - id of the tag
	 * @param name
	 *            - name of the tag
	 * @param type
	 *            - id type
	 * @param order
	 *            - the order to display
	 */
	public Tag(long id, String name, String type, long order) {
		super();
		this.id = id;
		this.name = name;
		this.type = type;
		this.order = order;
	}

	@Override
	public int compareTo(final Tag another) {

		return (this.order < another.order ? -1
				: (this.order > another.order ? 1 : 0));

	}

	@Override
	public boolean equals(Object o) {
		Tag incoming = (Tag) o;
		return this.id == incoming.id;
	}

	@Override
	public String toString() {
		return this.name;
	}
}
