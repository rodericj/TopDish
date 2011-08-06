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

public class DeleteDishServlet extends HttpServlet {
	private static final long serialVersionUID = 97288601828117355L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		try {
			TDUserService.getUser(req.getSession(true));
			final long dishID = Long.parseLong(req.getParameter("dishID"));
			final String ajax = req.getParameter("ajax");
			final Set<Key> delKeys = new HashSet<Key>();
			final Key dishKey = KeyFactory.createKey(Dish.class.getSimpleName(), dishID);
			final Restaurant rest = Datastore.get(((Dish) Datastore.get(dishKey)).getRestaurant());
			final Dish d = Datastore.get(dishKey);

			// delete dish
			delKeys.add(dishKey);
			// delete reviews for dish
			delKeys.addAll(TDQueryUtils.getReviewKeysByDish(dishKey));
			// delete photos for dish
			if (null != d.getPhotos())
				delKeys.addAll(d.getPhotos());
			// reduce restaurant dish count
			rest.removeDish();

			// delete everything!
			Datastore.delete(delKeys);
			// save restaurant
			Datastore.put(rest);

			// Send JSON response if ajax call.
			if (null != ajax && ajax.equals("true")) {
				final String json = APIUtils.generateJSONSuccessMessage(Alerts.DISH_DELETED);
				resp.getWriter().write(json);
				return;
			}

			Alerts.setInfo(req, Alerts.DISH_DELETED);
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
			final String ajax = req.getParameter("ajax");
			if(null != ajax && ajax.equals("true")){
				final String json = APIUtils.generateJSONFailureMessage(Alerts.DISH_NOT_DELETED);
				resp.getWriter().write(json);
				return;
			}
			
			Alerts.setInfo(req, Alerts.DISH_NOT_DELETED);
			resp.sendRedirect("index.jsp");
			return;
		}
	}
}