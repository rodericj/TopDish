/**
 * 
 */
package com.topdish.adminconsole.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Set;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.TDUserRole;
import com.topdish.util.Datastore;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;

/**
 * @author nikhil_malleri This class acts as the main controller for all
 *         requests coming to user management admin module
 */
public class TopDishUsersController extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 5694400450658858137L;
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
			System.err.println("ERROR: user disp size:::: " + displaySize);
		}
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		req.getSession().removeAttribute("displayListSessionData");

		RequestDispatcher rd = null;
		rd = req.getRequestDispatcher("/admin/users/main.jsp");
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
		String userType = req.getParameter("userType") == null ? null : req
				.getParameter("userType").trim();
		RequestDispatcher rd = null;
		PersistenceManager pm = PMF.get().getPersistenceManager();

		req.setAttribute("pageNo", pageNo);
		req.setAttribute("displaySize", displaySize);

		if (action.equalsIgnoreCase("show") && userType != null) { // show the
																	// list of
																	// users
																	// based on
																	// role type
																	// selected
																	// from the
																	// drop down

			Query query = pm.newQuery(TDUser.class);

			if (userType.equalsIgnoreCase("admin")) {
				query.setFilter("role==" + TDUserRole.ROLE_ADMIN);
			} else if (userType.equalsIgnoreCase("advanced")) {
				query.setFilter("role==" + TDUserRole.ROLE_ADVANCED);
			} else if (userType.equalsIgnoreCase("standard")) {
				query.setFilter("role==" + TDUserRole.ROLE_STANDARD);
			} else if (userType.equalsIgnoreCase("all"))
				;

			List<TDUser> users = (List<TDUser>) query.execute();
			users = (List<TDUser>) pm.detachCopyAll(users);

			// / workaround for getting dishes and restaurant count as suggested
			// by TopDish... can be removed once dishes and restaurant count is
			// updated in TDUser table
			Query dishQuery = null;
			Query restQuery = null;
			for (int i = 0; users != null && i < users.size(); i++) {
				dishQuery = pm.newQuery(Dish.class);
				restQuery = pm.newQuery(Restaurant.class);

				TDUser user = users.get(i);

				dishQuery.setFilter("creator == :param");
				List<Dish> dishList = (List<Dish>) dishQuery.execute(user
						.getKey());
				restQuery.setFilter("creator == :param");
				List<Restaurant> restList = (List<Restaurant>) restQuery
						.execute(user.getKey());

				int dishCount = 0;
				int restCount = 0;
				if (dishList != null)
					dishCount = dishList.size();
				if (restList != null)
					restCount = restList.size();

				user.setNumDishes(dishCount);
				user.setNumRestaurants(restCount);
			}
			// / workaround ends-----

			Collections.sort(users, new UserNameSorter(1));
			req.getSession().setAttribute("displayListSessionData", users);
			req.setAttribute("displayList", getDisplayPageData(users, 1));

			rd = req.getRequestDispatcher("/admin/users/userList.jsp");
			rd.forward(req, resp);
		} else if (action.equalsIgnoreCase("goto")) {
			req.setAttribute(
					"displayList",
					getDisplayPageData((List<TDUser>) req.getSession()
							.getAttribute("displayListSessionData"), pageNo));
			rd = req.getRequestDispatcher("/admin/users/userList.jsp");
			rd.forward(req, resp);
		} else if (action.equalsIgnoreCase("changeRole")) {
			String id = req.getParameter("id") == null ? "0" : req
					.getParameter("id").trim();
			String role = req.getParameter("role") == null ? null : req
					.getParameter("role").trim();
			try {
				TDUser user = (TDUser) pm.getObjectById(TDUser.class,
						Long.parseLong(id));
				if (role != null && user != null) {
					int roleVal;
					if (role.equalsIgnoreCase("administrator"))
						roleVal = TDUserRole.ROLE_ADMIN;
					else if (role.equalsIgnoreCase("advanced"))
						roleVal = TDUserRole.ROLE_ADVANCED;
					else
						roleVal = TDUserRole.ROLE_STANDARD;

					user.setRole(roleVal);
					pm.makePersistent(user);

					// update data stored in session
					List<TDUser> userList = (List<TDUser>) req.getSession()
							.getAttribute("displayListSessionData");
					for (int i = 0; userList != null && i < userList.size(); i++) {
						TDUser tdUser = userList.get(i);
						if (tdUser.getKey().getId() == Long.parseLong(id)) {
							tdUser.setRole(roleVal);
							break;
						}
					}
				}
			} catch (Exception e) {
			}

		} else if (action.equalsIgnoreCase("search")) {
			String searchBy = req.getParameter("searchby") == null ? "" : req
					.getParameter("searchby").trim();
			String keyword = req.getParameter("keyword") == null ? null : req
					.getParameter("keyword").trim();

			if (keyword != null) {
				if (searchBy.equalsIgnoreCase("username")) {
					Set<TDUser> users = Datastore.get(TDQueryUtils
							.getUserKeysByName(keyword));
					List<TDUser> searchList = (List<TDUser>) users;
					if (searchList != null) {
						Collections.sort(searchList, new UserNameSorter(1));
						req.getSession().setAttribute("displayListSessionData",
								searchList);
						req.setAttribute("displayList",
								getDisplayPageData(searchList, 1));

						rd = req.getRequestDispatcher("/admin/users/userList.jsp");
						rd.forward(req, resp);
					} else {
						System.out.println("in else...");
						resp.getOutputStream().write(
								"<tr><td colspan=\"7\" align=\"center\">No records found.</td></tr>"
										.getBytes());
					}
				}
			}
		} else if (action.equalsIgnoreCase("sort")) {
			String column = req.getParameter("col") == null ? "" : req
					.getParameter("col").trim();
			String order = req.getParameter("ord") == null ? "" : req
					.getParameter("ord").trim();

			List<TDUser> sortList = (List<TDUser>) req.getSession()
					.getAttribute("displayListSessionData");
			if (sortList == null)
				return;

			if (column.equalsIgnoreCase("username")) { // sort by user name
				if (order.equals("desc")) // descending
					Collections.sort(sortList, new UserNameSorter(-1));
				else
					Collections.sort(sortList, new UserNameSorter(1));
			} else if (column.equalsIgnoreCase("review")) { // sort by review
															// count
				if (order.equals("desc")) // descending
					Collections.sort(sortList, new ReviewCountSorter(-1));
				else
					Collections.sort(sortList, new ReviewCountSorter(1));
			} else if (column.equalsIgnoreCase("dish")) { // sort by dish count
				if (order.equals("desc")) // descending
					Collections.sort(sortList, new DishCountSorter(-1));
				else
					Collections.sort(sortList, new DishCountSorter(1));
			} else if (column.equalsIgnoreCase("restaurant")) { // sort by
																// restaurant
																// count
				if (order.equals("desc")) // descending
					Collections.sort(sortList, new RestaurantCountSorter(-1));
				else
					Collections.sort(sortList, new RestaurantCountSorter(1));
			}

			req.getSession().setAttribute("displayListSessionData", sortList);
			req.setAttribute("displayList", getDisplayPageData(sortList, 1));

			rd = req.getRequestDispatcher("/admin/users/userList.jsp");
			rd.forward(req, resp);
		}
		pm.close();
	}

	private List<TDUser> getDisplayPageData(List<TDUser> dataList, int pageNo) {
		ArrayList<TDUser> displayList = new ArrayList<TDUser>();

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

class UserNameSorter implements Comparator<TDUser> {

	private int sortDirection = 1;

	public UserNameSorter(int sortVal) {
		this.sortDirection = sortVal;
	}

	public int compare(TDUser user1, TDUser user2) {
		if (sortDirection == 1) // ascending
			return user1.getNickname().compareToIgnoreCase(user2.getNickname());
		else
			// descending
			return -1
					* user1.getNickname().compareToIgnoreCase(
							user2.getNickname());
	}
}

class ReviewCountSorter implements Comparator<TDUser> {

	private int sortDirection = 1;

	public ReviewCountSorter(int sortVal) {
		this.sortDirection = sortVal;
	}

	public int compare(TDUser user1, TDUser user2) {

		if (sortDirection == 1) // ascending
			return user1.getNumReviews().compareTo(user2.getNumReviews());
		else
			// descending
			return -1 * user1.getNumReviews().compareTo(user2.getNumReviews());
	}
}

class DishCountSorter implements Comparator<TDUser> {

	private int sortDirection = 1;

	public DishCountSorter(int sortVal) {
		this.sortDirection = sortVal;
	}

	public int compare(TDUser user1, TDUser user2) {
		if (sortDirection == 1) // ascending
			return user1.getNumDishes().compareTo(user2.getNumDishes());
		else
			// descending
			return -1 * user1.getNumDishes().compareTo(user2.getNumDishes());
	}
}

class RestaurantCountSorter implements Comparator<TDUser> {

	private int sortDirection = 1;

	public RestaurantCountSorter(int sortVal) {
		this.sortDirection = sortVal;
	}

	public int compare(TDUser user1, TDUser user2) {
		if (sortDirection == 1) // ascending
			return user1.getNumRestaurants().compareTo(
					user2.getNumRestaurants());
		else
			// descending
			return -1
					* user1.getNumRestaurants().compareTo(
							user2.getNumRestaurants());
	}
}
