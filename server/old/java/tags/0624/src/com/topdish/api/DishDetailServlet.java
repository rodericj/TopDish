package com.topdish.api;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import javax.jdo.JDOObjectNotFoundException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.gson.Gson;
import com.topdish.api.jdo.DishLite;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.ConvertToLite;
import com.topdish.api.util.DishConstants;
import com.topdish.jdo.Dish;
import com.topdish.util.Datastore;

//returns all information about a dish including reviews
//parameters: dishID (id # of dish in question)

public class DishDetailServlet extends HttpServlet {
	private static final long serialVersionUID = 507151447822835258L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		// topdish1.appspot.com/api/dishDetail?id[]=1&id[]=2&id[]=5...

		String[] ids = req.getParameterValues(APIConstants.ID_ARRAY);
		Set<Key> dishKeys = new HashSet<Key>();
		
		for (int i = 0; i < ids.length; i++) {
			try {
				Long id = Long.parseLong(ids[i]);
				dishKeys.add(KeyFactory.createKey(Dish.class.getSimpleName(), id));
			} catch (NumberFormatException e) {
				// malformed input
			} catch (JDOObjectNotFoundException e) {
				// object not found, skipping
			}
		}

		final Set<Dish> dishes = Datastore.get(dishKeys);
		final Set<DishLite> dishLites = ConvertToLite.convertDishes(dishes);

		if (!dishLites.isEmpty()) {
			final JSONArray array = new JSONArray();

			// Traverse dishes
			for (final DishLite dish : dishLites) {
				try {
					// Put a new JSONObject of the Dish in the Array
					array.put(new JSONObject(new Gson().toJson(dish)));

				} catch (Exception e) {
					e.printStackTrace();
				}
			}

			// Return array (empty or not)
			resp.getWriter().write(
					APIUtils.generateJSONSuccessMessage(DishConstants.DISHES,
							array));
		} else
			resp.getWriter().write(
					APIUtils.generateJSONFailureMessage("No dishes found"));
	}
}
