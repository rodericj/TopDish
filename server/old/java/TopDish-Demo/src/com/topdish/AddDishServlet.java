package com.topdish;

import java.io.IOException;
import java.util.Date;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;
import com.topdish.util.TagUtils;

public class AddDishServlet extends HttpServlet {
	private static final long serialVersionUID = 7789854914976913694L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException 
    	{
		String name = req.getParameter("name");
		String description = req.getParameter("description");
		String restName = req.getParameter("restaurantName");
		String restIDs = req.getParameter("restaurantID");
		String tagList = req.getParameter("tagList");
		String ingredientList = req.getParameter("ingredientList");
		String categoryIDs = req.getParameter("categoryID");
		String priceIDs = req.getParameter("priceID");
		
		Restaurant rest = null;
		Dish dish = null;
		Date dateCreated = new Date();
		long restID = 0;
		long categoryID = 0;
		long priceID = 0;
		
		try{
			restID = Long.valueOf(restIDs);
		}catch(NumberFormatException e){
			//restID not a long
		}
		try{
			categoryID = Long.parseLong(categoryIDs);
		}catch(NumberFormatException e){
			//categoryID not a long
		}
		try{
			priceID = Long.parseLong(priceIDs);
		}catch(NumberFormatException e){
			//priceID not a long
		}
		
		try {
			PersistenceManager pm = PMF.get().getPersistenceManager();
			TDUser creator = TDUserService.getUser(pm);
			rest = pm.getObjectById(Restaurant.class, restID);
			Tag price = null;
			Tag category = null;
			List<Key> tagKeysToAdd = TagUtils.getTags(pm, tagList, Tag.TYPE_GENERAL);
			List<Key> ingredientTags = TagUtils.getTags(pm, ingredientList, Tag.TYPE_INGREDIENT);
			
			if(categoryID != 0){
				category = pm.getObjectById(Tag.class, categoryID);
				tagKeysToAdd.add(category.getKey());
			}
			if(priceID != 0){
				price = pm.getObjectById(Tag.class, priceID);
				tagKeysToAdd.add(price.getKey());
			}
			
			try {
				tagKeysToAdd.addAll(ingredientTags);
				
				dish = new Dish(name, description, rest.getKey(), rest.getCity(), rest.getState(),
						rest.getNeighborhood(), rest.getLatitude(), rest.getLongitude(), restName,
						dateCreated, creator.getKey(), tagKeysToAdd);

				pm.makePersistent(dish);
				rest.addDish(dish.getKey());
				pm.makePersistent(rest);
			}
			finally {
				pm.close();
			}

			resp.sendRedirect("dishDetail.jsp?dishID=" + dish.getKey().getId());
		} catch (UserNotLoggedInException e) {
			//forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			String url = "../addDish.jsp?name=" + name + "&description=" + description;
			url += "&restaurantName=" + restName + "&restID=" + restID;
			url += "&tagList=" + tagList;
			resp.sendRedirect(userService.createLoginURL(url));
		} catch (UserNotFoundException e) {
			//do nothing
		}
	}
}