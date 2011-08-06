package com.topdish.utils;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;

import android.util.Log;

import com.google.gson.Gson;
import com.topdish.data.Dish;

/**
 * Utilies to support Dish Pojo
 * 
 * @author Salil
 * 
 */
public class DishUtils {

	/**
	 * DEBUG Tag
	 */
	public static final String TAG = "DishUtils";

	// public static final String ID = "id";
	// public static final String NAME = "name";
	// public static final String DESCRIPTION = "description";
	// public static final String PHOTO_URL = "photoURL";
	// public static final String NEGATIVE_REVIEWS = "negReviews";
	// public static final String POSITIVE_REVIEWS = "posReviews";
	// public static final String LATITUDE = "latitude";
	// public static final String LONGITUDE = "longitude";
	// public static final String RESTAURANT_ID = "restaurantID";
	// public static final String RESTAURANT_NAME = "restaurantName";

	/**
	 * Create a new Dish from a JSON String
	 * 
	 * @param dishAsJSONString
	 *            - Dish Object as JSON String
	 * @return a new Dish with fields populated, or null if parse fails
	 */
	public static Dish createFromJSON(final String dishAsJSONString) {

		try {
			return createFromJSON(new JSONObject(dishAsJSONString));
		} catch (Exception e) {
			e.printStackTrace();
			Log.d(TAG, "Failed to convert to JSON Object");
		}
		return null;

	}

	/**
	 * Convert {@link JSONObject} to {@link Dish}
	 * 
	 * @param dishAsJSONObject
	 *            - {@link JSONObject} representation of the {@link Dish}
	 * @return the {@link Dish}
	 */
	public static Dish createFromJSON(final JSONObject dishAsJSONObject) {
		return new Gson().fromJson(dishAsJSONObject.toString(), Dish.class);
	}

	/**
	 * Convert JSON Array of Dishes to List of Dishes
	 * 
	 * @param jsonArray
	 *            - dishes as JSON Array
	 * @return Dishes as List
	 */
	public static Map<Long, Dish> convertJSONArrayToDishArray(final JSONArray jsonArray) {
		final Map<Long, Dish> toBeReturned = new HashMap<Long, Dish>();

		// Traverse returned dishes
		for (int i = 0; i < jsonArray.length(); i++) {
			try {
				final JSONObject curObj = jsonArray.getJSONObject(i);
				final Dish curDish = createFromJSON(curObj);

				// Check null
				if (null != curDish) {
					curDish.name = TDUtils.stringDecode(curDish.name);
					curDish.restaurantName = TDUtils.stringDecode(curDish.restaurantName);
					toBeReturned.put(curDish.id, curDish);
				} else
					Log.d(TAG, "Skipped Obejct " + i + " as it is null");

			} catch (Exception e) {
				e.printStackTrace();
				Log.d(TAG, "Skipped Object: " + i);
			}
		}

		return toBeReturned;
	}

	/**
	 * Convert JSON Array of Dishes to List of Dishes
	 * 
	 * @param jsonArray
	 *            - dishes as JSON Array as String
	 * @return Dishes as List
	 */
	public static Map<Long, Dish> convertJSONArrayToDishArray(String jsonArray) {
		try {
			return convertJSONArrayToDishArray(new JSONArray(jsonArray));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new HashMap<Long, Dish>();
	}

}
