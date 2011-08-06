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
import com.topdish.api.jdo.DishLite;
import com.topdish.api.util.ConvertToLite;
import com.topdish.jdo.Dish;
import com.topdish.util.TDQueryUtils;

public class DishSearchServlet extends HttpServlet {
	private static final long serialVersionUID = 3305214228504501522L;

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

			resp.getWriter().write(masterArray.toString());

		}
	}
}
