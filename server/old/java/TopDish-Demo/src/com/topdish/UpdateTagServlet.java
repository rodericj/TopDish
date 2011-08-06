package com.topdish;

import java.io.IOException;
import java.util.Date;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.exception.CuisineCannotHaveParentException;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.ParentIsSelfException;
import com.topdish.util.TDUserService;

public class UpdateTagServlet extends HttpServlet {
	
	private static final long serialVersionUID = -6416366011223346230L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		
		PersistenceManager pm = PMF.get().getPersistenceManager();
		
		long tagID = Integer.parseInt(req.getParameter("id"));
		String name = req.getParameter("name");
		String description = req.getParameter("description");
		int type = 0;
		int manualOrder = 0;
		
		try{
			type = Integer.parseInt(req.getParameter("type"));
		}catch(NumberFormatException e){
			//not an int
		}
		try{
			manualOrder = Integer.parseInt(req.getParameter("manual_order"));
		}catch(NumberFormatException e){
			//not an int
		}
		
		Tag parent = null;
		if(req.getParameter("parentID") != null){
			if(!req.getParameter("parentID").equals("")){
				long parentID = Long.parseLong(req.getParameter("parentID"));
				parent = pm.getObjectById(Tag.class, parentID);
			}
		}
		
		Date date = new Date();
		
		TDUser editor;
		try {
			editor = TDUserService.getUser(pm);

			Tag t = (Tag)pm.getObjectById(Tag.class, tagID);
			t.setName(name);
			t.setDescription(description);
			t.setLastEditor(editor.getKey());
			t.setDateModified(date);
			t.setType(type);
			t.setManualOrder(manualOrder);
			if(parent != null)
				t.setParentTag(parent.getKey());
			
			try {
				pm.makePersistent(t);
			} finally {
				pm.close();
			}
			resp.sendRedirect("index.jsp");
		} catch (ParentIsSelfException e){
			//TODO: show error to user
			resp.sendRedirect("editTag.jsp?tagID=" + tagID);
		} catch (CuisineCannotHaveParentException e){
			//TODO: show error to user
			resp.sendRedirect("editTag.jsp?tagID=" + tagID);
		} catch (UserNotLoggedInException e) {
			//forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			String redirectURL = "../editTag.jsp?tagID=" + tagID;
			resp.sendRedirect(userService.createLoginURL(redirectURL));
		} catch (UserNotFoundException e) {
			//do nothing
		}
	}
}