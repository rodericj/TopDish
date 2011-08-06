package com.topdish;

import java.io.IOException;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;
import com.topdish.util.TagUtils;

public class AddDishServlet extends HttpServlet {
	private static final long serialVersionUID = 7789854914976913694L;
	private static final String TAG = AddDishServlet.class.getSimpleName();

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		try {
			final TDUser creator = TDUserService.getUser(req.getSession());

			final String name = req.getParameter("name");
			final String description = req.getParameter("description");
			final String restName = req.getParameter("restaurantName");
			final String restIDs = req.getParameter("restaurantID");
			final String tagList = req.getParameter("tagList");
			final String categoryIDs = req.getParameter("categoryID");
			final String priceIDs = req.getParameter("priceID");

			Restaurant rest = null;
			Dish dish = null;
			long restID = 0;
			long categoryID = 0;
			long priceID = 0;
			Tag price = null;
			Tag category = null;

			try {
				restID = Long.parseLong(restIDs);
			} catch (NumberFormatException e) {
				// restID not a long
			}
			try {
				categoryID = Long.parseLong(categoryIDs);
			} catch (NumberFormatException e) {
				// categoryID not a long
			}
			try {
				priceID = Long.parseLong(priceIDs);
			} catch (NumberFormatException e) {
				// priceID not a long
			}

			rest = Datastore.get(KeyFactory.createKey(Restaurant.class.getSimpleName(), restID));
			final Set<Key> tagKeysToAdd = new HashSet<Key>(TagUtils.getTagKeysByName(tagList
					.split(", ")));

			if (categoryID != 0) {
				category = Datastore
						.get(KeyFactory.createKey(Tag.class.getSimpleName(), categoryID));
				tagKeysToAdd.add(category.getKey());
			}
			if (priceID != 0) {
				price = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), priceID));
				tagKeysToAdd.add(price.getKey());
			}

			dish = new Dish(name, description, rest.getKey(), rest.getCity(), rest.getState(),
					rest.getNeighborhood(), rest.getLatitude(), rest.getLongitude(), restName,
					new Date(), creator.getKey(), tagKeysToAdd);

			// Adds the Restaurant's current Cuisine.
			if (null != rest.getCuisine()){
				dish.setCuisine(rest.getCuisine());
			}

			Datastore.put(dish);
			rest.addDish();
			Datastore.put(rest);

			resp.sendRedirect("dishDetail.jsp?dishID=" + dish.getKey().getId());
			Alerts.setInfo(req, Alerts.DISH_ADDED);
			return;
		} catch (UserNotLoggedInException e) {
			// forward to login screen
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		} catch (UserNotFoundException e) {
			// forward to login screen
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		} catch (Exception e) {
			Logger.getLogger(TAG).error(e.getMessage());
			Alerts.setError(req, Alerts.DISH_NOT_ADDED);
			resp.sendRedirect("index.jsp");
			return;
		}
	}
}