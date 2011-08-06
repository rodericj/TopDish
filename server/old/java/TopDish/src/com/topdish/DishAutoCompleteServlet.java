package com.topdish;

import java.io.IOException;
import java.util.Set;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.appengine.api.datastore.KeyFactory;
import com.google.gson.Gson;
import com.topdish.api.jdo.DishLite;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.ConvertToLite;
import com.topdish.api.util.DishConstants;
import com.topdish.jdo.Restaurant;
import com.topdish.util.TDQueryUtils;

public class DishAutoCompleteServlet extends HttpServlet {
	private static final long serialVersionUID = 7270956707603091302L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		String name = req.getParameter("q");
		int limit = 10;
		long restID = 0;
		String restIDs = "";
		String limitS = "";
		final boolean DEBUG = false;

		if (req.getParameter("restID") != null) {
			restIDs = req.getParameter("restID");
		}

		if (req.getParameter("limit") != null) {
			limitS = req.getParameter("limit");
		}

		try {
			limit = Integer.parseInt(limitS);
			restID = Long.parseLong(restIDs);

			if (DEBUG)
				System.out.println("restID:" + restID + ", limit: " + limit);

		} catch (NumberFormatException e) {
			throw new IllegalArgumentException(
					"Restaurant ID must be greater than zero.");
		}

		String[] queryWords = name.split(" ");

		if (restID <= 0)
			throw new IllegalArgumentException(
					"Restaurant ID must be greater than zero.");

		Set<DishLite> dishes = ConvertToLite.convertDishes(TDQueryUtils
				.searchDishesByRestaurant(queryWords, KeyFactory.createKey(
						Restaurant.class.getSimpleName(), restID), limit));

		if (!dishes.isEmpty()) {
			if (DEBUG)
				System.out.println(dishes.size() + " dishes found");

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
			
			resp.getWriter().flush();

			if (DEBUG)
				System.out.println("response: "
						+ APIUtils.generateJSONSuccessMessage(
								DishConstants.DISHES, masterArray));
		} else {
			if (DEBUG)
				System.out.println("No dishes found");
		}
	}
}