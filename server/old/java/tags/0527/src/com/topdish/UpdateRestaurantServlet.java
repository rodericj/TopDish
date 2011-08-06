package com.topdish;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

/**
 * {@link HttpServlet} to update information on a {@link Restaurant}
 * 
 */
public class UpdateRestaurantServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -8139126403183852580L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		if(!TDUserService.isUserLoggedIn(req.getSession(true))){
			resp.sendRedirect("login.jsp");
			return;
		}
		
		/*
		 * Pull pieces from request
		 */
		final long restID = Integer.parseInt(req.getParameter("restID"));
		final String name = req.getParameter("name");
		final String addressLine1 = req.getParameter("address1");
		final String addressLine2 = req.getParameter("address2");
		final String city = req.getParameter("city");
		final String state = req.getParameter("state");
		final PhoneNumber phone = new PhoneNumber(req.getParameter("phone"));
		final String neighborhood = req.getParameter("neighborhood");
		final Link url = new Link(req.getParameter("url"));

		try {
			TDUser editor = TDUserService.getUser(req.getSession());

			/*
			 * Update the restaurant
			 */
			Restaurant r = Datastore.get(KeyFactory.createKey(
					Restaurant.class.getSimpleName(), restID));
			r.setName(name);
			r.setAddressLine1(addressLine1);
			r.setAddressLine2(addressLine2);
			r.setCity(city);
			r.setState(state);
			r.setPhone(phone);
			r.setUrl(url);
			r.setNeighborhood(neighborhood);
			r.setLastEditor(editor.getKey());
			r.setDateModified(new Date());

			// Prevents Exception from being thrown when cuisine_id is an empty
			// string
			if (!req.getParameter("cuisine_id").isEmpty()) {
				long cuisineID = Long.parseLong(req.getParameter("cuisine_id"));
				Tag cuisine = Datastore.get(KeyFactory.createKey(
						Tag.class.getSimpleName(), cuisineID));
				r.setCuisine(cuisine.getKey());
			}

			Datastore.put(r);

			Alerts.setInfo(req, Alerts.RESTAURANT_UPDATED);
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
		}
	}
}