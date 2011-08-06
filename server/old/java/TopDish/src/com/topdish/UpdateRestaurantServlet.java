package com.topdish;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.google.gson.Gson;
import com.topdish.api.jdo.RestaurantLite;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.RestaurantConstants;
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

	private static final String TAG = UpdateRestaurantServlet.class.getSimpleName();

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		try {
			final TDUser editor = TDUserService.getUser(req.getSession(true));

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
			final String ajax = req.getParameter("ajax");

			/*
			 * Update the restaurant
			 */
			final Restaurant r = Datastore.get(KeyFactory.createKey(Restaurant.class.getSimpleName(),
					restID));
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

			Logger.getLogger(TAG).info("Updating Restaurant " + r.getKey().getId());

			// Prevents Exception from being thrown when cuisine_id is an empty
			// string
			if (!req.getParameter("cuisine_id").isEmpty()) {
				long cuisineID = Long.parseLong(req.getParameter("cuisine_id"));
				final Tag cuisine = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(),
						cuisineID));
				r.setCuisine(cuisine.getKey());
				Logger.getLogger(TAG)
						.info("Setting cuisine to " + cuisine.getKey().getId() + ": "
								+ cuisine.getName());
			}

			Datastore.put(r);

			// Send JSON response if ajax call.
			if (null != ajax && ajax.equals("true")) {
				try {
					final String restStr = new Gson().toJson(new RestaurantLite(r));
					final String json = APIUtils.generateJSONSuccessMessage(new JSONObject().put(
							RestaurantConstants.RESTAURANT, restStr), Alerts.RESTAURANT_UPDATED);
					resp.getWriter().write(json);
					return;
				} catch (JSONException e) {
					APIUtils.generateJSONFailureMessage(e);
				}
			}

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
		} catch(Exception e){
			Logger.getLogger(TAG).error(e.getMessage());
			Alerts.setError(req, Alerts.RESTAURANT_NOT_UPDATED);
			resp.sendRedirect("index.jsp");
			return;
		}
	}
}