package com.topdish.api;

import java.io.IOException;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.repackaged.org.json.JSONArray;
import com.google.appengine.repackaged.org.json.JSONObject;
import com.google.gson.Gson;
import com.topdish.api.jdo.TagLite;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;

/**
 * Class to feed initial data to the Mobile Phone <br>
 * To choose which {@link Tag}s are sent to the phone, simply add additional
 * {@link Tag} static integers to the "desiredTags" array <br>
 * Returns a {@link JSONArray} of {@link TagLite}s
 * 
 * @author Salil
 * 
 */
public class MobileInitServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 7130022365453837066L;

	/**
	 * DEBUG
	 */
	private static final boolean DEBUG = true;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// Get Persistence Manager
		PersistenceManager pm = PMF.get().getPersistenceManager();

		// All desired Tags. To add more tags, look at the Tag file and check
		// the static int references
		final int[] desiredTags = new int[] { Tag.TYPE_MEALTYPE,
				Tag.TYPE_PRICE, Tag.TYPE_LIFESTYLE, Tag.TYPE_ALLERGEN };

		// Array to be printed
		final JSONArray array = new JSONArray();

		// Traverse list of tag types
		for (final int i : desiredTags) {
			// Get the current list
			final List<Tag> curList = getTag(pm, i);

			// Convert each one returned to a JSON object
			for (final Tag curTag : curList)
				try {
					// Create GSON and generate JSON as String
					final String jsonStr = new Gson()
							.toJson(new TagLite(curTag));

					if (DEBUG)
						System.out.println("AS JSON STR: " + jsonStr);

					// Convert o JSON Object
					final JSONObject tagJson = new JSONObject(jsonStr);

					if (DEBUG)
						System.out.println("AS JSON: " + tagJson.toString());

					// Add to Array
					array.put(tagJson);

				} catch (Exception e) {
					e.printStackTrace();
				}
		}

		if (DEBUG)
			System.out.println("Array: " + array.toString());

		// Write to user
		resp.getOutputStream().print(array.toString());

	}

	/**
	 * Get {@link Tag}s
	 * 
	 * @param pm
	 *            - current persistence manager
	 * @param typeParam
	 *            - type of Tag get from static ints in {@link Tag} class
	 * @return a list of Tags
	 */
	@SuppressWarnings("unchecked")
	private List<Tag> getTag(PersistenceManager pm, final int typeParam) {

		// Query
		final Query query = pm.newQuery(Tag.class);

		// Set filter requirements to search for type
		query.setFilter("type == typeParam");
		query.declareParameters("int typeParam");

		// Get Manual Order
		query.setOrdering("manualOrder ASC");

		// Get Cuisens
		return (List<Tag>) query.execute(typeParam);
	}
}
