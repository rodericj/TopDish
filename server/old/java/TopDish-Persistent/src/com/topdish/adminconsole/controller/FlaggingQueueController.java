/**
 * 
 */
package com.topdish.adminconsole.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Flag;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

/**
 * This servlet acts as the main controller for all the requests coming for
 * Flagging Queue admin module.
 * 
 * @author nikhil_malleri
 * 
 */
public class FlaggingQueueController extends HttpServlet {
	private static final long serialVersionUID = 2131865029724247412L;

	private int displaySize;

	@Override
	public void init(ServletConfig config) throws ServletException {

		super.init(config);
		try {
			this.displaySize = Integer.parseInt(getServletConfig()
					.getInitParameter("displaySize"));
		} catch (Exception e) {
			e.printStackTrace();
			this.displaySize = 20;
			System.err.println("ERROR: disp size:::: " + displaySize);
		}
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// String action = req.getParameter("action") == null ? "" : req
		// .getParameter("action").trim();
		RequestDispatcher rd = null;

		rd = req.getRequestDispatcher("/admin/flags/main.jsp");
		rd.forward(req, resp);
	}

	@SuppressWarnings("unchecked")
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		int pageNo = 1;

		try {
			pageNo = req.getParameter("pg") == null ? 1 : Integer.parseInt(req
					.getParameter("pg"));
		} catch (Exception e) {
			pageNo = 1;
		}

		String action = req.getParameter("action") == null ? "" : req
				.getParameter("action").trim();
		String flagFor = req.getParameter("flagFor") == null ? null : req
				.getParameter("flagFor").trim();
		RequestDispatcher rd = null;
		PersistenceManager pm = PMF.get().getPersistenceManager();

		req.setAttribute("pageNo", pageNo);
		req.setAttribute("displaySize", displaySize);

