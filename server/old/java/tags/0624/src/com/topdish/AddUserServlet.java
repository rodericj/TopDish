package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.api.util.FacebookConstants;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.TDUserRole;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

public class AddUserServlet extends HttpServlet {
	private static final long serialVersionUID = -2495174036563420120L;

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = AddUserServlet.class.getSimpleName();

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		if (!TDUserService.isUserAuthenticated(req)) {
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}

		String nickname = req.getParameter("nickname");
		String email = req.getParameter("email").toLowerCase();

		// Check if nickname and email are unique
		Set<Key> nameDupes = TDQueryUtils.getUserKeysByName(nickname);
		Set<Key> emailDupes = TDQueryUtils.getUserKeysByEmail(email);

		// Send user back to login page with error message
		if (!nameDupes.isEmpty()) {
			//name is already in use
			resp.sendRedirect("welcome.jsp");
			System.out.println("duplicate name");
			return;
		}
		
		if (!emailDupes.isEmpty()) {
			//email is already in use
			resp.sendRedirect("welcome.jsp");
			System.out.println("duplicate email");
			return;
		}

		// Set the Lifestyles
		String[] lifestyles = req.getParameterValues("lifestyle[]");
		List<Key> lifestyleKeys = new ArrayList<Key>();

		if (lifestyles != null) {
			for (String l : lifestyles) {
				Integer i = Integer.parseInt(l);
				Tag t = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), i));
				lifestyleKeys.add(t.getKey());
			}
		}

		// Set the allergens
		String[] allergens = req.getParameterValues("allergen[]");
		List<Key> allergenKeys = new ArrayList<Key>();

		if (allergens != null) {
			for (String a : allergens) {
				Integer i = Integer.parseInt(a);
				Tag t = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), i));
				allergenKeys.add(t.getKey());
			}
		}

		Logger.getLogger(TAG).info("Starting");
		UserService userService = UserServiceFactory.getUserService();
		User user = userService.getCurrentUser();

		Logger.getLogger(TAG).info("Trying to get TDUser");
		TDUser tdUser = null;
		try {
			tdUser = TDUserService.getUser(req.getSession());
		} catch (UserNotFoundException e) {
			// e.printStackTrace();
		} catch (UserNotLoggedInException e) {
			// e.printStackTrace();
		}

		Logger.getLogger(TAG).info(
				"SESSION DATA: " + Arrays.asList(req.getSession().getAttributeNames()));

		if (null == tdUser && null == user) {
			Logger.getLogger(TAG).info("Both TDUser and User are null, creating new user.");
			tdUser = new TDUser(user = new User(email, "facebook.com"), nickname, email);
		} else if (null != user) {
			Logger.getLogger(TAG).info("USER is not null");
			// checks if user is admin else creates with default role(standard)
			if (userService.isUserAdmin())
				tdUser = new TDUser(user, nickname, email, TDUserRole.ROLE_ADMIN);
			else
				tdUser = new TDUser(user, nickname, email);
		}

		if (null != req.getSession().getAttribute(FacebookConstants.FACEBOOK_ID)) {
			Logger.getLogger(TAG).info(
					"ADDING FACEBOOK ID: "
							+ req.getSession().getAttribute(FacebookConstants.FACEBOOK_ID));
			tdUser.setFacebookId(String.valueOf(req.getSession().getAttribute(
					FacebookConstants.FACEBOOK_ID)));
		}

		tdUser.setLifestyles(lifestyleKeys);
		tdUser.setAllergens(allergenKeys);

		Datastore.put(tdUser);
		Logger.getLogger(TAG).info("Done and Redirecting");

		resp.sendRedirect("index.jsp");
		//TODO: show welcome message to user
		return;
	}
}