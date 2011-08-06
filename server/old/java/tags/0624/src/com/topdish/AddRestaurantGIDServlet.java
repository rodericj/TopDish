package com.topdish;

import java.io.IOException;
import java.util.Date;
import java.util.List;

import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

public class AddRestaurantGIDServlet extends HttpServlet {
	private static final long serialVersionUID = 6379542729783887560L;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		if (!TDUserService.isUserLoggedIn(req.getSession(true))) {
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}

		String name = req.getParameter("name");
		String addressLine1 = req.getParameter("address");
		String addressLine2 = "";
		String city = req.getParameter("city");
		String state = req.getParameter("state");
		String neighborhood = "";
		double lat = Double.parseDouble(req.getParameter("lat"));
		double lng = Double.parseDouble(req.getParameter("lng"));
		PhoneNumber phone = new PhoneNumber(req.getParameter("phone"));
		String gid = req.getParameter("gid");
		Date created = new Date();
		Link url = new Link(req.getParameter("url"));

		try {
			TDUser creator = TDUserService.getUser(req.getSession());

			// check if restaurant exists
			Query query = PMF.get().getPersistenceManager().newQuery(Restaurant.class);
			query.setFilter("gid == nameParam");
			query.declareParameters("String nameParam");
			try {
				List<Restaurant> results = (List<Restaurant>) query.execute(gid);
				if (results.size() > 0) {
					// restaurant found, redirect to restaurant
					Restaurant r = (Restaurant) results.get(0);
					resp.sendRedirect("rateDish.jsp?restID=" + r.getKey().getId());
					return;
				} else {
					// add restaurant, redirect to restaurant
					Restaurant restaurant = new Restaurant(name, addressLine1, addressLine2, city,
							state, neighborhood, lat, lng, phone, gid, url, created,
							creator.getKey());
					Datastore.put(restaurant);
					resp.sendRedirect("rateDish.jsp?restID=" + restaurant.getKey().getId());
					return;
				}
			} finally {
				query.closeAll();
			}
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
