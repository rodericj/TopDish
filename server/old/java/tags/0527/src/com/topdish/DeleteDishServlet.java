package com.topdish;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;

public class DeleteDishServlet extends HttpServlet {
	private static final long serialVersionUID = 97288601828117355L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		try {
			final long dishID = Long.parseLong(req.getParameter("dishID"));
			final Set<Key> delKeys = new HashSet<Key>();
			final Key dishKey = KeyFactory.createKey(
					Dish.class.getSimpleName(), dishID);
			final Restaurant rest = Datastore.get(((Dish) Datastore
					.get(dishKey)).getRestaurant());
			final Dish d = Datastore.get(dishKey);

			// delete dish
			delKeys.add(dishKey);
			// delete reviews for dish
			delKeys.addAll(TDQueryUtils.getReviewKeysByDish(dishKey));
			// delete photos for dish
			if(null != d.getPhotos())
				delKeys.addAll(d.getPhotos());
			// reduce restaurant dish count
			rest.removeDish();

			// delete everything!
			Datastore.delete(delKeys);
			// save restaurant
			Datastore.put(rest);
		} catch (Exception e) {
			e.printStackTrace();
		}

		resp.sendRedirect("index.jsp");
	}
}