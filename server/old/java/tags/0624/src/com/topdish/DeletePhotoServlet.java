package com.topdish;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class DeletePhotoServlet extends HttpServlet {
	private static final long serialVersionUID = -3667818854704812885L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		String userIDs = req.getParameter("userID");
		String dishIDs = req.getParameter("dishID");
		String restIDs = req.getParameter("restID");
		String photoIDs = req.getParameter("photoID");

		long userID = 0;
		long dishID = 0;
		long restID = 0;
		long photoID = 0;

		try {
			userID = Long.parseLong(userIDs);
		} catch (NumberFormatException e) {
			// not a long
		}
		try {
			dishID = Long.parseLong(dishIDs);
		} catch (NumberFormatException e) {
			// not a long
		}
		try {
			restID = Long.parseLong(restIDs);
		} catch (NumberFormatException e) {
			// not a long
		}
		try {
			photoID = Long.parseLong(photoIDs);
		} catch (NumberFormatException e) {
			// not a long
		}

		try {
			// check that user is logged in
			TDUserService.getUser(req.getSession());

			if (photoID != 0) {
				Photo photo = Datastore.get(KeyFactory.createKey(
						Photo.class.getSimpleName(), photoID));
				if (userID != 0) {
					TDUser user = Datastore.get(KeyFactory.createKey(
							TDUser.class.getSimpleName(), userID));
					user.removePhoto();
					Datastore.delete(photo.getKey());
					Datastore.put(user);
					resp.sendRedirect("/userProfile.jsp");
				}
				if (dishID != 0) {
					Dish dish = Datastore.get(KeyFactory.createKey(
							Dish.class.getSimpleName(), dishID));
					dish.removePhoto(photo.getKey());
					Datastore.delete(photo.getKey());
					Datastore.put(dish);
					resp.sendRedirect("/dishDetail.jsp?dishID=" + dishID);
				}
				if (restID != 0) {
					Restaurant rest = Datastore.get(KeyFactory.createKey(
							Restaurant.class.getSimpleName(), restID));
					rest.removePhoto(photo.getKey());
					Datastore.delete(photo.getKey());
					Datastore.put(rest);
					resp.sendRedirect("/restaurantDetail.jsp?restID=" + restID);
				}
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
