package com.topdish;

import java.io.IOException;
import java.util.Date;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletException;
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
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

public class RateDishServlet extends HttpServlet {
	private static final long serialVersionUID = -6242328863763029283L;
	private BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();

	private static boolean DEBUG = false;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		if(!TDUserService.isUserLoggedIn(req.getSession(true))){
			resp.sendRedirect("login.jsp");
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			return;
		}
		
		Restaurant rest = null;
		// Add dish (if new) and add review
		String restIDs = req.getParameter("restID");
		String dishName = req.getParameter("dishName");
		String dishIDs = req.getParameter("dishID");
		String dishDesc = req.getParameter("dishDesc");
		String ratingS = req.getParameter("rating");
		String categoryIDs = req.getParameter("categoryID");
		String priceIDs = req.getParameter("priceID");
		String comments = req.getParameter("comments");

		Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
		BlobKey blobKey = blobs.get("myFile");

		long restID = 0;
		long dishID = 0;
		int rating = 0;
		long categoryID = 0;
		long priceID = 0;

		try {
			restID = Long.parseLong(restIDs);
		} catch (NumberFormatException e) {
			// not a long
		}
		try {
			dishID = Long.parseLong(dishIDs);
		} catch (NumberFormatException e) {
			// not a long
		}
		try {
			rating = Integer.parseInt(ratingS);
		} catch (NumberFormatException e) {
			// not an integer
		}
		try {
			categoryID = Long.parseLong(categoryIDs);
		} catch (NumberFormatException e) {
			// not a long
		}
		try {
			priceID = Long.parseLong(priceIDs);
		} catch (NumberFormatException e) {
			// not a long
		}

		try {
			TDUser creator = TDUserService.getUser(req.getSession());
			
			Key dishKey = null;
			Dish dish = null;
			Review rev = null;

			if (rest == null) {
				// restaurant exists in our DB
				rest = Datastore.get(KeyFactory.createKey(
						Restaurant.class.getSimpleName(), restID));
			}
			if (dishID > 0) {
				// find dish in data store
				dishKey = KeyFactory.createKey(Dish.class.getSimpleName(), dishID);
				dish = Datastore.get(dishKey);
			} else {
				// add dish in data store
				Set<Key> keysToAdd = new HashSet<Key>();

				Tag category = null;
				Tag price = null;
				if (categoryID > 0) {
					category = Datastore.get(KeyFactory.createKey(
							Tag.class.getSimpleName(), categoryID));

					if (DEBUG)
						System.out.println("Found category: "
								+ category.getKey());
				}
				if (priceID > 0) {
					price = Datastore.get(KeyFactory.createKey(
							Tag.class.getSimpleName(), priceID));

					if (DEBUG)
						System.out.println("Found price: " + price.getKey());
				}

				if (DEBUG)
					System.out.println("creating dish: " + dishName);

				dish = new Dish(dishName, dishDesc, rest, creator.getKey(), keysToAdd);
				dish.setCategory(category.getKey());
				dish.setPrice(price.getKey());
				rest.addDish();

				Datastore.put(dish);
				Datastore.put(rest);

				if (DEBUG)
					System.out.println("dish added");
			}

			//check if user has created review for same dish within the last 24 hours
			if(null != dishKey){
				final Key lastReviewKey = TDQueryUtils.getLatestReviewKeyByUserDish(creator.getKey(), dishKey);
				if(null != lastReviewKey){
					final Review lastReview = Datastore.get(lastReviewKey);
					final int oneDay = 1000*60*60*24;
					if(lastReview.getDateCreated().after(new Date(System.currentTimeMillis() - oneDay))){
						//within last 24 hours, skip and return an error
						resp.sendRedirect("dishDetail.jsp?dishID=" + dishKey.getId());
						Alerts.setError(req, Alerts.RATE_DISH_ONCE_PER_DAY);
						return;
					}
				}
			}

			if (DEBUG)
				System.out.println("adding review");

			// add review
			rev = new Review(dish.getKey(), rating, comments, creator.getKey());

			if (blobKey != null) {
				// user added a photo for the dish
				Photo photo = new Photo(blobKey, "", creator.getKey());
				Datastore.put(photo);
				dish.addPhoto(photo.getKey());
				rev.setPhoto(photo.getKey());

				if (DEBUG)
					System.out
							.println("photo added: " + photo.getKey().getId());
			}

			Datastore.put(rev);

			if (DEBUG)
				System.out.println("review key: " + rev.getKey());

			dish.addReview(rev);

			if (DEBUG)
				System.out.println("review created");

			creator.addReview(rev);
			Datastore.put(creator);
			Datastore.put(dish);

			resp.sendRedirect("dishDetail.jsp?dishID=" + dish.getKey().getId());
			Alerts.setInfo(req, Alerts.DISH_ADDED);
			return;
		} catch (UserNotLoggedInException e) {
			// forward to login screen
			resp.sendRedirect("login.jsp");
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			return;
		} catch (UserNotFoundException e) {
			// forward to login screen
			resp.sendRedirect("login.jsp");
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			return;
		}
	}
}
