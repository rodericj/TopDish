package com.topdish.api;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.beoui.geocell.model.Point;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.repackaged.com.google.io.protocol.proto.ProtocolDescriptor.Tag;
import com.google.gson.Gson;
import com.topdish.api.jdo.DishLite;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.ConvertToLite;
import com.topdish.api.util.DishConstants;
import com.topdish.jdo.Dish;
import com.topdish.util.TDQueryUtils;

public class DishSearchServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 3305214228504501522L;

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = DishSearchServlet.class.getSimpleName();

	@Override
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		// resp.setCharacterEncoding(APIConstants.UTF8_ENCODING);

		final String query = req.getParameter(APIConstants.QUERY);
		double lat = 0.0;
		double lng = 0.0;
		int maxDistance = 2000;
		int maxResults = 20;
		String[] searchTerms = new String[0];

		final String tagIds = req.getParameter("tags");
		final Set<Key> tagKeys = new HashSet<Key>();

		if (null != tagIds && !tagIds.isEmpty())
			for (final String tagId : tagIds.split(",")) {
				try {
					tagKeys.add(KeyFactory.createKey(Tag.class.getSimpleName(),
							Long.parseLong(tagId)));
				} catch (Exception e) {
					e.printStackTrace();
					// skip this tag
				}
			}
		else
			Logger.getLogger(TAG).info("No Tags");

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

		Set<DishLite> dishes = null;

		try {
			// TODO: Make this able to handle tags by "merging" searchGeoItems
			// and filterDishes functions in TDQueryUtils
			// final Set<Dish> dishesFromDb = TDQueryUtils.searchGeoItems(
			// searchTerms, new Point(lat, lng), maxResults, maxDistance,
			// new Dish());
			final Set<Dish> dishesFromDb = new HashSet<Dish>(TDQueryUtils
					.searchGeoItemsWithFilter(searchTerms, new Point(lat, lng),
							maxResults, maxDistance, new Dish(), 0,
							new ArrayList<Key>(tagKeys), null));
			Logger.getLogger(TAG).info(
					"Number of Dishes from TDQueryUtils: "
							+ dishesFromDb.size());
			dishes = ConvertToLite.convertDishes(dishesFromDb);
			Logger.getLogger(TAG).info(
					"Successfully converted " + dishes.size() + " of "
							+ dishesFromDb.size() + " to DishLites");
		} catch (Exception e) {
			e.printStackTrace();
			Logger.getLogger(TAG).info(
					"Query did not finish: " + e.getMessage());
		}

		// Check empty
		if (null != dishes && !dishes.isEmpty()) {
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

			Logger.getLogger(TAG).info(
					"Size of JSON Master Array: " + masterArray.length());

			resp.getWriter().write(
					APIUtils.generateJSONSuccessMessage(DishConstants.DISHES,
							masterArray));

		} else {
			Logger.getLogger(TAG).info("Dishes was null or empty");
			resp.getWriter().write(
					APIUtils.generateJSONFailureMessage("No Dishes Found."));
		}
	}
}
