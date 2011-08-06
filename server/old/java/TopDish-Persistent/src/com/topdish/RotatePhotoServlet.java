package com.topdish;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.adminconsole.TopDishConstants;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Photo;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

public class RotatePhotoServlet extends HttpServlet{
	private static final long serialVersionUID = -3667818854704812885L;
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
		throws IOException{
		
	    String dishIDs = req.getParameter("dishID");
	    String photoIDs = req.getParameter("photoID");
	    
        long dishID = 0;
        long photoID = 0;
        
        String callType = req.getParameter("callType");
		
		boolean isAjaxCall=false;
		
		if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
			isAjaxCall=true;
        try{
        	PersistenceManager pm = PMF.get().getPersistenceManager();
			TDUserService.getUser(pm);	//check that user is logged in
        	
        	if(photoIDs != null){
        		photoID = Long.valueOf(photoIDs);
        		dishID = Long.valueOf(dishIDs);
        		Photo photo = pm.getObjectById(Photo.class, photoID);
        		photo.rotateImage();
        		pm.makePersistent(photo);
        		if(!isAjaxCall)
        			resp.sendRedirect("/editDish.jsp?dishID=" + dishID);
        	}

        	pm.close();
        	if(isAjaxCall)
			{
				resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>Photo rotated successfully!!!</mesg>");
			    
			}
        } catch (UserNotLoggedInException e) {
			//forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			//String url = "../addDish.jsp?name=" + name + "&description=" + description;
			//TODO: fix url to return user to try delete again
			if(isAjaxCall)
			{
				resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>Photo could not be rotated!!!</mesg>");
			    
			}
			else
				resp.sendRedirect(userService.createLoginURL("/index.jsp"));
		} catch (UserNotFoundException e) {
			//do nothing
		}
	    
	}
	
	  
}
