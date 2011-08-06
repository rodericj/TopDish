package com.topdish.api;

import java.io.IOException;
import java.util.List;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.beoui.geocell.model.Point;
import com.google.gson.Gson;
import com.topdish.api.jdo.RestaurantLite;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.ConvertToLite;
import com.topdish.api.util.RestaurantConstants;
import com.topdish.jdo.Restaurant;
import com.topdish.util.TDQueryUtils;

public class RestaurantSearchServlet extends HttpServlet {
	private static final long serialVersionUID = 2940294218710551199L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		final String query = req.getParameter(APIConstants.QUERY);
		double lat = 0.0;
		double lng = 0.0;
		int maxDistance = 2000;
		int maxResults = 20;
		String[] searchTerms = {};

		// Get lat and long
		try {
			lat = Double.parseDouble(req.getParameter(APIConstants.LAT));
			lng = Double.parseDouble(req.getParameter(APIConstants.LNG));
		} catch (NumberFormatException e) {
			e.printStackTrace();
		} catch (NullPointerException e) {
			e.printStackTrace();
		}

		// Preset Defaults
		try {
			maxDistance = Integer.parseInt(req
					.getParameter(APIConstants.DISTANCE));
			maxResults = Integer.parseInt(req.getParameter(APIConstants.LIMIT));
		} catch (Exception e) {
			// No big deal, defaults set
		}

		if (null != query && !query.isEmpty())
			searchTerms = query.split(" ");

		List<RestaurantLite> restaurants = ConvertToLite
				.convertRestaurants(TDQueryUtils.searchGeoItems(searchTerms,
						new Point(lat, lng), maxResults, maxDistance,
						new Restaurant()));

		if (!restaurants.isEmpty()) {
			final JSONArray jsonArray = new JSONArray();

			// Traverse each restaurant
			for (final RestaurantLite r : restaurants) {
				try {
					// Put it in the array
					jsonArray.put(new JSONObject(new Gson().toJson(r)));
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}

			// Write success with Array
			resp.getWriter().write(
					APIUtils.generateJSONSuccessMessage(
							RestaurantConstants.RESTAURANTS, jsonArray));
		} else
			resp
					.getWriter()
					.write(
							APIUtils
									.generateJSONFailureMessage("No restaurants found."));
	}
}
