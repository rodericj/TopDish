package com.topdish;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

public class AddReviewServlet extends HttpServlet {
	private static final long serialVersionUID = 4487912407733775656L;
	private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		if (!TDUserService.isUserLoggedIn(req.getSession(true))) {
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}

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
			System.out.println("Not from a Blob Upload. Must be a Dish Bio Review.");
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
			final TDUser creator = TDUserService.getUser(req.getSession());

			// check if user has created review for same dish within the last 24
			// hours
			final Key dishKey = KeyFactory.createKey(Dish.class.getSimpleName(), dishID);
			if (null != dishKey) {
				final Key lastReviewKey = TDQueryUtils.getLatestReviewKeyByUserDish(
						creator.getKey(), dishKey);
				if (null != lastReviewKey) {
					final Review lastReview = Datastore.get(lastReviewKey);
					final int oneDay = 1000 * 60 * 60 * 24;
					if (lastReview.getDateCreated().after(
							new Date(System.currentTimeMillis() - oneDay))) {

						// within last 24 hours, skip and return an error
						Alerts.setError(req, Alerts.RATE_DISH_ONCE_PER_DAY);
						resp.sendRedirect("dishDetail.jsp?dishID=" + dishKey.getId());
						return;
					}
				}
			}

			dish = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), dishID));
			final Review review = new Review(dish.getKey(), direction, comment, creator.getKey());

			Datastore.put(review);
			dish.addReview(review);

			if (blobKey != null) {
				System.out.println("Blob Found.");
				// user added a photo for the dish
				photo = new Photo(blobKey, "", creator.getKey());
				Datastore.put(photo);
				dish.addPhoto(photo.getKey());
				// DEBUG:
				System.out.println("photo added: " + photo.getKey().getId());
			}

			Datastore.put(dish);
			creator.addReview(review);
			Datastore.put(creator);

			Alerts.setInfo(req, Alerts.REVIEW_ADDED);
			resp.sendRedirect("dishDetail.jsp?dishID=" + dishID);
			return;
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