package com.topdish;

import java.io.IOException;
import java.util.Arrays;
import java.util.Date;

import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

public class UpdateDishServlet extends HttpServlet
{
	private static final long serialVersionUID = 3426591936548809459L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException 
    	{
		
		String dishIDs = req.getParameter("dishID");
		String name = req.getParameter("name");
		String description = req.getParameter("description");
		String categoryIDs = req.getParameter("categoryID");
		String priceIDs = req.getParameter("priceID");
		String tagList = req.getParameter("tagList");
		Date date = new Date();
		long categoryID = 0;
		long priceID = 0;
		long dishID = 0;
		
		try{
			dishID = Long.parseLong(dishIDs);
		}catch(NumberFormatException e){
			//not a long
		}
		try{
			priceID = Long.parseLong(priceIDs);
		}catch(NumberFormatException e){
			//not a long
		}
		try{
			categoryID = Long.parseLong(categoryIDs);
		}catch(NumberFormatException e){
			//not a long
		}
		
		try 
		{
			PersistenceManager pm = PMF.get().getPersistenceManager();
			TDUser editor = TDUserService.getUser(pm);
			Dish d = pm.getObjectById(Dish.class, dishID);
			d.setName(name);
			d.setDescription(description);
			d.setLastEditor(editor.getKey());
			d.setDateModified(date);
			d.removeAllTags(); 
			d.addTag(pm.getObjectById(Tag.class, categoryID).getKey());
			d.addTag(pm.getObjectById(Tag.class, priceID).getKey());
						
			if(!tagList.equals("")){
				for(String id : Arrays.asList(tagList.split("[,;]+"))){
					d.addTag(PMF.get().getPersistenceManager().getObjectById(Tag.class, Integer.parseInt(id)).getKey());
				}
			}

			pm.makePersistent(d);
			pm.close();

			resp.sendRedirect("dishDetail.jsp?dishID=" + dishIDs);
		} catch (UserNotLoggedInException e) {
			//forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			String url = "../editDish.jsp?dishID=" + dishIDs;
			resp.sendRedirect(userService.createLoginURL(url));
		} catch (UserNotFoundException e) {
			//do nothing
		} catch (JDOObjectNotFoundException e){
			e.printStackTrace();
		}
	}
}