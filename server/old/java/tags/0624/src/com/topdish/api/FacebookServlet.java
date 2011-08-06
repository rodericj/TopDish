package com.topdish.api;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.json.JSONObject;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.FacebookConstants;
import com.topdish.api.util.UserConstants;
import com.topdish.jdo.TDUser;
import com.topdish.util.Datastore;
import com.topdish.util.FacebookUtils;
import com.topdish.util.TDQueryUtils;

/**
 * Servlet to handle Facebook login from API
 * 
 * @author Salil
 * 
 */
public class FacebookServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 6036944661148152395L;

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = FacebookServlet.class.getSimpleName();

	/**
	 * DEBUG
	 */
	// private static final boolean DEBUG = true;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// Print Writer
		final PrintWriter writer = resp.getWriter();

		try {

			// Get the OAUTH Key
			final String facebookApiKey = req.getParameter(FacebookConstants.FACEBOOK_OAUTH_KEY);

			// Check not null
			if (null == facebookApiKey) {

				Logger.getLogger(TAG).info("Null API Key found!");

				// Inform user of invalid APIKey
				writer.write(APIUtils.generateJSONFailureMessage(2,
						"Facebook OAuth Key was null or invalid"));
				writer.flush();
				writer.close();
			} else {

				Logger.getLogger(TAG).info("OAuth Key Not Null: " + facebookApiKey);

				// Get the user's facebook data
				final JSONObject fbookData = FacebookUtils.getFacebookDataAsJSON(facebookApiKey);

				Logger.getLogger(TAG).info("Facebook Data translated.");

				String facebookId = null;

				try {
					facebookId = fbookData.getString("id");
				} catch (Exception e) {
				}

				if (null != facebookId) {

					// Grab the user key
					final Key userKey = TDQueryUtils.getUserForFacebookId(facebookId);

					// The current real user
					TDUser realUser = null;

					// Check that the key is valid
					if (null != userKey)
						realUser = Datastore.get(userKey);

					// If key is not valid = no existing user, create new one
					if (null == realUser) {

						Logger.getLogger(TAG).info("Generating new User");

						String email = null;

						try {
							email = fbookData.getString("email");
						} catch (Exception e) {
							email = new String();
						}

						String name = null;

						try {
							name = fbookData.getString("name");
						} catch (Exception e) {
							name = email;
						}

						realUser = new TDUser(new User(email, "facebook.com"), name, email);
						realUser.setFacebookId(facebookId);

						Datastore.put(realUser);

					} else
						Logger.getLogger(TAG).info(
								"Existing user found: " + realUser.getKey().getId());

					writer.write(APIUtils.generateJSONSuccessMessage(new JSONObject().put(
							UserConstants.TDUSER_ID, realUser.getKey().getId()).put(
							UserConstants.API_KEY, realUser.getApiKey())));
					writer.flush();
					writer.close();

				} else {

					Logger.getLogger(TAG).info("No facebookId Found!");

					// Inform user of malformed or null email address
					writer.write(APIUtils.generateJSONFailureMessage(3,
							"Facebook Returned no facebookId"));
					writer.flush();
					writer.close();
				}

			}
		} catch (Exception e) {

			Logger.getLogger(TAG).info("Returning Error", e);

			// Return generic error
			e.printStackTrace();
			writer.write(APIUtils.generateJSONFailureMessage(e));
			writer.flush();
			writer.close();
		}

		Logger.getLogger(TAG).info("Servlet complete");
	}
	// /**
	// * Get the Facebook Id
	// *
	// * @param facebookApiKey
	// * - the OAUTH Key
	// * @return the id or null
	// * @throws Exception
	// * @throws Exception
	// */
	// private JSONObject getFacebookDataAsJSON(final String facebookApiKey)
	// throws Exception {
	//
	// return ((null != facebookApiKey && !facebookApiKey.isEmpty()) ? new
	// JSONObject(readFromURL(
	// BASE_URL, facebookApiKey)) : null);
	//
	// }
	//
	// /**
	// * Read from a URL and return the string
	// *
	// * @param url
	// * - to be read from
	// * @param key
	// * - apikey
	// * @return the string read in
	// * @throws Exception
	// */
	// private String readFromURL(final String url, final String key) throws
	// Exception {
	//
	// Logger.getLogger(TAG).info("FINAL URL : " + url + URLEncoder.encode(key,
	// "UTF-8"));
	//
	// // Create the URL. Making sure to UTF-8 encode the key
	// URL address = new URL(url + URLEncoder.encode(key, "UTF-8"));
	//
	// // Create the request
	// // FIXME: Remove when GAE fixing bug
	// HTTPRequest request = new HTTPRequest(address, HTTPMethod.GET,
	// doNotValidateCertificate());
	//
	// // Get the response
	// HTTPResponse response =
	// URLFetchServiceFactory.getURLFetchService().fetch(request);
	// return new String(response.getContent());
	//
	// }

}
