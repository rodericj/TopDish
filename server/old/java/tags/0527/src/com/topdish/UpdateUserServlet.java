package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class UpdateUserServlet extends HttpServlet {
	private static final long serialVersionUID = 632733181194368523L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		
		if(!TDUserService.isUserLoggedIn(req.getSession(true))){
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}

		String nickname = req.getParameter("nickname");
		String email = req.getParameter("email").toLowerCase();
		String bio = req.getParameter("bio");
		if (bio.length() > 100) {
			bio = bio.substring(0, 100);
		}
		Long userKey = Long.parseLong(req.getParameter("userKey"));

		String[] lifestyles = req.getParameterValues("lifestyle[]");
		List<Key> lifestyleKeys = new ArrayList<Key>();

		if (lifestyles != null) {
			for (String l : lifestyles) {
				Integer i = Integer.parseInt(l);
				Tag t = Datastore.get(KeyFactory.createKey(
						Tag.class.getSimpleName(), i));
				lifestyleKeys.add(t.getKey());
			}
		}

		String[] allergens = req.getParameterValues("allergen[]");
		List<Key> allergenKeys = new ArrayList<Key>();

		if (allergens != null) {
			for (String a : allergens) {
				Integer i = Integer.parseInt(a);
				Tag t = Datastore.get(KeyFactory.createKey(
						Tag.class.getSimpleName(), i));
				allergenKeys.add(t.getKey());
			}
		}

		TDUser tdUser = Datastore.get(KeyFactory.createKey(
				TDUser.class.getSimpleName(), userKey));

		tdUser.setEmail(email);
		tdUser.setNickname(nickname);
		tdUser.setBio(bio);
		tdUser.setLifestyles(lifestyleKeys);
		tdUser.setAllergens(allergenKeys);
		Datastore.put(tdUser);

		// add to memcache
		Datastore.put(tdUser);

		Alerts.setInfo(req, Alerts.USER_UPDATED);
		resp.sendRedirect("userProfile.jsp");
		return;
	}
}