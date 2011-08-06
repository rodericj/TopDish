package com.topdish.api;

import java.io.IOException;
import java.util.List;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.beoui.geocell.model.Point;
import com.google.appengine.repackaged.org.json.JSONArray;
import com.google.appengine.repackaged.org.json.JSONException;
import com.google.appengine.repackaged.org.json.JSONObject;
import com.google.gson.Gson;
import com.topdish.api.jdo.RestaurantLite;
import com.topdish.api.util.ConvertToLite;
import com.topdish.jdo.Restaurant;
import com.topdish.util.TDQueryUtils;

public class RestaurantSearchServlet extends HttpServlet {
	private static final long serialVersionUID = 2940294218710551199L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		final String query = req.getParameter("q");
		double lat = 0.0;
		double lng = 0.0;
		int maxDistance = 2000;
		int maxResults = 20;
		String[] searchTerms = {};

		try {
			lat = Double.parseDouble(req.getParameter("lat"));
			lng = Double.parseDouble(req.getParameter("lng"));
			maxDistance = Integer.parseInt(req.getParameter("distance"));
			maxResults = Integer.parseInt(req.getParameter("limit"));
		} catch (NumberFormatException e) {
			e.printStackTrace();
		} catch (NullPointerException e) {
			e.printStackTrace();
		}

		if (null != query && !query.equals(""))
			searchTerms = query.split(" ");

		List<RestaurantLite> restaurants = ConvertToLite
				.convertRestaurants(TDQueryUtils.searchGeoItems(searchTerms,
						new Point(lat, lng), maxResults, maxDistance,
						new Restaurant()));

		if (!restaurants.isEmpty()) {
			final JSONArray masterArray = new JSONArray();

			// Traverse each restaurant
			for (RestaurantLite r : restaurants) {
				try {
					// Put it in the array
					masterArray.put(new JSONObject(new Gson().toJson(r)));
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}

			resp.getWriter().write(masterArray.toString());
		}
	}
}
