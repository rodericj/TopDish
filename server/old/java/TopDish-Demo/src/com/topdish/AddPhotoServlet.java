package com.topdish;

import java.io.IOException;
import java.util.Map;

import javax.jdo.PersistenceManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
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

public class AddPhotoServlet extends HttpServlet {
	private static final long serialVersionUID = 6510992373222045247L;
	private BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

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
				resp.sendRedirect("/userProfile.jsp");
			} else {
				PersistenceManager pm = PMF.get().getPersistenceManager();
				TDUser creator = TDUserService.getUser(pm);
				Photo photo = null;
				// use blob if provided
				if (null != blobKey) {
					photo = new Photo(blobKey, desc, creator.getKey());
					pm.makePersistent(photo);
				}
				if (userIDs != null) {
					userID = Long.valueOf(userIDs);
					if (userID == creator.getKey().getId()) {
						// only allow user to update own photo
						TDUser user = pm.getObjectById(TDUser.class, userID);
						user.setPhoto(photo.getKey());
						pm.makePersistent(user);
						resp.sendRedirect("/userProfile.jsp");
					} else {
						resp.sendRedirect("/");
					}
				}

				if (dishIDs != null) {
					dishID = Long.valueOf(dishIDs);
					Dish dish = pm.getObjectById(Dish.class, dishID);
					dish.addPhoto(photo.getKey());
					pm.makePersistent(dish);
					resp.sendRedirect("/dishDetail.jsp?dishID=" + dishID);
				}

				if (restIDs != null) {
					restID = Long.valueOf(restIDs);
					Restaurant rest = pm
							.getObjectById(Restaurant.class, restID);
					rest.addPhoto(photo.getKey());
					pm.makePersistent(rest);
					resp.sendRedirect("/restaurantDetail.jsp?restID=" + restID);
				}

				pm.close();
			}
		} catch (UserNotLoggedInException e) {
			// forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			// String url = "../addDish.jsp?name=" + name + "&description=" +
			// description;
			// TODO: fix url to return user to try upload again
			resp.sendRedirect(userService.createLoginURL("/index.jsp"));
		} catch (UserNotFoundException e) {
			// do nothing
		}
	}
}
