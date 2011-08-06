package com.topdish.jdo;

import java.util.Date;
import java.util.Set;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.NotPersistent;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.repackaged.org.json.JSONObject;
import com.topdish.exception.CuisineCannotHaveParentException;
import com.topdish.search.AbstractSearch;
import com.topdish.util.ParentIsSelfException;
import com.topdish.util.TagUtils;

/**
 * Tags associated with a Dish
 * 
 * @author Randy
 * 
 */
@PersistenceCapable
public class Tag implements TDPersistable {

	/**
	 * General Types <br>
	 * Examples: Spicy, Greasy, Tacos, Smoothie, Savory, etc.
	 */
	public final static int TYPE_GENERAL = 0;

	/**
	 * Cuisine Types <br>
	 * Examples: American, French, Indonesian, Japanese, New American, etc.
	 */
	public final static int TYPE_CUISINE = 1;

	/**
	 * Price Types <br>
	 * Examples: $, $$, $$$, $$$
	 */
	public final static int TYPE_PRICE = 2;

	/**
	 * Lifestyle Types <br>
	 * Examples: vegetarian, vegan, kosher, etc.
	 */
	@Persistent
	public final static int TYPE_LIFESTYLE = 3;

	/**
	 * Allergen Types <br>
	 * Examples: shellfish, peanuts, gluten, eggs, fish, etc.
	 */
	public final static int TYPE_ALLERGEN = 4;

	/**
	 * Ingredient Types <br>
	 * Examples: eggs, bacon, sourdough, bread, angus beef, romaine lettuce,
	 * etc.
	 */
	public final static int TYPE_INGREDIENT = 5;

	/**
	 * MealType Tags <br>
	 * Examples: breakfast, lunch, dinner, snack, appetizer, dessert, etc.
	 */
	public final static int TYPE_MEALTYPE = 6;

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

	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	@Persistent
	private Key parentTag;

	@Persistent
	private String name;

	@Persistent
	private String description;

	@Persistent
	private int type = TYPE_GENERAL; // set default value since null causes
	// issues

	@Persistent
	private Date dateCreated;

	@Persistent
	private Date dateModified;

	@Persistent
	private Key creator;

	@Persistent
	private Key lastEditor;

	@Persistent
	private transient Set<String> searchTerms;

	@Persistent
	private Integer manualOrder;
	
	@NotPersistent
	private String creatorName;
	
	@NotPersistent
	private String typeString;

	/**
	 * Constructor for a new tag
	 * 
	 * @param parentTag
	 * @param name
	 * @param description
	 * @param dateCreated
	 * @param creator
	 * @throws CuisineCannotHaveParentException
	 * @throws ParentIsSelfException
	 */
	public Tag(Key parentTag, String name, String description, int type,
			Date dateCreated, Key creator)
			throws CuisineCannotHaveParentException {

		if (parentTag != null && type == TYPE_CUISINE) {
			throw new CuisineCannotHaveParentException();
		}

		this.parentTag = parentTag;
		this.name = name;
		this.description = description;
		this.type = type;
		this.dateCreated = dateCreated;
		this.creator = creator;
		this.searchTerms = AbstractSearch.getSearchTerms(this.name);
		this.manualOrder = 0;
	}

	/**
	 * Default constructor <br />
	 * 
	 * Note: do not use for creating a Tag object.  Specifically created for generic operations.
	 */
	public Tag() {}

	public Key getParentTag() {
		return parentTag;
	}

	public void setParentTag(Key parentTag) throws ParentIsSelfException,
			CuisineCannotHaveParentException {
		if (parentTag != null && parentTag.getId() == this.key.getId()) {
			throw new ParentIsSelfException();
		} else if (parentTag != null && this.type == TYPE_CUISINE) {
			throw new CuisineCannotHaveParentException();
		} else {
			this.parentTag = parentTag;
		}
	}

	public Integer getManualOrder() {
		if (this.manualOrder != null) {
			return this.manualOrder;
		} else {
			return 0;
		}
	}

	public void setManualOrder(int manualOrder) {
		this.manualOrder = manualOrder;
	}

	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
		this.searchTerms = AbstractSearch.getSearchTerms(this.name);
	}

	public String getDescription() {
		return this.description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Integer getType() {
		return this.type;
	}

	public void setType(int type) throws CuisineCannotHaveParentException {
		if (this.parentTag != null && type == TYPE_CUISINE) {
			throw new CuisineCannotHaveParentException();
		} else {
			this.type = type;
		}
	}

	public Date getDateCreated() {
		return this.dateCreated;
	}

	public Date getDateModified() {
		return this.dateModified;
	}

	public void setDateModified(Date dateModified) {
		this.dateModified = dateModified;
	}

	public Key getCreator() {
		return this.creator;
	}

	public Key getLastEditor() {
		return this.lastEditor;
	}

	public void setLastEditor(Key lastEditor) {
		this.lastEditor = lastEditor;
	}

	public Key getKey() {
		return this.key;
	}

	public Set<String> getSearchTerms() {
		return this.searchTerms;
	}

	public String getTagTypeName() {
		switch (this.type) {
		case TYPE_ALLERGEN:
			return ALLERGEN_NAME;
		case TYPE_CUISINE:
			return CUISINE_NAME;
		case TYPE_GENERAL:
			return GENERAL_NAME;
		case TYPE_INGREDIENT:
			return INGREDIENT_NAME;
		case TYPE_LIFESTYLE:
			return LIFESTYLE_NAME;
		case TYPE_MEALTYPE:
			return MEALTYPE_NAME;
		case TYPE_PRICE:
			return PRICE_NAME;
		default:
			return "";
		}
	}

	/**
	 * Get Tag as JSON Object with limited information <br>
	 * Note: For mobile use
	 * 
	 * @return Tag with Key, Description, and Manual Order as JSON Object
	 */
	public JSONObject toJSONLite() {
		JSONObject jsonObj = new JSONObject();
		try {

			jsonObj.put(TagUtils.KEY, key.toString()).put(TagUtils.NAME, name)
					.put(TagUtils.DESCRIPTION, description).put(
							TagUtils.MANUAL_ORDER, manualOrder);

		} catch (Exception e) {
			e.printStackTrace();
		}
		return jsonObj;
	}

	public String getCreatorName() {
		return creatorName;
	}

	public void setCreatorName(String creatorName) {
		this.creatorName = creatorName;
	}

	public String getTypeString() {
		return typeString;
	}

	public void setTypeString(String typeString) {
		this.typeString = typeString;
	}
	
	
	
}