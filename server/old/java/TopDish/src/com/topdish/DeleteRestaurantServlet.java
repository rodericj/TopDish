package com.topdish;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.api.util.APIUtils;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

public class DeleteRestaurantServlet extends HttpServlet {
	private static final long serialVersionUID = 9155168219151480031L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		try {
			// Get user object to force login.
			TDUserService.getUser(req.getSession(true));

			final long restID = Long.parseLong(req.getParameter("restID"));
			final String ajax = req.getParameter("ajax");
			final Set<Key> delKeys = new HashSet<Key>();
			final Key restKey = KeyFactory.createKey(Restaurant.class.getSimpleName(), restID);
			final Set<Key> dishKeys = new HashSet<Key>(
					TDQueryUtils.getDishKeysByRestaurant(restKey));

			// Delete restaurant.
			delKeys.add(restKey);
			// Delete restaurant photos.
			delKeys.addAll(((Restaurant) Datastore.get(restKey)).getPhotos());
			// Delete dishes at that restaurant.
			delKeys.addAll(dishKeys);

			for (final Key dishKey : dishKeys) {
				// Delete reviews for each dish.
				delKeys.addAll(TDQueryUtils.getReviewKeysByDish(dishKey));
				// Delete photos for each dish.
				final Dish d = Datastore.get(dishKey);
				if (null != d && null != d.getPhotos()) {
					delKeys.addAll(d.getPhotos());
				}
			}

			Datastore.delete(delKeys);

			// Send JSON response if ajax call.
			if (null != ajax && ajax.equals("true")) {
				final String json = APIUtils.generateJSONSuccessMessage(Alerts.RESTAURANT_DELETED);
				resp.getWriter().write(json);
				return;
			}

			Alerts.setInfo(req, Alerts.RESTAURANT_DELETED);
			resp.sendRedirect("index.jsp");
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
		} catch(Exception e){
			Alerts.setInfo(req, Alerts.GENERAL_ERROR);
			resp.sendRedirect("index.jsp");
			return;
		}
	}
}