package com.topdish;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class UpdateUserServlet extends HttpServlet {
	private static final long serialVersionUID = 632733181194368523L;
	private static final String TAG = UpdateUserServlet.class.getSimpleName();

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		try {
			TDUserService.getUser(req.getSession(true));

			final String nickname = req.getParameter("nickname");
			final String email = req.getParameter("email").toLowerCase();
			final String bio = req.getParameter("bio");
			final String userKeyS = req.getParameter("userKey");
			long userKey = Long.parseLong(userKeyS);
			
			if (bio.length() > 100) {
				Alerts.setError(req, Alerts.USER_BIO_TOO_LONG);
				resp.sendRedirect("userProfile.jsp");
				return;
			}
			

			final String[] lifestyles = req.getParameterValues("lifestyle[]");
			final Set<Key> lifestyleKeys = new HashSet<Key>();

			if (null != lifestyles) {
				for (final String l : lifestyles) {
					final Integer i = Integer.parseInt(l);
					lifestyleKeys.add(KeyFactory.createKey(Tag.class.getSimpleName(), i));
				}
			}

			final String[] allergens = req.getParameterValues("allergen[]");
			final Set<Key> allergenKeys = new HashSet<Key>();

			if (null != allergens) {
				for (final String a : allergens) {
					final Integer i = Integer.parseInt(a);
					allergenKeys.add(KeyFactory.createKey(Tag.class.getSimpleName(), i));
				}
			}

			final TDUser tdUser = Datastore.get(KeyFactory.createKey(TDUser.class.getSimpleName(),
					userKey));

			tdUser.setEmail(email);
			tdUser.setNickname(nickname);
			tdUser.setBio(bio);
			tdUser.setLifestyles(lifestyleKeys);
			tdUser.setAllergens(allergenKeys);
			
			Datastore.put(tdUser);

			Alerts.setInfo(req, Alerts.USER_UPDATED);
			resp.sendRedirect("userProfile.jsp");
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
		} catch(Exception e){
			Logger.getLogger(TAG).error(e.getMessage());
			Alerts.setError(req, Alerts.USER_NOT_UPDATED);
			resp.sendRedirect("index.jsp");
			return;
		}
	}
}