package com.topdish;

import java.io.IOException;
import java.util.Date;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

public class UpdateRestaurantServlet extends HttpServlet {
	private static final long serialVersionUID = -8139126403183852580L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		
		long restID = Integer.parseInt(req.getParameter("restID"));
		String name = req.getParameter("name");
		String addressLine1 = req.getParameter("address1");
		String addressLine2 = req.getParameter("address2");
		String city = req.getParameter("city");
		String state = req.getParameter("state");
		PhoneNumber phone = new PhoneNumber(req.getParameter("phone"));
		String neighborhood = req.getParameter("neighborhood");
		Link url = new Link(req.getParameter("url"));
		long cuisineID = Long.parseLong(req.getParameter("cuisine_id"));
		Date date = new Date();
		
		try {
			PersistenceManager pm = PMF.get().getPersistenceManager();
			TDUser editor = TDUserService.getUser(pm);

			Tag cuisine = pm.getObjectById(Tag.class, cuisineID);
			
			Restaurant r = (Restaurant)pm.getObjectById(Restaurant.class, restID);
			r.setName(name);
			r.setAddressLine1(addressLine1);
			r.setAddressLine2(addressLine2);
			r.setCity(city);
			r.setState(state);
			r.setPhone(phone);
			r.setUrl(url);
			r.setNeighborhood(neighborhood);
			r.setLastEditor(editor.getKey());
			r.setDateModified(date);
			r.setCuisine(cuisine.getKey());
			
			try {
				pm.makePersistent(r);
			} finally {
				pm.close();
			}
			resp.sendRedirect("index.jsp");
		} catch (UserNotLoggedInException e) {
			//forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			String redirectURL = "../editRestaurant.jsp?restID=" + restID;
			resp.sendRedirect(userService.createLoginURL(redirectURL));
		} catch (UserNotFoundException e) {
			//do nothing
		}		
	}
}