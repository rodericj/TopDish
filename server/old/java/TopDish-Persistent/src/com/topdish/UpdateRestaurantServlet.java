package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.adminconsole.TopDishConstants;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

public class UpdateRestaurantServlet extends HttpServlet {
	private static final long serialVersionUID = -8139126403183852580L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		
		long restID = Integer.parseInt(req.getParameter("restID"));
		String callType=req.getParameter("callType");
		
		String name = req.getParameter("name");
		String addressLine1 = req.getParameter("address1");
		String addressLine2 = req.getParameter("address2");
		String city = req.getParameter("city");
		String state = req.getParameter("state");
		PhoneNumber phone = new PhoneNumber(req.getParameter("phone"));
		String neighborhood = req.getParameter("neighborhood");
		Link url = new Link(req.getParameter("url"));
		String cusineStr=req.getParameter("cuisine_id");
		long cuisineID =0;
		if(null!=cusineStr && cusineStr.length()>0)
		 cuisineID = Long.parseLong(cusineStr);
		Date date = new Date();
		
		try {
			PersistenceManager pm = PMF.get().getPersistenceManager();
			TDUser editor = TDUserService.getUser(pm);
			
			Tag cuisine=null;
			if(cuisineID>0)
				cuisine = TDQueryUtils.getEntity(pm, cuisineID, new Tag());
			
			Restaurant r = TDQueryUtils.getEntity(pm, restID, new Restaurant());
			if(null!=r)
			{
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
				if(null!=cuisine)
					r.setCuisine(cuisine.getKey());
			}
			
			try {
				if(null!=r)
				{
					pm.makePersistent(r);
				}
				List<Restaurant> restList=(List<Restaurant>)req.getSession(true).getAttribute("restList");
				if(null!=restList && restList.size()>0)
				{
					List<Restaurant> restL=new ArrayList<Restaurant>();
					for(Restaurant rest:restList)
					{
						if(null!=r && rest.getKey().getId()==r.getKey().getId())
						{
							restL.add(r);
						}
						else
						{
							restL.add(rest);
						}
					}
					req.getSession(true).setAttribute("restList", restL);
				}
			} finally {
				pm.close();
			}
			if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
			{
				resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>Restaurant updated successfully!!!</mesg>");
			}
			else
				resp.sendRedirect("index.jsp");
		} catch (UserNotLoggedInException e) {
			//forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			String redirectURL = "../editRestaurant.jsp?restID=" + restID;
			if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
			{
				resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>Restaurant could not be updated!!!</mesg>");
			}
			else
				resp.sendRedirect(userService.createLoginURL(redirectURL));
		} catch (UserNotFoundException e) {
			//do nothing
		}		
	}
}