package com.topdish.api;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.gson.Gson;
import com.topdish.api.jdo.DishLite;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.DishConstants;
import com.topdish.api.util.ReviewConstants;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Review;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;

/**
 * Class to handle rating a dish for the API
 * 
 * @author Salil
 * 
 */
public class RateDishServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -3589030030821612441L;

	/**
	 * Print DEBUG
	 */
	private static final boolean DEBUG = true;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		final String apiKey = req.getParameter(APIConstants.API_KEY);
		// Grab User Associated with API Key
		final Key creatorKey = TDQueryUtils.getUserKeyByAPIKey(apiKey);

		if (null != creatorKey) {

			if (DEBUG) {
				System.out.println("Starting Rate Dish");
				System.out.println("User with api key " + apiKey + " found.");
			}

			try {
				// Get Posted Data
				final Long dishId = Long.parseLong(req
						.getParameter(DishConstants.DISH_ID));
				final Integer direction = Integer.parseInt(req
						.getParameter(ReviewConstants.DIRECTION));
				final String comment = req
						.getParameter(ReviewConstants.COMMENT);

				if (DEBUG)
					System.out.println("Adding : " + dishId + " with a "
							+ direction + " review and comment " + comment);

				Dish dish = Datastore.get(KeyFactory.createKey(
						Dish.class.getSimpleName(), dishId));

				// Create Review
				Review review = new Review(dish.getKey(), direction, comment,
						creatorKey);
				Datastore.put(review);

				// Add Review to Dish
				dish.addReview(review);
				Datastore.put(dish);

				if (DEBUG)
					System.out
							.println("Dish successfully updated with review.");

				// Send back success message
				try {
					// Return the fixed object
					final JSONObject masterO = new JSONObject();
					masterO.put(
							DishConstants.DISH,
							new JSONObject(new Gson()
									.toJson(new DishLite(dish))));
					resp.getWriter().write(
							APIUtils.generateJSONSuccessMessage(masterO));
				} catch (Exception ex) {
					// Return generic message
					resp.getWriter().write(
							APIUtils.generateJSONSuccessMessage());
				}

			} catch (Exception e) {
				e.printStackTrace();

				// Return error message
				resp.getWriter().write(APIUtils.generateJSONFailureMessage(e));
			}

		} else if (DEBUG) {
			System.err.println("No user found for api key: "
					+ req.getParameter(APIConstants.API_KEY).trim());

			resp.getWriter().write(
					APIUtils.generateJSONFailureMessage("User not found."));
		}
	}
}