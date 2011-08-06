package com.topdish;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Photo;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class RotatePhotoServlet extends HttpServlet {
	private static final long serialVersionUID = -3667818854704812885L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		if(!TDUserService.isUserLoggedIn(req.getSession(false))){
			resp.sendRedirect("login.jsp");
			return;
		}
		
		String dishIDs = req.getParameter("dishID");
		String photoIDs = req.getParameter("photoID");

		long dishID = 0;
		long photoID = 0;

		try {
			// check the user is logged in
			TDUserService.getUser(req.getSession());

			if (photoIDs != null) {
				photoID = Long.valueOf(photoIDs);
				dishID = Long.valueOf(dishIDs);
				Photo photo = Datastore.get(KeyFactory.createKey(
						Photo.class.getSimpleName(), photoID));
				photo.rotateImage();
				Datastore.put(photo);
				resp.sendRedirect("/editDish.jsp?dishID=" + dishID);
			}
		} catch (UserNotLoggedInException e) {
			// forward to login screen
			resp.sendRedirect("login.jsp");
		} catch (UserNotFoundException e) {
			// forward to login screen
			resp.sendRedirect("login.jsp");
		}
	}
}
