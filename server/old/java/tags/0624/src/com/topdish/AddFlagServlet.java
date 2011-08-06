package com.topdish;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Flag;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class AddFlagServlet extends HttpServlet {
	private static final long serialVersionUID = 4924551326574743200L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		
		if(!TDUserService.isUserLoggedIn(req.getSession(false))){
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}

		String reviewIDs = req.getParameter("reviewID");
		String photoIDs = req.getParameter("photoID");
		String dishIDs = req.getParameter("dishID");
		String restaurantIDs = req.getParameter("restaurantID");
		String restDishIds = req.getParameter("restDishId");
		String flagTypeS = req.getParameter("type");
		String comment = req.getParameter("comment");

		long reviewID = 0;
		long photoID = 0;
		long dishID = 0;
		long restaurantID = 0;
		long restDishId = 0;
		int flagType = 0;

		TDUser creator = null;
		Review review = null;
		Photo photo = null;
		Dish dish = null;
		Restaurant restaurant = null;

		try {
			reviewID = Long.parseLong(reviewIDs);
		} catch (NumberFormatException e) {
			// not a long
		}

		try {
			photoID = Long.parseLong(photoIDs);
		} catch (NumberFormatException e) {
			// not a long
		}

		try {
			dishID = Long.parseLong(dishIDs);
		} catch (NumberFormatException e) {
			// not a long
		}

		try {
			restaurantID = Long.parseLong(restaurantIDs);
		} catch (NumberFormatException e) {
			// not a long
		}

		try {
			restDishId = Long.parseLong(restDishIds);
		} catch (NumberFormatException e) {
			// not a long
		}

		try {
			flagType = Integer.parseInt(flagTypeS);
		} catch (NumberFormatException e) {
			// not an integer
		}

		try {
			creator = TDUserService.getUser(req.getSession());
		} catch (UserNotLoggedInException e) {
			// forward to log in page
			resp.sendRedirect("login.jsp");
			return;
		} catch (UserNotFoundException e) {
			// forward to login screen
			resp.sendRedirect("login.jsp");
			return;
		}

		if (dishID != 0) {
			dish = Datastore.get(KeyFactory.createKey(
					Dish.class.getSimpleName(), dishID));
			Flag flag = new Flag(flagType, creator.getKey(), dish.getCreator(),
					comment);

			Datastore.put(flag);
			dish.addFlag(flag);
			creator.addFlag(flag);
			Datastore.put(dish);
			Datastore.put(creator);

			Alerts.setInfo(req, Alerts.FLAG_ADDED);
			resp.sendRedirect("dishDetail.jsp?dishID=" + dishID);
			return;
		} else if (restaurantID != 0) {
			restaurant = Datastore.get(KeyFactory.createKey(
					Restaurant.class.getSimpleName(), restaurantID));
			Flag flag = new Flag(flagType, creator.getKey(),
					restaurant.getCreator(), comment);

			Datastore.put(flag);
			restaurant.addFlag(flag);
			creator.addFlag(flag);
			Datastore.put(restaurant);
			Datastore.put(creator);

			if (restDishId > 0){
				Alerts.setInfo(req, Alerts.FLAG_ADDED);
				resp.sendRedirect("restaurantDetail.jsp?restID=" + restaurant.getKey().getId());
				return;
			}
			else{
				Alerts.setInfo(req, Alerts.FLAG_ADDED);
				resp.sendRedirect("index.jsp");
				return;
			}
		} else if (reviewID != 0 || photoID != 0) {
			Flag flag = null;

			if (reviewID != 0) {
				review = Datastore.get(KeyFactory.createKey(
						Review.class.getSimpleName(), reviewID));
				flag = new Flag(flagType, creator.getKey(),
						review.getCreator(), comment);

				Datastore.put(flag);
				review.addFlag(flag);
				creator.addFlag(flag);
				Datastore.put(review);
				Datastore.put(creator);

				Alerts.setInfo(req, Alerts.FLAG_ADDED);
				resp.sendRedirect("dishDetail.jsp?dishID=" + review.getDish().getId());
				return;
			}
			if (photoID != 0) {
				photo = Datastore.get(KeyFactory.createKey(
						Photo.class.getSimpleName(), photoID));
				flag = new Flag(flagType, creator.getKey(), photo.getCreator(),
						comment);

				Datastore.put(flag);
				photo.addFlag(flag);
				creator.addFlag(flag);
				Datastore.put(photo);
				Datastore.put(flag);

				// TODO: find a better place to redirect
				Alerts.setInfo(req, Alerts.FLAG_ADDED);
				resp.sendRedirect("index.jsp");
				return;
			}
		} else {
			// redirect back to front page
			resp.sendRedirect("index.jsp");
		}
	}
}