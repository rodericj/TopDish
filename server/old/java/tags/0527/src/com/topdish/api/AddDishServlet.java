package com.topdish.api;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.DishConstants;
import com.topdish.api.util.RestaurantConstants;
import com.topdish.api.util.TagConstants;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Tag;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;

/**
 * Add a Dish Servlet for API
 * 
 * @author Salil
 * 
 */
public class AddDishServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -7879443331990585310L;

	/**
	 * DEBUG
	 */
	private static final boolean DEBUG = true;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		try {
			if (DEBUG)
				System.out.println("Start Adding Dish");

			// Get Posted Data
			final String name = req.getParameter(APIConstants.NAME);
			final String description = (null != req.getParameter(APIConstants.DESCRIPTION) ? req
					.getParameter(APIConstants.DESCRIPTION) : new String());
			final String restuarantId = req.getParameter(RestaurantConstants.RESTAURANT_ID);
			final String tags = req.getParameter(TagConstants.TAGS);
			final String apiKey = req.getParameter(APIConstants.API_KEY);
			final Set<Key> tagList = new HashSet<Key>();

			if (DEBUG) {
				System.out.println(RestaurantConstants.RESTAURANT_ID + "\t:\t" + restuarantId);
				System.out.println(TagConstants.TAGS + "\t:\t" + tags);
				System.out.println(APIConstants.API_KEY + "\t:\t" + apiKey);
				System.out.println(APIConstants.NAME + "\t:\t" + name);
				System.out.println(APIConstants.DESCRIPTION + "\t:\t" + description);
			}

			// Check for tags passed
			if (null != tags && !tags.isEmpty()) {
				if (DEBUG) {
					System.out.println("TAGS AS STRING: " + tags);
					System.out.println("TAGS BROKEN UP : " + Arrays.asList(tags.split(",")));
				}
				// Get all related tags
				final Set<Key> tagKeys = new HashSet<Key>();
				final String[] tagKeyStrings = tags.split(",");

				for (String s : tagKeyStrings) {
					try {
						tagKeys.add(KeyFactory.createKey(Tag.class.getSimpleName(),
								Long.parseLong(s)));
					} catch (Exception e) {
						e.printStackTrace();
					}
				}

				tagList.addAll(tagKeys);

				if (DEBUG)
					System.out.println("TAGS FOUND: " + tagList);
			}

			// Pull restaurant from db
			final Restaurant restaurant = Datastore.get(KeyFactory.createKey(
					Restaurant.class.getSimpleName(), Long.parseLong(restuarantId)));

			if (null == restaurant && DEBUG)
				System.err.println("No Restaurant with id " + restuarantId);

			// Set the user and check that it is not null
			final Key userKey = TDQueryUtils.getUserKeyByAPIKey(apiKey);

			if (null != userKey) {

				// Create Dish
				final Dish dish = new Dish(name, description, restaurant, userKey, tagList);

				// Make persistent
				Datastore.put(dish);

				if (DEBUG)
					System.err.println("Succesfully added [" + dish.getKeyString() + "] "
							+ dish.getName() + " to Restaurant " + restaurant.getName());

				restaurant.addDish();
				Datastore.put(restaurant);

				final String json = APIUtils.generateJSONSuccessMessage(new JSONObject().put(
						DishConstants.DISH_ID, dish.getKey().getId()));

				if (DEBUG)
					System.out.println("response: " + json);

				// Return key to user
				resp.getWriter().write(json);
			} else {
				resp.getWriter().write(APIUtils.generateJSONFailureMessage("User not found."));
				System.err.println("User is null!");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
