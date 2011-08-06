package com.topdish.adminconsole.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.adminconsole.TopDishConstants;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDPersistable;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TagUtils;

public class TopDishExplorerServlet extends HttpServlet {
	private static final long serialVersionUID = 3305214228504501522L;

	private static final String TAG = TopDishExplorerServlet.class.getSimpleName();

	private int displaySize;

	@Override
	public void init(ServletConfig config) throws ServletException {

		super.init(config);
		try {
			this.displaySize = Integer.parseInt(getServletConfig().getInitParameter("displaySize"));
		} catch (Exception e) {
			e.printStackTrace();
			this.displaySize = 20;
			System.err.println("ERROR: disp size:::: " + displaySize);
		}
	}

	private static void searchRestaurant(HttpServletRequest req, HttpServletResponse resp,
			String callType) {
		List<Restaurant> restList;
		String restName = req.getParameter("restName");
		restList = search(restName, new Restaurant());

		List<Restaurant> restL = new ArrayList<Restaurant>();
		if (null != restList) {
			for (Restaurant r : restList) {
				restL.add(r);
			}
		}
		req.getSession().setAttribute("restList", restL);
		if (null != callType && callType.trim().length() > 0
				&& callType.equals(TopDishConstants.CALL_TYPE_NONAJAX)) {
			try {
				req.getRequestDispatcher("explorer/restaurantExplorer.jsp").forward(req, resp);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static void searchReviews(HttpServletRequest req, HttpServletResponse resp,
			String callType) {
		// TL;DR: this code gets reviews for users based on
		// a user name
		String creatorName = req.getParameter("creatorName");

		final Set<Review> reviews = new HashSet<Review>();

		for (Key k : TDQueryUtils.getUserKeysByName(creatorName)) {
			reviews.addAll(TDQueryUtils.getReviewsByUser(k));
		}

		for (Review r : reviews) {
			final TDUser creator = Datastore.get(r.getCreator());
			final Dish dish = Datastore.get(r.getDish());
			r.setCreatorName(creator.getNickname());
			r.setDishName(dish.getName());
		}

		req.getSession(true).setAttribute("reviewList", reviews);

		if (null != callType && callType.trim().length() > 0
				&& callType.equals(TopDishConstants.CALL_TYPE_NONAJAX)) {
			try {
				req.getRequestDispatcher("explorer/reviewExplorer.jsp").forward(req, resp);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static void searchTags(HttpServletRequest req, HttpServletResponse resp, String callType) {
		int i = 0;
		String queryS = "", paramS = "";
		List<Object> termList = new ArrayList<Object>();

		boolean filterExists = false;

		List<Tag> tagList;
		String tagName = req.getParameter("tagName");
		String type = req.getParameter("type");

		if (null != tagName && tagName.trim().length() > 0) {
			tagName = tagName.toLowerCase();
			String[] qWords = tagName.split(" ");

			for (int c = 0; c < qWords.length; c++) {
				termList.add(qWords[c].toLowerCase());
			}

			for (int count = 0; count < qWords.length; count++) {
				if (count > 0) {
					queryS += " && searchTerms.contains(s" + i + ")";
				} else {
					queryS += "searchTerms.contains(s" + i + ")";
				}
				i++;
			}

			filterExists = true;
		}
		if (null != type && type.trim().length() > 0) {
			if (filterExists) {
				queryS += " && type==param";
			} else {
				queryS += "type==param";
			}

			filterExists = true;
		}

		if (filterExists) {
			for (int j = 0; j < termList.size(); j++) {
				if (paramS.length() > 0) {
					paramS += ", String s" + j;
				} else {
					paramS += "String s" + j;
				}

			}
			// for tag type
			if (null != type && type.trim().length() > 0) {
				termList.add(Integer.parseInt(type));
				if (paramS.length() > 0) {
					paramS += ", int param";
				} else {
					paramS += "int param";
				}
			}
			tagList = (List<Tag>) TDQueryUtils.searchAllEntities(termList, queryS, paramS,
					new Tag());
		} else {
			tagList = new ArrayList<Tag>(Datastore.getAll(new Tag()));
		}

		if (null != tagList) {
			for (Tag tag : tagList) {
				TDUser userObj = null;
				try {
					userObj = Datastore.get(tag.getCreator());
				} catch (Exception e) {
					System.err.println("User does not exists");
					e.printStackTrace();
				}
				if (null != userObj) {
					if (null == tag.getCreatorName()
							|| (null != tag.getCreatorName() && tag.getCreatorName().trim()
									.length() == 0))
						tag.setCreatorName(userObj.getNickname().toString());
				}
				tag.setTypeString(tag.getTagTypeName());
			}
		}
		req.getSession(true).setAttribute("tagList", tagList);
		if (null != callType && callType.trim().length() > 0
				&& callType.equals(TopDishConstants.CALL_TYPE_NONAJAX)) {
			try {
				req.getRequestDispatcher("explorer/tagExplorer.jsp").forward(req, resp);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static void searchDishes(HttpServletRequest req, HttpServletResponse resp,
			String callType) {
		Logger.getLogger(TAG).info("Starting searchDishes");

		String dishName = req.getParameter("dishName");

		Logger.getLogger(TAG).info("Search query: " + dishName);

		List<Dish> dishL = new ArrayList<Dish>(search(dishName, new Dish()));

		if (null != dishL) {
			for (Dish d : dishL) {
				Logger.getLogger(TAG).info("Getting additional info for dish: " + d.getName());
				TDUser userObj = null;
				try {
					userObj = Datastore.get(d.getCreator());
				} catch (Exception e) {
					System.err.println("User does not exists");
					e.printStackTrace();
				}
				if (null != userObj) {
					if (null == d.getCreatorName()
							|| (null != d.getCreatorName() && d.getCreatorName().trim().length() == 0))
						d.setCreatorName(userObj.getNickname().toString());
				}
				int totalReviews = d.getNumPosReviews() + d.getNumNegReviews();
				d.setTotalReviews(totalReviews);
				try {
					final Set<Tag> tags = Datastore.get(d.getTags());
					d.setTagString(TagUtils.formatTagString(new ArrayList<Tag>(tags)));
				} catch (Exception e) {
					Logger.getLogger(TAG).error(e);
				}
			}
		}
		Logger.getLogger(TAG).info("Putting results in the Session");

		req.getSession(true).setAttribute("dishList", dishL);
		if (null != callType && callType.trim().length() > 0
				&& callType.equals(TopDishConstants.CALL_TYPE_NONAJAX)) {
			Logger.getLogger(TAG).info("Sending response to redirector?");
			try {
				req.getRequestDispatcher("explorer/dishExplorer.jsp").forward(req, resp);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static void search(HttpServletRequest req, HttpServletResponse resp, String callType) {
		// if search
		String entity = req.getParameter("entity");
		Logger.getLogger(TAG).info("Entity: " + entity);

		if (null != entity && entity.trim().length() > 0) {
			if (entity.equals(TopDishConstants.ENTITY_RESTAURANT)) {
				Logger.getLogger(TAG).info("Action: Search Restaurants");
				searchRestaurant(req, resp, callType);
			} else if (entity.equals(TopDishConstants.ENTITY_REVIEWS)) {
				Logger.getLogger(TAG).info("Action: Search Reviews");
				searchReviews(req, resp, callType);
			} else if (entity.equals(TopDishConstants.ENTITY_TAGS)) {
				Logger.getLogger(TAG).info("Action: Search Tags");
				searchTags(req, resp, callType);
			} else if (entity.equals(TopDishConstants.ENTITY_DISH)) {
				Logger.getLogger(TAG).info("Action: Search Dishes");
				searchDishes(req, resp, callType);
			} else {
				Logger.getLogger(TAG).info("Action: FREAK OUT!");
				try {
					resp.sendRedirect("/");
				} catch (IOException e) {
					e.printStackTrace();
				}
				return;
			}
		}
	}

	private static void rstrDishes(HttpServletRequest req, HttpServletResponse resp, String callType) {
		// restaurant wise dishes
		String restId = req.getParameter("restID");
		long restID = Long.valueOf(restId);
		Restaurant restaurant = Datastore.get(KeyFactory.createKey(
				Restaurant.class.getSimpleName(), restID));
		List<Dish> dishList = new ArrayList<Dish>(TDQueryUtils.getDishesByRestaurant(restaurant
				.getKey()));
		List<Dish> dishL = new ArrayList<Dish>();
		if (null != dishList) {
			for (Dish d : dishList) {
				TDUser userObj = null;
				try {
					userObj = Datastore.get(d.getCreator());
				} catch (Exception e) {
					System.err.println("User does not exists");
					e.printStackTrace();
				}
				if (null != userObj) {
					if (null == d.getCreatorName()
							|| (null != d.getCreatorName() && d.getCreatorName().trim().length() == 0))
						d.setCreatorName(userObj.getNickname().toString());
				}

				int totalReviews = d.getNumPosReviews() + d.getNumNegReviews();
				d.setTotalReviews(totalReviews);
				final Set<Tag> tags = Datastore.get(d.getTags());
				d.setTagString(TagUtils.formatTagString(new ArrayList<Tag>(tags)));
				dishL.add(d);
			}
		}
		req.getSession(true).setAttribute("dishList", dishL);
		if (callType == null) {
			callType = "";
		}
		if (!callType.equals(TopDishConstants.CALL_TYPE_AJAX)) {
			try {
				req.getRequestDispatcher("explorer/dishExplorer.jsp").forward(req, resp);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static void viewRestaurant(HttpServletRequest req, HttpServletResponse resp,
			String callType) {
		// restaurant wise dishes
		String restId = req.getParameter("restID");
		long restID = Long.valueOf(restId);
		Restaurant rest = Datastore.get(KeyFactory.createKey(Restaurant.class.getSimpleName(),
				restID));
		List<Restaurant> restL = new ArrayList<Restaurant>();
		if (null != rest)
			restL.add(rest);
		req.getSession(true).setAttribute("restList", restL);
		if (callType == null) {
			callType = "";
		}
		if (!callType.equals(TopDishConstants.CALL_TYPE_AJAX)) {
			try {
				req.getRequestDispatcher("explorer/restaurantExplorer.jsp").forward(req, resp);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static void viewReview(HttpServletRequest req, HttpServletResponse resp, String callType) {
		// restaurant wise dishes
		String reviewId = req.getParameter("reviewID");
		long reviewID = Long.valueOf(reviewId);
		Review review = Datastore.get(KeyFactory.createKey(Review.class.getSimpleName(), reviewID));
		List<Review> reviewL = new ArrayList<Review>();
		if (null != review) {
			TDUser userObj = null;
			try {
				userObj = Datastore.get(review.getCreator());
			} catch (Exception e) {
				System.err.println("User does not exists");
				e.printStackTrace();
			}
			if (null != userObj) {
				if (null == review.getCreatorName()
						|| (null != review.getCreatorName() && review.getCreatorName().trim()
								.length() == 0))
					review.setCreatorName(userObj.getNickname().toString());
			}
			if (null != review.getDish()) {
				try {
					Dish dish = Datastore.get(review.getDish());
					if (dish != null)
						review.setDishName(dish.getName());
				} catch (Exception e) {
					System.err.println("Dish does not exists");
					e.printStackTrace();
				}
			}
			reviewL.add(review);
		}

		req.getSession(true).setAttribute("reviewList", reviewL);
		if (callType == null) {
			callType = "";
		}
		if (!callType.equals(TopDishConstants.CALL_TYPE_AJAX)) {
			try {
				req.getRequestDispatcher("explorer/reviewExplorer.jsp").forward(req, resp);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static void viewPhoto(HttpServletRequest req, HttpServletResponse resp, String callType) {
		// restaurant wise dishes
		String photoId = req.getParameter("photoID");
		long photoID = Long.valueOf(photoId);
		Photo photo = Datastore.get(KeyFactory.createKey(Photo.class.getSimpleName(), photoID));
		Dish dish = TDQueryUtils.getDishByPhoto(photo.getKey());
		List<Dish> dishL = new ArrayList<Dish>();

		if (null != dish) {
			TDUser userObj = null;
			try {
				userObj = Datastore.get(dish.getCreator());
			} catch (Exception e) {
				System.err.println("User does not exists");
				e.printStackTrace();
			}
			if (null != userObj) {
				if (null == dish.getCreatorName()
						|| (null != dish.getCreatorName() && dish.getCreatorName().trim().length() == 0))
					dish.setCreatorName(userObj.getNickname().toString());
			}

			int totalReviews = dish.getNumPosReviews() + dish.getNumNegReviews();
			dish.setTotalReviews(totalReviews);
			final Set<Tag> tags = Datastore.get(dish.getTags());
			dish.setTagString(TagUtils.formatTagString(new ArrayList<Tag>(tags)));

			dishL.add(dish);
		}

		req.getSession(true).setAttribute("dishList", dishL);
		if (callType == null) {
			callType = "";
		}
		if (!callType.equals(TopDishConstants.CALL_TYPE_AJAX)) {
			try {
				req.getRequestDispatcher("explorer/dishExplorer.jsp").forward(req, resp);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static void viewDishes(HttpServletRequest req, HttpServletResponse resp, String callType) {
		String dishId = req.getParameter("dishID");
		long dishID = Long.valueOf(dishId);
		Dish dish = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), dishID));
		List<Dish> dishL = new ArrayList<Dish>();
		if (null != dish) {
			TDUser userObj = null;
			try {
				userObj = Datastore.get(dish.getCreator());
			} catch (Exception e) {
				System.err.println("User does not exists");
				e.printStackTrace();
			}
			if (null != userObj) {
				if (null == dish.getCreatorName()
						|| (null != dish.getCreatorName() && dish.getCreatorName().trim().length() == 0))
					dish.setCreatorName(userObj.getNickname().toString());
			}

			int totalReviews = dish.getNumPosReviews() + dish.getNumNegReviews();
			dish.setTotalReviews(totalReviews);
			final Set<Tag> tags = Datastore.get(dish.getTags());
			dish.setTagString(TagUtils.formatTagString(new ArrayList<Tag>(tags)));
			dishL.add(dish);
		}

		req.getSession(true).setAttribute("dishList", dishL);
		if (callType == null) {
			callType = "";
		}
		if (!callType.equals(TopDishConstants.CALL_TYPE_AJAX)) {
			try {
				req.getRequestDispatcher("explorer/dishExplorer.jsp").forward(req, resp);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static void dishReviews(HttpServletRequest req, HttpServletResponse resp,
			String callType) {
		// restaurant wise dishes
		String dishStrID = req.getParameter("dishID");
		long dishID = Long.valueOf(dishStrID);
		final Dish dish = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), dishID));
		List<Review> reviewList = new ArrayList<Review>(
				TDQueryUtils.getReviewsByDish(dish.getKey()));
		List<Review> reviewL = new ArrayList<Review>();
		if (null != reviewList) {
			for (Review r1 : reviewList) {
				TDUser userObj = null;
				try {
					userObj = Datastore.get(r1.getCreator());
				} catch (Exception e) {
					System.err.println("User does not exists");
					e.printStackTrace();
				}
				if (null != userObj) {
					if (null == r1.getCreatorName()
							|| (null != r1.getCreatorName() && r1.getCreatorName().trim().length() == 0))
						r1.setCreatorName(userObj.getNickname().toString());
				}
				if (null != r1.getDish()) {
					try {
						if (dish != null)
							r1.setDishName(dish.getName());
					} catch (Exception e) {
						System.err.println("Dish does not exists");
						e.printStackTrace();
					}
				}
				reviewL.add(r1);
			}
		}
		req.getSession(true).setAttribute("reviewList", reviewL);
		if (callType == null) {
			callType = "";
		}
		if (!callType.equals(TopDishConstants.CALL_TYPE_AJAX)) {
			try {
				req.getRequestDispatcher("explorer/reviewExplorer.jsp").forward(req, resp);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String callType = req.getParameter("callType");
		if (null == callType) {
			callType = TopDishConstants.CALL_TYPE_NONAJAX;
		}
		try {
			req.getSession().setAttribute("displaySize", displaySize);
			String action = req.getParameter("action");

			Logger.getLogger(TAG).info("Action: " + action + ", calltype: " + callType);

			if (null != action && action.trim().length() > 0) {
				if (action.equals(TopDishConstants.ACTION_SEARCH)) {
					search(req, resp, callType);
				} else if (action.equals(TopDishConstants.ACTION_RSTRDISHES)) {
					rstrDishes(req, resp, callType);
				} else if (action.equals(TopDishConstants.ACTION_VIEWRESTAURANT)) {
					viewRestaurant(req, resp, callType);
				} else if (action.equals(TopDishConstants.ACTION_VIEWREVIEW)) {
					viewReview(req, resp, callType);
				} else if (action.equals(TopDishConstants.ACTION_VIEWPHOTO)) {
					viewPhoto(req, resp, callType);
				} else if (action.equals(TopDishConstants.ACTION_VIEWDISHES)) {
					viewDishes(req, resp, callType);
				} else if (action.equals(TopDishConstants.ACTION_DISHREVIEWS)) {
					dishReviews(req, resp, callType);
				}
			}
		} catch (Exception e) {
			System.err.println("Error:" + e.getMessage());
			e.printStackTrace();
		}
	}

	private static <T extends TDPersistable> List<T> search(String searchName, T t) {
		Logger.getLogger(TAG).info("Starting search for type " + t.getClass().getSimpleName());

		int i = 0;
		String queryS = "", paramS = "";
		List<Object> termList = new ArrayList<Object>();
		boolean filterExists = false;

		if (null != searchName && searchName.trim().length() > 0) {
			searchName = searchName.toLowerCase();
			String[] qWords = searchName.split(" ");

			for (int c = 0; c < qWords.length; c++) {
				termList.add(qWords[c].toLowerCase());
			}

			for (int count = 0; count < qWords.length; count++) {
				if (count > 0) {
					queryS += " && searchTerms == s" + i;
				} else {
					queryS += "searchTerms == s" + i;
				}
				i++;
			}

			filterExists = true;
		}

		if (filterExists) {
			for (int j = 0; j < termList.size(); j++) {
				if (paramS.length() > 0) {
					paramS += ", String s" + j;
				} else {
					paramS += "String s" + j;
				}
			}

			Logger.getLogger(TAG).info(
					"Search params are termList: " + termList + " queryS: " + queryS + " paramS: "
							+ paramS);

			return (List<T>) TDQueryUtils.searchAllEntities(termList, queryS, paramS, t);
		} else {
			Logger.getLogger(TAG).info("Gave up and returning EVERYTHING");
			return new ArrayList<T>(Datastore.getAll(t));
		}
	}

	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		doPost(req, resp);
	}
}
