package com.topdish.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public class Alerts {

	public static final String PLEASE_LOGIN = "Please log in to continue.";
	public static final String DISH_ADDED = "Your dish was added!";
	public static final String FLAG_ADDED = "Your flag was added! Thanks for keeping TopDish tidy.";
	public static final String PHOTO_ADDED = "Your photo was added!";
	public static final String PHOTO_NOT_ADDED = "Sorry, the photo you uploaded was not successful. Please try again.";
	public static final String RATE_DISH_ONCE_PER_DAY = "Sorry, you can only rate the same dish once a day.";
	public static final String REVIEW_ADDED = "Your review was added!";
	public static final String TAG_ADDED = "Your tag was added!";
	public static final String DISH_UPDATED = "Your dish was updated!";
	public static final String RESTAURANT_UPDATED = "Your restarurant was updated!";
	public static final String USER_UPDATED = "Your profile was updated!";
	public static final String TAG_UPDATED = "Your tag was updated!";
	public static final String TAG_PARENT_NOT_SELF = "Tags cannot be their own parent.";
	public static final String TAG_CUISINE_NO_PARENT = "Cuisine tags cannot have a parent";
	public static final String GENERAL_ERROR = "Sorry, but we had a problem with that last action. Please try again.";
	public static final String RESTAURANT_NOT_FOUND = "Sorry, but that restaurant was not found. Please try again.";
	public static final String DISH_NOT_FOUND = "Sorry, but that dish was not found. Please try again.";

	/**
	 * Sets an info message in the {@link HttpSesion}.
	 * 
	 * @param request
	 *            the {@link HttpServletRequest}.
	 * @param message
	 *            the message to set.
	 */
	public static void setInfo(HttpServletRequest request, String message) {
		request.getSession().setAttribute("info", message);
	}

	/**
	 * Get the current info message, if any and removes that message from the
	 * session.
	 * 
	 * @param request
	 *            the {@link HttpServletRequest}.
	 * @return the current info message or <code>null</code>.
	 */
	public static String getInfo(HttpServletRequest request) {
		if (null != request.getSession().getAttribute("info")) {
			final String info = (String) request.getSession().getAttribute("info");
			request.getSession().removeAttribute("info");
			return info;
		} else {
			return null;
		}
	}

	/**
	 * Set an error message in the {@link HttpSession}.
	 * 
	 * @param request
	 *            the {@link HttpServletRequest}.
	 * @param message
	 *            the message to set.
	 */
	public static void setError(HttpServletRequest request, String message) {
		request.getSession().setAttribute("error", message);
	}

	/**
	 * Gets the current error message, if any and removes that message from the
	 * session.
	 * 
	 * @param request
	 *            the {@link HttpServletRequest}.
	 * @return the current error message or <code>null</code>.
	 */
	public static String getError(HttpServletRequest request) {
		if (null != request.getSession().getAttribute("error")) {
			final String error = (String) request.getSession().getAttribute("error");
			request.getSession().removeAttribute("error");
			return error;
		} else {
			return null;
		}
	}
}