		if (action.equalsIgnoreCase("showFlaggedItems")) { // if dish is
															// selected, show
															// all dishes which
															// were flagged.
															// Similarly for
															// restaurans,
															// photos and
															// reviews

			if (flagFor != null) {

				if (flagFor.equalsIgnoreCase("dish")) {

					ArrayList<Dish> dishList = new ArrayList<Dish>();
					ArrayList<Long> uniqueDishId = new ArrayList<Long>();

					Query query = pm.newQuery(Flag.class);
					query.setFilter("status==1 && flagFor=='dish'");
					List<Flag> flags = (List<Flag>) query.execute();

					for (int i = 0; i < flags.size(); i++) {
						Flag flag = flags.get(i);
						try {
							if (uniqueDishId.contains(flag.getDish().getId()))
								continue;
							else {
								uniqueDishId.add(flag.getDish().getId());
								try {
									Dish dish = (Dish) pm.getObjectById(
											Dish.class, flag.getDish().getId());
									dishList.add(dish);
								} catch (Exception e) {/* dish doesn't exist */
								}
							}
						} catch (Exception e) {
						}
					}
					query.closeAll();

					Collections.sort(dishList, new DishNameSorter(1));
					req.getSession().setAttribute("displayListSessionData",
							dishList);
					req.setAttribute("displayList",
							getDisplayPageData(dishList, 1));
					// query.setFilter("nickname >= :1 && nickname < :2");
					// List<TDUser> list = (List<TDUser>)query.execute("AD",
					// ("AD" + "\ufffd"));

					// System.out.println("search result size="+list.size());
					// for(int i=0;i<list.size();i++){
					// TDUser user = list.get(i);
					// System.out.println("================>>"+user.getNickname());
					// }
				} else if (flagFor.equalsIgnoreCase("restaurant")) {

					ArrayList<Restaurant> restaurantList = new ArrayList<Restaurant>();
					ArrayList<Long> uniqueRestId = new ArrayList<Long>();

					Query query = pm.newQuery(Flag.class);
					query.setFilter("status==1 && flagFor=='restaurant'");
					List<Flag> flags = (List<Flag>) query.execute();

					for (int i = 0; i < flags.size(); i++) {
						Flag flag = flags.get(i);
						if (uniqueRestId.contains(flag.getRestaurant().getId()))
							continue;
						else {
							uniqueRestId.add(flag.getRestaurant().getId());
							try {
								Restaurant restaurant = (Restaurant) pm
										.getObjectById(Restaurant.class, flag
												.getRestaurant().getId());
								restaurantList.add(restaurant);
							} catch (Exception e) {/* restaurant doesn't exist */
							}
						}
					}
					query.closeAll();

					req.getSession().setAttribute("displayListSessionData",
							restaurantList);
					req.setAttribute("displayList",
							getDisplayPageData(restaurantList, 1));

				} else if (flagFor.equalsIgnoreCase("review")) {

					ArrayList<Review> reviewList = new ArrayList<Review>();
					ArrayList<Long> uniqueReviewId = new ArrayList<Long>();

					Query query = pm.newQuery(Flag.class);
					query.setFilter("status==1 && flagFor=='review'");
					List<Flag> flags = (List<Flag>) query.execute();

					for (int i = 0; i < flags.size(); i++) {
						Flag flag = flags.get(i);
						if (uniqueReviewId.contains(flag.getReview().getId()))
							continue;
						else {
							uniqueReviewId.add(flag.getReview().getId());
							try {
								Review review = (Review) pm.getObjectById(
										Review.class, flag.getReview().getId());
								Dish dish = (Dish) pm.getObjectById(Dish.class,
										review.getDish().getId());
								review.setDishName(dish.getName());
								reviewList.add(review);
							} catch (Exception e) {/*
													 * review or dish doesnt
													 * exist
													 */
							}
						}
					}
					query.closeAll();

					req.getSession().setAttribute("displayListSessionData",
							reviewList);
					req.setAttribute("displayList",
							getDisplayPageData(reviewList, 1));

				} else if (flagFor.equalsIgnoreCase("photo")) {

					ArrayList<Photo> photoList = new ArrayList<Photo>();
					ArrayList<Long> uniquePhotoId = new ArrayList<Long>();

					Query query = pm.newQuery(Flag.class);
					query.setFilter("status==1 && flagFor=='photo'");
					List<Flag> flags = (List<Flag>) query.execute();

					for (int i = 0; i < flags.size(); i++) {
						Flag flag = flags.get(i);
						try {
							if (uniquePhotoId.contains(flag.getPhoto().getId()))
								continue;
							else {
								uniquePhotoId.add(flag.getPhoto().getId());
								Photo photo = (Photo) pm.getObjectById(
										Photo.class, flag.getPhoto().getId());
								TDUser tdUser = (TDUser) pm.getObjectById(
										TDUser.class, photo.getCreator()
												.getId());
								photo.setCreatorName(tdUser.getNickname());
								photoList.add(photo);
							}
						} catch (Exception e) {
						}
					}
					query.closeAll();

					req.getSession().setAttribute("displayListSessionData",
							photoList);
					req.setAttribute("displayList",
							getDisplayPageData(photoList, 1));

				}
			}

			rd = req.getRequestDispatcher("/admin/flags/flaggedItems.jsp");
			rd.forward(req, resp);
		} else if (action.equalsIgnoreCase("showFlags")) { // show all new flags
															// associated with
															// any particular
															// dish/restaurant/review/photo

			ArrayList<Flag> flagsList = new ArrayList<Flag>();
			String id = req.getParameter("id") == null ? null : req
					.getParameter("id").trim();
			List<Flag> flags = new ArrayList<Flag>();
			try {
				if (flagFor.equalsIgnoreCase("dish")) {
					Query query = pm.newQuery(Flag.class);
					Dish d = (Dish) pm.getObjectById(Dish.class,
							Long.parseLong(id));
					query.setFilter("status==1 && flagFor=='dish' && dish == :param");
					flags = (List<Flag>) query.execute(d.getKey());
				} else if (flagFor.equalsIgnoreCase("restaurant")) {
					Query query = pm.newQuery(Flag.class);
					Restaurant r = (Restaurant) pm.getObjectById(
							Restaurant.class, Long.parseLong(id));
					query.setFilter("status==1 && flagFor=='restaurant' && restaurant == :param");
					flags = (List<Flag>) query.execute(r.getKey());
				} else if (flagFor.equalsIgnoreCase("review")) {
					Query query = pm.newQuery(Flag.class);
					Review rv = (Review) pm.getObjectById(Review.class,
							Long.parseLong(id));
					query.setFilter("status==1 && flagFor=='review' && review == :param");
					flags = (List<Flag>) query.execute(rv.getKey());
				} else if (flagFor.equalsIgnoreCase("photo")) {
					Query query = pm.newQuery(Flag.class);
					Photo p = (Photo) pm.getObjectById(Photo.class,
							Long.parseLong(id));
					query.setFilter("status==1 && flagFor=='photo' && photo == :param");
					flags = (List<Flag>) query.execute(p.getKey());
				}

				for (int i = 0; flags != null && i < flags.size(); i++) {
					Flag flag = flags.get(i);
					TDUser user = (TDUser) pm.getObjectById(TDUser.class, flag
							.getCreator().getId());
					flag.setCreatorUsername(user.getNickname());
					flag.setTypeStringValue(Flag.FLAG_TYPE_NAME.get(flag
							.getType().toString()));
					flagsList.add(flag);
				}
			} catch (Exception e) {
			}

			req.setAttribute("flagsDisplayList", flagsList);
			rd = req.getRequestDispatcher("/admin/flags/flags.jsp");
			rd.forward(req, resp);
		} else if (action.equalsIgnoreCase("showFlagAction")) {
			try {
				String id = req.getParameter("id") == null ? null : req
						.getParameter("id").trim();
				Flag flag = (Flag) pm.getObjectById(Flag.class,
						Long.parseLong(id));

				TDUser user = (TDUser) pm.getObjectById(TDUser.class, flag
						.getCreator().getId());
				flag.setCreatorUsername(user.getNickname());
				flag.setTypeStringValue(Flag.FLAG_TYPE_NAME.get(flag.getType()
						.toString()));

				req.setAttribute("flagViewObj", flag);
			} catch (Exception e) {
			}
			rd = req.getRequestDispatcher("/admin/flags/flagAction.jsp");
			rd.forward(req, resp);
		} else if (action.equalsIgnoreCase("flagMarkAsResolved")) { // action
																	// for
																	// marking
																	// the flag
																	// as
																	// resolved
			String id = req.getParameter("id") == null ? null : req
					.getParameter("id").trim();
			String comment = req.getParameter("id") == null ? "" : req
					.getParameter("comment").trim();

			if (id != null) {
				try {
					Flag flag = (Flag) pm.getObjectById(Flag.class,
							Long.parseLong(id));
					flag.setAdminComment(comment);
					flag.setResolvedDate(new java.util.Date());
					UserServiceFactory.getUserService().getCurrentUser();
					flag.setResolvedBy(TDUserService.getUser(req.getSession()).getKey());
					flag.setStatus(0); // set as resolved [0=resolved,
										// 1=unresolved]
					pm.makePersistent(flag);
				} catch (Exception e) {
				} // catch both UserNotLoggedIn and UserNotFound Exception. Do
					// nothing

			}
			pm.close();
			return;
		} else if (action.equalsIgnoreCase("showPage")) { // pagination requests
															// come here

			if (flagFor.equalsIgnoreCase("dish"))
				req.setAttribute(
						"displayList",
						getDisplayPageData((ArrayList<Dish>) req.getSession()
								.getAttribute("displayListSessionData"), pageNo));
			else if (flagFor.equalsIgnoreCase("restaurant"))
				req.setAttribute(
						"displayList",
						getDisplayPageData(
								(ArrayList<Restaurant>) req.getSession()
										.getAttribute("displayListSessionData"),
								pageNo));
			else if (flagFor.equalsIgnoreCase("review"))
				req.setAttribute(
						"displayList",
						getDisplayPageData((ArrayList<Review>) req.getSession()
								.getAttribute("displayListSessionData"), pageNo));
			else if (flagFor.equalsIgnoreCase("photo"))
				req.setAttribute(
						"displayList",
						getDisplayPageData((ArrayList<Photo>) req.getSession()
								.getAttribute("displayListSessionData"), pageNo));

			rd = req.getRequestDispatcher("/admin/flags/flaggedItems.jsp");
			rd.forward(req, resp);
		} else if (action.equalsIgnoreCase("sort")) {
			String column = req.getParameter("col") == null ? "" : req
					.getParameter("col").trim();
			String order = req.getParameter("ord") == null ? "" : req
					.getParameter("ord").trim();

			if (flagFor.equalsIgnoreCase("dish")) {
				ArrayList<Dish> sortList = (ArrayList<Dish>) req.getSession()
						.getAttribute("displayListSessionData");

				if (column.equalsIgnoreCase("dishname")) { // sort by dish name
					if (order.equals("desc")) // descending
						Collections.sort(sortList, new DishNameSorter(-1));
					else
						Collections.sort(sortList, new DishNameSorter(1));
				}

				req.getSession().setAttribute("displayListSessionData",
						sortList);
				req.setAttribute("displayList", getDisplayPageData(sortList, 1));
			} else if (flagFor.equalsIgnoreCase("restaurant")) {
				ArrayList<Restaurant> sortList = (ArrayList<Restaurant>) req
						.getSession().getAttribute("displayListSessionData");

				if (column.equalsIgnoreCase("restname")) { // sort by restaurant
															// name
					if (order.equals("desc")) // descending
						Collections
								.sort(sortList, new RestaurantNameSorter(-1));
					else
						Collections.sort(sortList, new RestaurantNameSorter(1));
				}

				req.getSession().setAttribute("displayListSessionData",
						sortList);
				req.setAttribute("displayList", getDisplayPageData(sortList, 1));
			} else if (flagFor.equalsIgnoreCase("review")) {
				req.getSession().getAttribute("displayListSessionData");
			} else if (flagFor.equalsIgnoreCase("photo")) {
				ArrayList<Photo> sortList = (ArrayList<Photo>) req.getSession()
						.getAttribute("displayListSessionData");

				if (column.equalsIgnoreCase("creatorname")) { // sort by
																// restaurant
																// name
					if (order.equals("desc")) // descending
						Collections.sort(sortList, new PhotoCreatorNameSorter(
								-1));
					else
						Collections.sort(sortList,
								new PhotoCreatorNameSorter(1));
				}

				req.getSession().setAttribute("displayListSessionData",
						sortList);
				req.setAttribute("displayList", getDisplayPageData(sortList, 1));
			}

			rd = req.getRequestDispatcher("/admin/flags/flaggedItems.jsp");
			rd.forward(req, resp);
		}

