package com.topdish.api;

import java.io.IOException;
import java.util.SortedMap;
import java.util.Map.Entry;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.beoui.geocell.model.Point;
import com.google.appengine.repackaged.org.json.JSONArray;
import com.google.appengine.repackaged.org.json.JSONException;
import com.google.appengine.repackaged.org.json.JSONObject;
import com.google.gson.Gson;
import com.topdish.api.jdo.DishLite;
import com.topdish.jdo.Dish;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;
import com.topdish.util.TDRecoUtils;
import com.topdish.util.TDUserService;

public class DishRecommendServlet extends HttpServlet {
	private static final long serialVersionUID = 3305214228504501522L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException, ServletException {
		
		double lat = 0.0;
		double lng = 0.0;
		int maxDistance = 2000;
		int maxResults = 20;

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

		// Set the user and check that it is not null
		TDUser user = null;
		try {
			user = TDUserService.getUser(PMF.get().getPersistenceManager());
		} catch(Exception e) {
			throw new ServletException(e);
		}

		final SortedMap<Double, Dish> recoDishes = TDRecoUtils
				.recommendDishes(user, new Point(lat, lng), maxResults, maxDistance);
		JSONArray masterArray = new JSONArray();

		// Traverse each dish
		if (recoDishes != null) {
			for (Entry<Double, Dish> recoEntry : recoDishes.entrySet()) {
				try {
					DishLite dishLite = new DishLite(recoEntry.getValue()); 
					JSONObject jsonObj = new JSONObject((new Gson().toJson(dishLite)));
					jsonObj.put("recoScore", recoEntry.getKey());
					masterArray.put(jsonObj);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		}
		
		resp.getWriter().write(masterArray.toString());
	}
}
