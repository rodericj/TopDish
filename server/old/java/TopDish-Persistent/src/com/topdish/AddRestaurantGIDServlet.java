package com.topdish;

import java.io.IOException;
import java.util.Date;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
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
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

public class AddRestaurantGIDServlet  extends HttpServlet {
	private static final long serialVersionUID = 6379542729783887560L;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String name = req.getParameter("name");
		String addressLine1 = req.getParameter("address");
		String addressLine2 = "";
		String city = req.getParameter("city");
		String state = req.getParameter("state");
		String neighborhood = "";
		double lat = Double.valueOf(req.getParameter("lat"));
		double lng = Double.valueOf(req.getParameter("lng"));
		PhoneNumber phone = new PhoneNumber(req.getParameter("phone"));
		String gid = req.getParameter("gid");
		Date created = new Date();
		Link url = new Link(req.getParameter("url"));
		
		try{
			PersistenceManager pm = PMF.get().getPersistenceManager();
			TDUser creator = TDUserService.getUser(pm);

			//check if restaurant exists
			Query query = pm.newQuery(Restaurant.class);
			query.setFilter("gid == nameParam");
			query.declareParameters("String nameParam");
			try {
				List<Restaurant> results = (List<Restaurant>) query.execute(gid);
				if(results.size() > 0){
					//restaurant found, redirect to restaurant
					Restaurant r = (Restaurant)results.get(0);
					//resp.sendRedirect("restaurantDetail.jsp?restID=" + r.getKey().getId());
					resp.sendRedirect("rateDish.jsp?restID=" + r.getKey().getId());
				}else{
					//add restaurant, redirect to restaurant
					Restaurant restaurant = new Restaurant(name, addressLine1, addressLine2,
							city, state, neighborhood, lat, lng, phone,
							gid, url, created, creator.getKey());
					pm.makePersistent(restaurant);
					resp.sendRedirect("rateDish.jsp?restID=" + restaurant.getKey().getId());
					//resp.sendRedirect("restaurantDetail.jsp?restID=" + restaurant.getKey().getId());
				}
		    } finally {
		        query.closeAll();
		        pm.close();
		    }
		}catch(UserNotLoggedInException e){
			//forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			String redirecturl = "../addRestaurantGID?name=" + name + "&address=" + addressLine1;
			redirecturl += "&city=" + city + "&state=" + state + "&lat=" + lat + "&lng=" + lng;
			redirecturl += "&phone=" + phone.getNumber() + "&url=" + url.getValue() + "&gid=" + gid;
			resp.sendRedirect(userService.createLoginURL(redirecturl));
		} catch (UserNotFoundException e) {
			//do nothing
		}	
	}
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		//process GET request in case user just logged in.
		//TODO: remove in favor of pop-over login
		//THIS SCREWS UP THE URL!!!
		doPost(req, resp);
	}
}
