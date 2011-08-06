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

public class DeleteRestaurantServlet extends HttpServlet {
	private static final long serialVersionUID = 9155168219151480031L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		final long restID = Long.valueOf(req.getParameter("restID"));
		final Set<Key> delKeys = new HashSet<Key>();
		final Key restKey = KeyFactory.createKey(
				Restaurant.class.getSimpleName(), restID);
		final Set<Key> dishKeys = new HashSet<Key>(TDQueryUtils
				.getDishKeysByRestaurant(restKey));

		// delete restaurant
		delKeys.add(restKey);
		//delete restaurant photos
		delKeys.addAll(((Restaurant) Datastore.get(restKey)).getPhotos());
		// delete dishes at that restaurant
		delKeys.addAll(dishKeys);

		for (Key dishKey : dishKeys) {
			// delete reviews for each dish
			delKeys.addAll(TDQueryUtils.getReviewKeysByDish(dishKey));
			// delete photos for each dish
			final Dish d = Datastore.get(dishKey);
			if(null != d && null != d.getPhotos()){
				delKeys.addAll(d.getPhotos());
			}
		}

		Datastore.delete(delKeys);

		resp.sendRedirect("index.jsp");
	}
}