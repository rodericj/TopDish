package com.topdish;

import java.io.IOException;
import java.util.Date;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.exception.CuisineCannotHaveParentException;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

public class AddTagServlet extends HttpServlet {
	private static final long serialVersionUID = -3679213866889096509L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		
		String name = "";
		if(req.getParameter("name") != null){
			name = req.getParameter("name");
		}
		
		String description = "";
		if(req.getParameter("description") != null){
			description = req.getParameter("description");
		}
		
		String parentKeyString = "";
		Key parentKey = null;
		if(req.getParameter("parentID") != null){
			if(!req.getParameter("parentID").equals("")){
				long parentID = Long.valueOf(req.getParameter("parentID"));
				Tag parent = pm.getObjectById(Tag.class, parentID);
				parentKey = parent.getKey();
			}
		}
		
		String parentName = "";
		if(req.getParameter("parent") != null){
			parentName = req.getParameter("parent");
		}
		
		int type = 0;
		if(req.getParameter("type") != null){
			type = Integer.parseInt(req.getParameter("type"));
		}
		
		Date created = new Date();
		
		try {
			TDUser creator = TDUserService.getUser(pm);
			Tag tag = new Tag(parentKey, name, description, type, created, creator.getKey());
			try {
				pm.makePersistent(tag);
			} finally {
				pm.close();
			}
			resp.sendRedirect("index.jsp");
		} catch (CuisineCannotHaveParentException e){
			//TODO: show error to user
			resp.sendRedirect("addTag.jsp?name=" + name + "&description=" + description + ""
					+ "&parentName=" + parentName + "&parentID=" + parentKeyString + "&type=" + type);
		} catch (UserNotLoggedInException e) {
			//forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			resp.sendRedirect(userService.createLoginURL("../addTag.jsp?name=" + name + "&description=" + description + ""
					+ "&parentName=" + parentName + "&parentID=" + parentKeyString + "&type=" + type));
		} catch(UserNotFoundException e){
			//do nothing
		}
		
	}
}