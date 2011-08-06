package com.topdish;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;
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
			PersistenceManager pm = PMF.get().getPersistenceManager();
			TDUserService.getUser(pm); // check that user is logged in

			if (photoID != 0) {
				Photo photo = pm.getObjectById(Photo.class, photoID);
				if (userID != 0) {
					TDUser user = pm.getObjectById(TDUser.class, userID);
					user.removePhoto();
					pm.deletePersistent(photo);
					pm.makePersistent(user);
					resp.sendRedirect("/userProfile.jsp");
				}
				if (dishID != 0) {
					Dish dish = pm.getObjectById(Dish.class, dishID);
					dish.removePhoto(photo.getKey());
					pm.deletePersistent(photo);
					pm.makePersistent(dish);
					resp.sendRedirect("/dishDetail.jsp?dishID=" + dishID);
				}
				if (restID != 0) {
					Restaurant rest = pm
							.getObjectById(Restaurant.class, restID);
					rest.removePhoto(photo.getKey());
					pm.deletePersistent(photo);
					pm.makePersistent(rest);
					resp.sendRedirect("/restaurantDetail.jsp?restID=" + restID);
				}
			}

			pm.close();
		} catch (UserNotLoggedInException e) {
			// forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			// String url = "../addDish.jsp?name=" + name + "&description=" +
			// description;
			// TODO: fix url to return user to try delete again
			resp.sendRedirect(userService.createLoginURL("/index.jsp"));
		} catch (UserNotFoundException e) {
			// do nothing
		}

	}
}
