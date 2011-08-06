package com.topdish.api;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.FlagConstants;
import com.topdish.api.util.RestaurantConstants;
import com.topdish.jdo.Flag;
import com.topdish.jdo.Restaurant;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;

/**
 * Servlet to handle flagging a {@link Restaurant} <br>
 * Params: <br>
 * -apiKey - current user's api key <br>
 * -restaurantId - the {@link Restaurant} id to be flagged <br>
 * -type - (see {@link Flag} statics <br>
 * 
 * @author Salil
 * 
 */
public class FlagRestaurantServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -7219706700243372246L;

	/**
	 * DEBUG
	 */
	private static final boolean DEBUG = true;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// Get API Key
		final String apiKey = req.getParameter(APIConstants.API_KEY).trim();

		// Grab User Associated with API Key
		final Key creator = TDQueryUtils.getUserKeyByAPIKey(apiKey);

		try {

			// Check for no user
			if (null != creator) {

				if (DEBUG)
					System.out.println("User Found : "
							+ creator.getId());

				// Get the restaurant id
				final Long restaurantId = Long.parseLong(req
						.getParameter(RestaurantConstants.RESTAURANT_ID));

				// Get the flag type
				final Integer flagType = Integer.parseInt(req
						.getParameter(FlagConstants.FLAG_TYPE));

				// Pull restaurant from db
				Restaurant restaurant = Datastore.get(KeyFactory.createKey(Restaurant.class.getSimpleName(), restaurantId));

				// Check that restaurant exists
				if (null != restaurant) {

					if (DEBUG)
						System.out.println("Restaurant Found : "
								+ restaurant.getKeyString());

					// Check that Flag Type exists
					if (flagType == Flag.INACCURATE
							|| flagType == Flag.INAPPROPRIATE
							|| flagType == Flag.SPAM) {

						// Create new flag
						Flag flag = new Flag(flagType, restaurant.getCreator(),
								creator);

						// Store flag
						Datastore.put(flag);

						try {
							final JSONObject json = new JSONObject();
							json.put(FlagConstants.FLAG_ID, flag.getKey()
									.getId());
							// Write success
							resp.getWriter().write(
									APIUtils.generateJSONSuccessMessage(json));
						} catch (Exception e) {
							// Write generic success
							resp.getWriter().write(
									APIUtils.generateJSONSuccessMessage());
						}

						if (DEBUG)
							System.out.println("Flag Created and Stored : "
									+ flag.getKey().getId()
									+ " with direction " + flag.getType());
					} else {
						// Write failure to find flag type
						resp.getWriter().write(
								APIUtils.generateJSONFailureMessage(flagType
										+ " is an invalid type."));

						if (DEBUG)
							System.out.println("Flag Type was invalid : "
									+ flagType);
					}

				} else {
					// Write failure to find restaurant
					resp.getWriter().write(
							APIUtils.generateJSONFailureMessage("Restaurant "
									+ restaurantId + " did not exist."));

					if (DEBUG)
						System.out.println("Restaurant not found");
				}
			} else {
				// Write failure to find user
				resp
						.getWriter()
						.write(
								APIUtils
										.generateJSONFailureMessage("User with API Key "
												+ apiKey + " does not exist."));

				if (DEBUG)
					System.out.println("User not found");
			}
		} catch (Exception e) {
			resp.getWriter().write(
					APIUtils.generateJSONFailureMessage(e.getMessage()));
		}

	}
}
