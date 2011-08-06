package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.jdo.PersistenceManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

public class RateDishServlet extends HttpServlet {
	private static final long serialVersionUID = -6242328863763029283L;
	private BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();
	
	private static boolean DEBUG = false;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		String goYelp = req.getParameter("isYelp");
		Restaurant rest = null;

		if (goYelp.equals("true")) {
			// user selected a yelp response
			String name = req.getParameter("yelpName");
			String addressLine1 = req.getParameter("yelpAddress1");
			String addressLine2 = req.getParameter("yelpAddress2");
			String city = req.getParameter("yelpCity");
			String state = req.getParameter("yelpState");
			String neighborhood = "";
			String latS = req.getParameter("yelpLatitude");
			String lngS = req.getParameter("yelpLongitude");
			double lat = 0;
			double lng = 0;

			try {
				lat = Double.parseDouble(latS);
			} catch (NumberFormatException e) {
				// not a double
			}
			try {
				lng = Double.parseDouble(lngS);
			} catch (NumberFormatException e) {
				// not a double
			}
			PhoneNumber phone = new PhoneNumber(req.getParameter("yelpPhone"));
			String gid = req.getParameter("yelpID");
			Link url = new Link(req.getParameter("yelpURL"));
			Date created = new Date();

			try {
				TDUser creator = TDUserService.getUser(pm);

				rest = new Restaurant(name, addressLine1, addressLine2, city,
						state, neighborhood, lat, lng, phone, gid, url,
						created, creator.getKey());
				pm.makePersistent(rest);
			} catch (UserNotLoggedInException e) {
				// forward to log in screen
				UserService userService = UserServiceFactory.getUserService();
				String return_url = "../rateDish.jsp";
				resp.sendRedirect(userService.createLoginURL(return_url));
			} catch (UserNotFoundException e) {
				// do nothing
			}
		}

		// Add dish (if new) and add review

		String restIDs = req.getParameter("restID");
		String dishName = req.getParameter("dishName");
		String dishIDs = req.getParameter("dishID");
		String dishDesc = req.getParameter("dishDesc");
		String ratingS = req.getParameter("rating");
		// String ingList = req.getParameter("ingList");
		// String tagList = req.getParameter("tagList");
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
			TDUser creator = TDUserService.getUser(pm);
			Dish dish = null;
			Review rev = null;
			Date dateCreated = new Date();

			if (rest == null) {
				// restaurant exists in our DB
				rest = pm.getObjectById(Restaurant.class, restID);
			}
			if (dishID > 0) {
				// find dish in data store
				dish = pm.getObjectById(Dish.class, dishID);

				if(DEBUG)
					System.out.println("dish found: " + dish.getName());
			} else {
				// add dish in data store
				List<Key> keysToAdd = new ArrayList<Key>();

				Tag category = null;
				Tag price = null;
				if (categoryID > 0) {
					category = pm.getObjectById(Tag.class, categoryID);
					
					if(DEBUG)
						System.out.println("Found category: " + category.getKey());
				}
				if (priceID > 0) {
					price = pm.getObjectById(Tag.class, priceID);
					
					if(DEBUG)
						System.out.println("Found price: " + price.getKey());
				}

				// List<Key> tagKeys = null;
				// List<Key> ingKeys = null;
				// if(tagList != null && !tagList.equals("")){
				// tagKeys = TagUtils.getTags(pm, tagList, Tag.TYPE_GENERAL);
				// }
				// if(ingList != null && !ingList.equals("")){
				// ingKeys = TagUtils.getTags(pm, ingList, Tag.TYPE_INGREDIENT);
				// }

				if(DEBUG)
					System.out.println("creating dish: " + dishName);
				// System.out.println("tag list: " + tagList);
				// System.out.println("ing list: " + ingList);

				dish = new Dish(dishName, dishDesc, rest.getKey(),
						rest.getCity(), rest.getState(),
						rest.getNeighborhood(), rest.getLatitude(),
						rest.getLongitude(), rest.getName(), dateCreated,
						creator.getKey(), keysToAdd);
				dish.setCategory(category.getKey());
				dish.setPrice(price.getKey());

				dish = pm.makePersistent(dish);
				rest.addDish(dish.getKey());
				
				if(DEBUG)
					System.out.println("dish added");
			}

			if(DEBUG)
				System.out.println("adding review");

			// add review
			rev = new Review(dish.getKey(), rating, comments, creator.getKey());
			
			if (blobKey != null) {
				// user added a photo for the dish
				Photo photo = new Photo(blobKey, "", creator.getKey());
				pm.makePersistent(photo);
				dish.addPhoto(photo.getKey());
				rev.setPhoto(photo.getKey());

				if(DEBUG)
					System.out.println("photo added: " + photo.getKey().getId());
			}
			
			rev = pm.makePersistent(rev);

			if(DEBUG)
				System.out.println("review key: " + rev.getKey());

			dish.addReview(rev);

			if(DEBUG)
				System.out.println("review created");

			creator.addReview(rev);
			pm.makePersistent(creator);

			dish = pm.makePersistent(dish);
			resp.sendRedirect("dishDetail.jsp?dishID=" + dish.getKey().getId());
		} catch (UserNotLoggedInException e) {
			// forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			String url = "../rateDish.jsp?restID=" + restIDs + "&dishName="
					+ dishName;
			url += "&dishID=" + dishIDs + "&dishDesc=" + dishDesc + "&rating="
					+ ratingS;
			url += "&comments=" + comments;
			resp.sendRedirect(userService.createLoginURL(url));
		} catch (UserNotFoundException e) {
			// do nothing
		} finally {
			pm.close();
		}
	}
}