		pm.close();
	}

	private <T> ArrayList<T> getDisplayPageData(ArrayList<T> dataList,
			int pageNo) {
		ArrayList<T> displayList = new ArrayList<T>();

		if (pageNo > 0 && dataList.size() > 0) {
			if (displaySize >= dataList.size()) {
				return dataList;
			} else {
				int startIndex = displaySize * (pageNo - 1);
				if (startIndex > dataList.size()) {
					startIndex = dataList.size() - 1 - displaySize; // start of
																	// last page
				}

				int endIndex = startIndex + displaySize - 1;
				if ((endIndex + 1) > dataList.size()) {
					endIndex = dataList.size() - 1; // end of last page
				}

				for (int i = startIndex; i <= endIndex; i++) {
					displayList.add(dataList.get(i));
				}
			}
		}

		return displayList;
	}

}

/*
 * Comparator classes used for sorting
 */

class DishNameSorter implements Comparator<Dish> {

	private int sortDirection = 1;

	public DishNameSorter(int sortVal) {
		this.sortDirection = sortVal;
	}

	public int compare(Dish dish1, Dish dish2) {
		if (sortDirection == 1) // ascending
			return dish1.getName().compareToIgnoreCase(dish2.getName());
		else
			// descending
			return -1 * dish1.getName().compareToIgnoreCase(dish2.getName());
	}
}

class RestaurantNameSorter implements Comparator<Restaurant> {

	private int sortDirection = 1;

	public RestaurantNameSorter(int sortVal) {
		this.sortDirection = sortVal;
	}

	public int compare(Restaurant restaurant1, Restaurant restaurant2) {
		if (sortDirection == 1) // ascending
			return restaurant1.getName().compareToIgnoreCase(
					restaurant2.getName());
		else
			// descending
			return -1
					* restaurant1.getName().compareToIgnoreCase(
							restaurant2.getName());
	}
}

class PhotoCreatorNameSorter implements Comparator<Photo> {

	private int sortDirection = 1;

	public PhotoCreatorNameSorter(int sortVal) {
		this.sortDirection = sortVal;
	}

	public int compare(Photo photo1, Photo photo2) {
		if (sortDirection == 1) // ascending
			return photo1.getCreatorName().compareToIgnoreCase(
					photo2.getCreatorName());
		else
			// descending
			return -1
					* photo1.getCreatorName().compareToIgnoreCase(
							photo2.getCreatorName());
	}
}
