package com.topdish;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class AddPhotoServlet extends HttpServlet {
	private static final long serialVersionUID = 6510992373222045247L;
	private BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		if(!TDUserService.isUserLoggedIn(req.getSession(false))){
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}
		
		// TODO: session times out if you use "back" and try again

		Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
		BlobKey blobKey = blobs.get("myFile");

		String userIDs = req.getParameter("userID");
		String dishIDs = req.getParameter("dishID");
		String restIDs = req.getParameter("restID");
		String desc = req.getParameter("description");

		long userID = 0;
		long dishID = 0;
		long restID = 0;

		try {
			// Check that both the blob is null
			if (blobKey == null) {
				//TODO: find a better place to redirect
				Alerts.setError(req, Alerts.PHOTO_NOT_ADDED);
				resp.sendRedirect("index.jsp");
				return;
			} else {
				TDUser creator = TDUserService.getUser(req.getSession());
				Photo photo = null;
				// use blob if provided
				if (null != blobKey) {
					photo = new Photo(blobKey, desc, creator.getKey());
					Datastore.put(photo);

					if (userIDs != null) {
						userID = Long.parseLong(userIDs);
						if (userID == creator.getKey().getId()) {
							// only allow user to update own photo
							TDUser user = Datastore.get(KeyFactory.createKey(
									TDUser.class.getSimpleName(), userID));
							user.setPhoto(photo.getKey());
							Datastore.put(user);
							
							Alerts.setInfo(req, Alerts.PHOTO_ADDED);
							resp.sendRedirect("/userProfile.jsp");
							return;
						} else {
							Alerts.setError(req, Alerts.PHOTO_NOT_ADDED);
							resp.sendRedirect("index.jsp");
							return;
						}
					}

					if (dishIDs != null) {
						dishID = Long.parseLong(dishIDs);
						Dish dish = Datastore.get(KeyFactory.createKey(
								Dish.class.getSimpleName(), dishID));
						dish.addPhoto(photo.getKey());
						Datastore.put(dish);
						
						Alerts.setInfo(req, Alerts.PHOTO_ADDED);
						resp.sendRedirect("/dishDetail.jsp?dishID=" + dishID);
						return;
					}

					if (restIDs != null) {
						restID = Long.parseLong(restIDs);
						Restaurant rest = Datastore.get(KeyFactory.createKey(
								Restaurant.class.getSimpleName(), restID));
						rest.addPhoto(photo.getKey());
						Datastore.put(rest);
						
						Alerts.setInfo(req, Alerts.PHOTO_ADDED);
						resp.sendRedirect("/restaurantDetail.jsp?restID="
								+ restID);
						return;
					}
				}
			}
		} catch (UserNotLoggedInException e) {
			// forward to login screen
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		} catch (UserNotFoundException e) {
			// forward to login screen
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}
	}
}
