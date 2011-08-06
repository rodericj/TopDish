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
import com.topdish.api.jdo.DishLite;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.ConvertToLite;
import com.topdish.api.util.DishConstants;
import com.topdish.jdo.Dish;
import com.topdish.util.TDQueryUtils;

public class DishSearchServlet extends HttpServlet {
	private static final long serialVersionUID = 3305214228504501522L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		final String query = req.getParameter(APIConstants.QUERY);
		double lat = 0.0;
		double lng = 0.0;
		int maxDistance = 2000;
		int maxResults = 20;
		String[] searchTerms = {};

		// Get Lat and Long
		try {
			lat = Double.parseDouble(req.getParameter(APIConstants.LAT));
			lng = Double.parseDouble(req.getParameter(APIConstants.LNG));
		} catch (NumberFormatException e) {
			e.printStackTrace();
		} catch (NullPointerException e) {
			e.printStackTrace();
		}

		// Defaults preset
		try {
			maxDistance = Integer.parseInt(req
					.getParameter(APIConstants.DISTANCE));
			maxResults = Integer.parseInt(req.getParameter(APIConstants.LIMIT));
		} catch (Exception e) {
			// Not a big deal since defaults set
		}

		if (null != query && !query.equals(""))
			searchTerms = query.split(" ");

		List<DishLite> dishes = ConvertToLite.convertDishes(TDQueryUtils
				.searchGeoItems(searchTerms, new Point(lat, lng), maxResults,
						maxDistance, new Dish()));

		// Check empty
		if (!dishes.isEmpty()) {
			final JSONArray masterArray = new JSONArray();

			// Traverse each dish
			for (DishLite d : dishes) {
				try {
					// Put it in the array
					masterArray.put(new JSONObject(new Gson().toJson(d)));
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}

			resp.getWriter().write(
					APIUtils.generateJSONSuccessMessage(DishConstants.DISHES,
							masterArray));

		} else
			resp.getWriter().write(
					APIUtils.generateJSONFailureMessage("No Dishes Found."));
	}
}
