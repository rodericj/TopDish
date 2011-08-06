package com.topdish.api;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLEncoder;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.google.gson.Gson;
import com.topdish.api.jdo.TDUserLite;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;

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
	 * BASE URL to hit Facebook's Graph API
	 */
	private static final String BASE_URL = "https://graph.facebook.com/me/@@ACTION@@?access_token=";

	/**
	 * Get likes
	 */
	@SuppressWarnings("unused")
	private static final String LIKE_ACTION = "likes";

	/**
	 * Get user information
	 */
	private static final String ME_ACTION = "";

	/**
	 * DEBUG
	 */
	private static final boolean DEBUG = true;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// Get the OAuth API Key
		final String facebookApiKey = req.getParameter("facebookApiKey");

		if (null != facebookApiKey) {

			// Get Persistence Manager
			PersistenceManager pm = PMF.get().getPersistenceManager();

			try {

				// Get JSON from Facebook
				final String jsonFromFbook = readFromURL(
						"https://graph.facebook.com/me?access_token=",
						facebookApiKey);

				final JSONObject jsonObj = new JSONObject(jsonFromFbook);

				// Check for Id
				if (jsonObj.has("id")) {
					final String fbookID = jsonObj.getString("id");

					// Create user associated with user
					final TDUser user = getTDUserForFacebookId(pm, fbookID);

					if (null != user) {

						// Convert to Lite User
						final String json = new Gson().toJson(
								new TDUserLite(user)).toString();

						if (DEBUG)
							System.out.println("JSON OUT: " + json);

						// Write JSON to user
						resp.getOutputStream().write(json.getBytes());

					} else if (DEBUG)
						System.out.println("No user found with Facebook ID: "
								+ fbookID);

				} else if (DEBUG) {
					System.out
							.println("No ID Found in returned JSON. Checking for exception.");
					if (jsonObj.has("error")) {
						final JSONObject jsonError = jsonObj
								.getJSONObject("error");
						System.out
								.println("Error found from JSON. Message is: ");
						System.out.println(jsonError.getString("type")
								+ "\t:\t" + jsonError.getString("message"));
					}
				}

			} catch (Exception e) {
				e.printStackTrace();
			}

		} else if (DEBUG)
			System.out.println("Facebook API Key not found.");

	}

	/**
	 * Read from a URL and return the string
	 * 
	 * @param url
	 *            - to be read from
	 * @param key
	 *            - apikey
	 * @return the string read in
	 * @throws Exception
	 */
	private String readFromURL(final String url, final String key)
			throws Exception {

		if (DEBUG)
			System.out.println("FINAL URL : " + url
					+ URLEncoder.encode(key, "UTF-8"));

		// Create the URL. Making sure to UTF-8 encode the key
		URL address = new URL(url + URLEncoder.encode(key, "UTF-8"));
		BufferedReader in = new BufferedReader(new InputStreamReader(address
				.openStream()));

		String inputLine;
		String total = "";

		while ((inputLine = in.readLine()) != null)
			total += inputLine;

		if (DEBUG)
			System.out.println("DATA RETURNED : " + total);

		return total;
	}

	/**
	 * Given a Facebook ID, return a TDUser id
	 * 
	 * @param pm
	 * @param id
	 * @return the related TDUser
	 */
	@SuppressWarnings("unchecked")
	private TDUser getTDUserForFacebookId(PersistenceManager pm, final String id) {
		// Query
		final Query query = pm.newQuery(TDUser.class);

		// Set filter requirements to search for type
		query.setFilter("facebookId == param");
		query.declareParameters("String param");

		// List of users
		final List<TDUser> list = (List<TDUser>) query.execute(id);

		// Check null, and that only one user was returned
		return ((null != list && list.size() == 1) ? list.get(0) : null);

	}

}
