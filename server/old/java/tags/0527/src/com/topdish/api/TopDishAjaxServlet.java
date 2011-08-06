package com.topdish.api;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;

import com.beoui.geocell.model.Point;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.comparator.DishPosReviewsComparator;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Datastore;
import com.topdish.util.HumanTime;
import com.topdish.util.TDMathUtils;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

/**
 * Add a Top Dish Ajax Servlet for API
 * 
 */
public class TopDishAjaxServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 3305214228504501522L;

	// private static boolean DEBUG = false;

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = TopDishAjaxServlet.class.getSimpleName();

	@Override
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		Logger.getLogger(TAG).info("an ajax call was made!");

		boolean namesAdded = false;
		StringBuilder sb = new StringBuilder();
		int maxResults = 10;
		double maxDistance = 0.0; // meters // using 0 will return all distances
		// up to max # of results

		double lat = 0.0;
		double lng = 0.0;

		String callType = req.getParameter("callType");
		String cuisine = req.getParameter("cuisineID");
		String category = req.getParameter("categoryID");
		String price = req.getParameter("priceID");
		String lifestyle = req.getParameter("lifestyleID");
		String distanceS = req.getParameter("distance");
		String pageNumS = req.getParameter("page");

		// lat = Double.parseDouble(req.getParameter("lat"));
		// lng = Double.parseDouble(req.getParameter("lng"));
		String distString = req.getParameter("distance");
		if (null != distString && distString.length() > 0)
			maxDistance = Integer.parseInt(distString);
		maxResults = Integer.parseInt(req.getParameter("maxResults"));
		Point userLoc = TDUserService.getUserLocation(req);
		// TDPoint tdpoint=TDUserService.getUserLocation(req);
		lat = userLoc.getLat();
		lng = userLoc.getLon();

		long priceID = 0;
		long categoryID = 0;
		long lifestyleID = 0;
		long cuisineID = 0;
		int pageNum = 0;

		try {
			priceID = Long.parseLong(price);

			Logger.getLogger(TAG).info("price found: " + priceID);
		} catch (NumberFormatException e) {
			// not a long
			// e.printStackTrace();
			Logger.getLogger(TAG).error(e.getMessage());
		}
		try {
			cuisineID = Long.parseLong(cuisine);

			Logger.getLogger(TAG).info("cuisine found: " + cuisineID);
		} catch (NumberFormatException e) {
			// not a long
			// e.printStackTrace();
			Logger.getLogger(TAG).error(e.getMessage());
		}
		try {
			categoryID = Long.parseLong(category);

			Logger.getLogger(TAG).info("category found: " + categoryID);
		} catch (NumberFormatException e) {
			// not a long
			// e.printStackTrace();
			Logger.getLogger(TAG).error(e.getMessage());
		}
		try {
			maxDistance = Double.parseDouble(distanceS);

			Logger.getLogger(TAG).info("distance found: " + maxDistance);
		} catch (NumberFormatException e) {
			// not a long
			// e.printStackTrace();
			Logger.getLogger(TAG).error(e.getMessage());
		}
		try {
			lifestyleID = Long.parseLong(lifestyle);

			Logger.getLogger(TAG).info("lifestyle found: " + lifestyleID);
		} catch (NumberFormatException e) {
			// not a long
			// e.printStackTrace();
			Logger.getLogger(TAG).error(e.getMessage());
		}
		try {
			pageNum = Integer.parseInt(pageNumS);

			Logger.getLogger(TAG).info("page number found: " + pageNum);
		} catch (NumberFormatException e) {
			// not a long
			// e.printStackTrace();
			Logger.getLogger(TAG).error(e.getMessage());
		}

		// compute distance from miles to meters
		maxDistance *= 1609.334;

		Tag categoryTag = null;
		Tag priceTag = null;
		Tag lifestyleTag = null;
		Tag cuisineTag = null;
		final Set<Key> tagKeysToFilter = new HashSet<Key>();

		if (category != null && !category.equals("")) {
			categoryTag = Datastore
					.get(KeyFactory.createKey(Tag.class.getSimpleName(), categoryID));
			tagKeysToFilter.add(categoryTag.getKey());
		}

		if (price != null && !price.equals("")) {
			priceTag = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), priceID));
			tagKeysToFilter.add(priceTag.getKey());
		}

		if (lifestyle != null && !lifestyle.equals("")) {
			lifestyleTag = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(),
					lifestyleID));
			tagKeysToFilter.add(lifestyleTag.getKey());
		}
		if (cuisine != null && !cuisine.equals("")) {
			cuisineTag = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), cuisineID));
			tagKeysToFilter.add(cuisineTag.getKey());
		}

		final String query = req.getParameter("searchWord");
		List<Dish> dishResults = null;

		if (null != query && !query.isEmpty()) {
			// Search the data with a query text
			dishResults = TDQueryUtils.searchGeoItemsWithFilter(query.split(","), new Point(lat,
					lng), maxResults, maxDistance, new Dish(), pageNum * maxResults,
					new ArrayList<Key>(tagKeysToFilter), new DishPosReviewsComparator());
		} else {
			// Search without the query
			dishResults = new ArrayList<Dish>(TDQueryUtils.filterDishes(maxResults,
					tagKeysToFilter, maxDistance, lat, lng, pageNum * maxResults));
			Collections.sort(dishResults, new DishPosReviewsComparator());
		}

		if (null != dishResults && dishResults.size() > 0) {
			Logger.getLogger(TAG).info("result set size: " + dishResults.size());

			sb.append("<DishSearch>");
			sb.append("<count>" + pageNum + "</count>");
			sb.append("<Dishes>");
			namesAdded = true;
			// final List<Dish> toDisplay = new ArrayList<Dish>(dishResults);
			Collections.sort(dishResults, new DishPosReviewsComparator());
			for (final Dish dish : dishResults) {
				Restaurant r = Datastore.get(dish.getRestaurant());
				Collection<Tag> tags = Datastore.get(dish.getTags());
				Photo dishPhoto = null;

				if (dish.getPhotos() != null && dish.getPhotos().size() > 0) {
					dishPhoto = Datastore.get(dish.getPhotos().get(0));
				}

				int vote = 0;
				try {
					if (TDUserService.isUserLoggedIn(req.getSession())) {
						final TDUser tdUser = TDUserService.getUser(req.getSession());
						vote = TDQueryUtils.getLatestUserVoteByDish(tdUser.getKey(), dish.getKey());
					}
				} catch (UserNotFoundException e) {
					Logger.getLogger(TAG).error(e.getMessage());
				} catch (UserNotLoggedInException e) {
					Logger.getLogger(TAG).error(e.getMessage());
				}

				BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
				String blobUploadURL = blobstoreService.createUploadUrl("/addReview");

				sb.append("<Dish>");
				sb.append("<blobUploadURL>" + blobUploadURL + "</blobUploadURL>");
				sb.append("<keyId>" + dish.getKey().getId() + "</keyId>");
				sb.append("<name>" + StringEscapeUtils.escapeHtml(dish.getName()) + "</name>");
				sb.append("<description>" + StringEscapeUtils.escapeHtml(dish.getDescription())
						+ "</description>");
				sb.append("<distance>"
						+ TDMathUtils.formattedGeoPtDistanceMiles(userLoc, dish.getLocation())
						+ "</distance>");
				boolean isEditable = false;

				if (TDUserService.isAdmin()) {
					isEditable = true;
				} else
					isEditable = TDQueryUtils.isAccessible(Long.valueOf(dish.getKey().getId()),
							new Dish());
				if (isEditable)
					sb.append("<allowEdit>T</allowEdit>");
				else
					sb.append("<allowEdit>F</allowEdit>");
				if (TDUserService.isUserLoggedIn(req.getSession())) {
					sb.append("<userLoggedIn>L</userLoggedIn>");
				} else {
					sb.append("<userLoggedIn>O</userLoggedIn>");
				}
				if (null != dishPhoto) {
					try {
						final String url = dishPhoto.getURL(98);
						sb.append("<blobKey>" + url + "</blobKey>");
						sb.append("<photoExist>E</photoExist>");
					} catch (Exception e) {
						Logger.getLogger(TAG).error(e.getMessage(), e);
						sb.append("<blobKey></blobKey>");
						sb.append("<photoExist>NE</photoExist>");
					}
				} else {
					sb.append("<blobKey></blobKey>");
					sb.append("<photoExist>NE</photoExist>");
				}
				sb.append("<restAddrLine1>" + StringEscapeUtils.escapeHtml(r.getAddressLine1())
						+ "</restAddrLine1>");
				sb.append("<restCity>" + StringEscapeUtils.escapeHtml(r.getCity()) + "</restCity>");
				sb.append("<restState>" + StringEscapeUtils.escapeHtml(r.getState())
						+ "</restState>");
				sb.append("<restId>" + r.getKey().getId() + "</restId>");
				sb.append("<restName>" + StringEscapeUtils.escapeHtml(r.getName()) + "</restName>");
				sb.append("<restNeighbourhood>" + StringEscapeUtils.escapeHtml(r.getNeighborhood())
						+ "</restNeighbourhood>");
				// sb.append("<location>" + dish.getLocation() + "</location>");
				sb.append("<latitude>" + dish.getLocation().getLat() + "</latitude>");
				sb.append("<longitude>" + dish.getLocation().getLon() + "</longitude>");
				sb.append("<posReviews>" + dish.getNumPosReviews() + "</posReviews>");
				sb.append("<negReviews>" + dish.getNumNegReviews() + "</negReviews>");
				String voteString = "LTE0";
				if (vote > 0)
					voteString = "GT0";
				else if (vote < 0)
					voteString = "LT0";
				sb.append("<voteString>" + voteString + "</voteString>");
				if (tags != null && !tags.isEmpty()) {
					sb.append("<tagsEmpty>NE</tagsEmpty>");
				} else
					sb.append("<tagsEmpty>E</tagsEmpty>");
				sb.append("<Tags>");
				for (Tag tag : tags) {
					sb.append("<tag><tagName>" + StringEscapeUtils.escapeHtml(tag.getName())
							+ "</tagName></tag>");
				}
				sb.append("</Tags>");
				Key lastReviewKey = TDQueryUtils.getLatestReviewKeyByDish(dish.getKey());
				if (null != lastReviewKey) {
					final Review lastReview = Datastore.get(lastReviewKey);
					if (lastReview.getDirection() == Review.POSITIVE_DIRECTION) {
						sb.append("<lastReviewType>P</lastReviewType>");
					} else
						sb.append("<lastReviewType>N</lastReviewType>");
					sb.append("<lastReview>"
							+ HumanTime.approximately(System.currentTimeMillis()
									- lastReview.getDateCreated().getTime()) + "</lastReview>");
				} else {
					sb.append("<lastReviewType>E</lastReviewType>");
				}
				sb.append("<numReview>" + dish.getNumReviews() + "</numReview>");

				sb.append("</Dish>");

			}
			sb.append("</Dishes>");

			sb.append("</DishSearch>");
		} else {
			namesAdded = true;
			sb.append("<dishMesg>No records found</dishMesg>");
		}

		if (namesAdded) {
			resp.setContentType("text/xml");
			resp.getWriter().write("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" + sb.toString());
		} else {
			resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
		}
	}
}
