package com.topdish.api;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.List;

import javax.jdo.Query;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.google.gson.Gson;
import com.topdish.api.jdo.RestaurantLite;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.RestaurantConstants;
import com.topdish.geo.GeoUtils;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDPoint;
import com.topdish.jdo.Tag;
import com.topdish.util.Datastore;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TagUtils;

/**
 * Servlet to Upload new Restaurants
 * 
 * @author Salil
 * 
 */
public class AddRestaurantServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -4945276014841647846L;

	/**
	 * DEBUG
	 */
	private static boolean DEBUG = true;

	@SuppressWarnings("unchecked")
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		PrintWriter pw = resp.getWriter();

		try {
			// Pull parts of Restaurant out of Request
			final String name = validate(req
					.getParameter(RestaurantConstants.NAME));
			final String addressLine1 = validate(req
					.getParameter(RestaurantConstants.ADDRESS_LINE_1));
			final String addressLine2 = validate(req
					.getParameter(RestaurantConstants.ADDRESS_LINE_2));
			final String city = validate(req
					.getParameter(RestaurantConstants.CITY));
			final String state = validate(req
					.getParameter(RestaurantConstants.STATE));
			final String neighborhood = validate(req
					.getParameter(RestaurantConstants.NEIGHBORHOOD));
			final String phoneS = validate(req
					.getParameter(RestaurantConstants.PHONE));
			final String urlS = validate(req
					.getParameter(RestaurantConstants.URL));
			final String cuisine = validate(req
					.getParameter(RestaurantConstants.CUISINE));

			final String apiKey = validate(req
					.getParameter(APIConstants.API_KEY));

			// Create PhoneNumber object
			final PhoneNumber phone = new PhoneNumber(phoneS);

			// Create Link URL object
			final Link url = new Link(urlS);

			Key creator = TDQueryUtils.getUserKeyByAPIKey(apiKey);

			if (null == creator) {
				creator = TDQueryUtils.getDefaultUser();
			}

			String gid = "";

			double latitude = 0.0;
			double longitude = 0.0;

			TDPoint geoLoc = GeoUtils.reverseAddress(addressLine1 + " "
					+ addressLine2, city, state);

			// Check Emtpy Results
			if (null != geoLoc) {

				latitude = geoLoc.getLat();
				longitude = geoLoc.getLon();
			}

			// Check if restaurant exists
			Query restQ = PMF.get().getPersistenceManager().newQuery(Restaurant.class);
			restQ.setFilter("name == :p");
			List<Restaurant> restResults = (List<Restaurant>) restQ
					.execute(name);

			Restaurant restaurant = null;

			// If it does exist, use returned restaurant
			if (!restResults.isEmpty()) {
				if (DEBUG)
					System.out.println("Restaurant found, not re-adding: "
							+ name);
				restaurant = restResults.get(0);
			}
			// Else if it does not, create it
			else {
				if (DEBUG)
					System.out.println("This is a new restaurant.");

				// fill in new stuff for restaurant
				restaurant = new Restaurant(name, addressLine1, addressLine2,
						city, state, neighborhood, latitude, longitude, phone,
						gid, url, new Date(),
						(null != creator ? creator : null));

				// Grab tag by name
				List<Key> tags = TagUtils
						.getTagKeysByName(new String[] { cuisine });

				// Check that
				if (null != tags && !tags.isEmpty()) {
					Tag tag = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), tags.get(0).getId()));
					if (tag.getType() == Tag.TYPE_CUISINE)
						restaurant.setCuisine(tags.get(0));
				}

			}

			// Save the restaurant
			Datastore.put(restaurant);

			// Construct the return
			final JSONObject json = new JSONObject().put(
					RestaurantConstants.RESTAURANT,
					new JSONObject(new Gson().toJson(new RestaurantLite(
							restaurant))));

			// Write the new json object
			pw.write(APIUtils.generateJSONSuccessMessage(json));

		} catch (Exception e) {
			e.printStackTrace();

			// Inform user of Error
			pw.write(APIUtils.generateJSONFailureMessage(e));

		} finally {
			pw.flush();
			pw.close();
		}

	}

	/**
	 * Checks if a {@link String} is not null, if it is returns new empty
	 * {@link String}
	 * 
	 * @param toValidate
	 *            - {@link String} to validate
	 * @return the string if its not null, or a new {@link String}
	 */
	private String validate(String toValidate) {
		return (null != toValidate ? toValidate : new String());
	}
}
