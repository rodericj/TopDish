package com.topdish.api;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.google.appengine.api.datastore.Key;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.DishConstants;
import com.topdish.api.util.RestaurantConstants;
import com.topdish.api.util.TagConstants;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;
import com.topdish.util.TagUtils;

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

		PersistenceManager pm = PMF.get().getPersistenceManager();

		try {
			if (DEBUG)
				System.out.println("Start Adding Dish");

			// Get Posted Data
			final String name = req.getParameter(APIConstants.NAME);
			final String description = (null != req
					.getParameter(APIConstants.DESCRIPTION) ? req
					.getParameter(APIConstants.DESCRIPTION) : new String());
			final String restuarantId = req
					.getParameter(RestaurantConstants.RESTAURANT_ID);
			final String tags = req.getParameter(TagConstants.TAGS);
			final String apiKey = req.getParameter(APIConstants.API_KEY);
			final List<Key> tagList = new ArrayList<Key>();

			if (DEBUG) {
				System.out.println(RestaurantConstants.RESTAURANT_ID + "\t:\t"
						+ restuarantId);
				System.out.println(TagConstants.TAGS + "\t:\t" + tags);
				System.out.println(APIConstants.API_KEY + "\t:\t" + apiKey);
				System.out.println(APIConstants.NAME + "\t:\t" + name);
				System.out.println(APIConstants.DESCRIPTION + "\t:\t"
						+ description);
			}

			// Check for tags passed
			if (null != tags && !tags.isEmpty()) {
				if (DEBUG) {
					System.out.println("TAGS AS STRING: " + tags);
					System.out.println("TAGS BROKEN UP : "
							+ Arrays.asList(tags.split(",")));
				}
				// Get all related tags

				tagList.addAll(TagUtils.getTagKeysById(tags.split(",")));
				if (DEBUG)
					System.out.println("TAGS FOUND: " + tagList);
			}

			// Pull restaurant from db
			final Restaurant restaurant = pm.getObjectById(Restaurant.class,
					Long.parseLong(restuarantId));

			if (null == restaurant && DEBUG)
				System.err.println("No Restaurant with id " + restuarantId);

			// Set the user and check that it is not null
			final TDUser user = APIUtils
					.getUserAssociatedWithApiKey(pm, apiKey);

			if (null != user) {

				// Create Dish
				final Dish dish = new Dish(name, description, restaurant,
						new Date(), user.getKey(), tagList);

				// Make persistent
				pm.makePersistent(dish);

				if (DEBUG)
					System.err.println("Succesfully added ["
							+ dish.getKeyString() + "] " + dish.getName()
							+ " to Restaurant " + restaurant.getName());

				restaurant.addDish(dish.getKey());
				pm.makePersistent(restaurant);

				final String json = APIUtils
						.generateJSONSuccessMessage(new JSONObject().put(
								DishConstants.DISH_ID, dish.getKey().getId()));

				if (DEBUG)
					System.out.println("response: " + json);

				// Return key to user
				resp.getWriter().write(json);
			} else {
				resp.getWriter().write(
						APIUtils.generateJSONFailureMessage("User not found."));
				System.err.println("User is null!");
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pm.close();
		}
	}
}
