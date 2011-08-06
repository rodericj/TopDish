package com.topdish;

import java.io.IOException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.json.JSONObject;

import com.topdish.api.util.FacebookConstants;
import com.topdish.api.util.UserConstants;
import com.topdish.util.Alerts;
import com.topdish.util.FacebookUtils;

public class FacebookServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 1166874062491774556L;

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = FacebookServlet.class.getSimpleName();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException,
			IOException {

		try {

			final String code = req.getParameter(FacebookConstants.CODE);

			if (null != code) {

				Logger.getLogger(TAG).info("Got Code: " + code);

				// Use the code to get the access info
				final Map<String, String> accessInfo = FacebookUtils.getAccessToken(code);

				Logger.getLogger(TAG).info("Map Size:" + accessInfo.size());

				// Pull out access_token
				final String accessToken = accessInfo.get(FacebookConstants.ACCESS_TOKEN);

				// Get expiration
				final String expirationFb = accessInfo.get(FacebookConstants.EXPIRATION);

				// Define expiration from now
				long expFb = 5000 * 1000;
				try {
					expFb = Long.parseLong(expirationFb) * 1000;
				} catch (Exception e) {
					Logger.getLogger(TAG).info("Expiration time failed to parse, using default");
				}
				final long expiration = System.currentTimeMillis() + expFb;

				// Get the information the user
				final JSONObject fbData = FacebookUtils.getFacebookDataAsJSON(accessToken);

				// Pull out Facebook Id
				final String facebookId = fbData.getString("id");

				// Check that id was returned
				if (null != facebookId && !facebookId.isEmpty()) {

					Logger.getLogger(TAG).info("Facebook ID: " + facebookId);

					final String email = (fbData.has(UserConstants.EMAIL) ? fbData
							.getString("email") : new String());
					final String nickname = (fbData.has(UserConstants.NAME) ? fbData
							.getString("name") : new String());

					Logger.getLogger(TAG).info("Email : " + email);
					Logger.getLogger(TAG).info("Nickname : " + nickname);

					// Setup Session and insert facebook data
					HttpSession session = req.getSession(true);

					Logger.getLogger(TAG).info("Session retrieved: " + session.getId());

					session.setAttribute(FacebookConstants.FACEBOOK_ID, facebookId);
					session.setAttribute(FacebookConstants.FACEBOOK_OAUTH_KEY, accessToken);
					session.setAttribute(UserConstants.LOGIN_EXPIRATION, expiration);
					session.setAttribute(UserConstants.NICKNAME, nickname);
					session.setAttribute(UserConstants.EMAIL, email);

					Logger.getLogger(TAG).info(
							"Total Session Attributes: " + session.getAttributeNames());

					// Forward to Logic
					Logger.getLogger(TAG).info("Redirecting to Logic");
					resp.sendRedirect("/loginLogic");
					return;
				} else
					Logger.getLogger(TAG).info("Facebook ID was null or empty");

			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		// Forward back to Login
		Logger.getLogger(TAG).info("Redirecting to Login");
		Alerts.setError(req, "Facebook Login failed.");
		resp.sendRedirect("/login.jsp");
	}
}
