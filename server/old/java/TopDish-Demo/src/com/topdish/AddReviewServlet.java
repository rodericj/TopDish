package com.topdish;

import java.io.IOException;

import javax.jdo.PersistenceManager;
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
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

public class AddReviewServlet extends HttpServlet {
	private static final long serialVersionUID = 4487912407733775656L;
	private BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		long dishID = 0;
		String dishIDs = req.getParameter("dishID");
		Dish dish = null;
		String rating = "";
		String comment = "";
		int direction = 0;
		Photo photo = null;
		BlobKey blobKey = null;

		try {
			blobKey = blobstoreService.getUploadedBlobs(req).get("myFile");
		} catch (Exception e) {
			System.out
					.println("Not from a Blob Upload. Must be a Dish Bio Review.");
		}

		if (req.getParameter("rating") != null) {
			rating = req.getParameter("rating");

			if (rating.equals("pos"))
				direction = Review.POSITIVE_DIRECTION;
			else
				direction = Review.NEGATIVE_DIRECTION;
		}

		if (req.getParameter("comment") != null)
			comment = req.getParameter("comment");

		try {
			dishID = Long.parseLong(dishIDs);
		} catch (NullPointerException e) {
			// not a long
		}

		try {
			TDUser creator = TDUserService.getUser(pm);
			dish = pm.getObjectById(Dish.class, dishID);
			Review review = new Review(dish.getKey(), direction, comment,
					creator.getKey());

			pm.makePersistent(review);
			dish.addReview(review);

			if (blobKey != null) {
				System.out.println("Blob Found.");
				// user added a photo for the dish
				photo = new Photo(blobKey, "", creator.getKey());
				pm.makePersistent(photo);
				dish.addPhoto(photo.getKey());
				// DEBUG:
				System.out.println("photo added: " + photo.getKey().getId());
			}

			pm.makePersistent(dish);
			creator.addReview(review);
			pm.makePersistent(creator);

			resp.sendRedirect("dishDetail.jsp?dishID=" + dishID);
		} catch (UserNotLoggedInException e) {
			// forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			String url = "../addReview.jsp?dishID=" + dishID + "&dir="
					+ direction;
			url += "&comment=" + comment;
			resp.sendRedirect(userService.createLoginURL(url));
		} catch (UserNotFoundException e) {
			// do nothing
		} finally {
			pm.close();
		}
	}
}