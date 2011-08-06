package com.topdish.api;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.gson.Gson;
import com.topdish.api.jdo.RestaurantLite;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.RestaurantConstants;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.util.PMF;

//returns all information about a restaurant including dishes

public class RestaurantDetailServlet extends HttpServlet {
	private static final long serialVersionUID = -4026395514197779694L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		// topdish1.appspot.com/api/restaurantDetail?id[]=1&id[]=2&id[]=5...

		try {
			// List of Ids
			final String[] ids = req.getParameterValues(APIConstants.ID_ARRAY);

			PersistenceManager pm = PMF.get().getPersistenceManager();

			// JSON array of Restaurants
			final JSONArray jsonArray = new JSONArray();

			// Traverse Ids
			for (String id : ids) {
				try {
					// Get Restaurant from DB
					final Restaurant rest = pm.getObjectById(Restaurant.class,
							Long.parseLong(id));

					// Add to Array
					jsonArray.put(new JSONObject(new Gson()
							.toJson(new RestaurantLite(rest))));
				} catch (NumberFormatException e){
					//bad input value
				} catch (Exception e) {
					e.printStackTrace();
					// Skip this cause it failed
				}
			}

			// Print success with Message
			resp.getWriter().write(
					APIUtils.generateJSONSuccessMessage(
							RestaurantConstants.RESTAURANTS, jsonArray));

		} catch (Exception e) {
			e.printStackTrace();
			// Print failure with message
			resp.getWriter().write(APIUtils.generateJSONFailureMessage(e));
		}

	}
}
