package com.topdish;

import java.io.IOException;
import java.util.Arrays;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class UpdateDishServlet extends HttpServlet {
	private static final long serialVersionUID = 3426591936548809459L;

	/**
	 * DEBUG
	 */
	private static final boolean DEBUG = true;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		if(!TDUserService.isUserLoggedIn(req.getSession(true))){
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}
		
		if (DEBUG) {
			for (Object key : req.getParameterMap().keySet())
				System.out.println(new String((String) key) + " : "
						+ req.getParameter(new String((String) key)));

		}

		String dishIDs = req.getParameter("dishID");
		String name = req.getParameter("name");
		String description = req.getParameter("description");
		String categoryIDs = req.getParameter("categoryID");
		String priceIDs = req.getParameter("priceID");
		String tagList = req.getParameter("tagList");
		Date date = new Date();
		long categoryID = 0;
		long priceID = 0;
		long dishID = 0;

		try {
			dishID = Long.parseLong(dishIDs);
		} catch (NumberFormatException e) {
			// not a long
			if (DEBUG)
				System.out.println("Failed to parse Dish Id " + dishIDs
						+ " as a Long");
		}
		try {
			priceID = Long.parseLong(priceIDs);
		} catch (NumberFormatException e) {
			// not a long
			if (DEBUG)
				System.out.println("Failed to parse Price Id " + priceIDs
						+ " as a Long");
		}

		try {
			categoryID = Long.parseLong(categoryIDs);
		} catch (NumberFormatException e) {
			// not a long
			if (DEBUG)
				System.out.println("Failed to parse Category Id " + priceIDs
						+ " as a Long");
		}

		try {
			TDUser editor = TDUserService.getUser(req.getSession());
			Dish d = Datastore.get(KeyFactory.createKey(
					Dish.class.getSimpleName(), dishID));
			d.setName(name);
			d.setDescription(description);
			d.setLastEditor(editor.getKey());
			d.setDateModified(date);
			d.removeAllTags();
			d.setCategory(Datastore
					.get(KeyFactory.createKey(Tag.class.getSimpleName(),
							categoryID)).getKey());
			d.setPrice(Datastore.get(
					KeyFactory.createKey(Tag.class.getSimpleName(), priceID))
					.getKey());

			// Traverse Tags
			if (!tagList.isEmpty())
				for (String id : Arrays.asList(tagList.split("[,;]+")))
					d.addTag(Datastore.get(
							KeyFactory.createKey(Tag.class.getSimpleName(),
									Long.parseLong(id))).getKey());

			Datastore.put(d);

			Alerts.setInfo(req, Alerts.DISH_ADDED);
			resp.sendRedirect("dishDetail.jsp?dishID=" + dishIDs);
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