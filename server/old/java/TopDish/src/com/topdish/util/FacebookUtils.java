package com.topdish.util;

import static com.google.appengine.api.urlfetch.FetchOptions.Builder.doNotValidateCertificate;

import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.Logger;
import org.json.JSONObject;

import com.google.appengine.api.urlfetch.HTTPMethod;
import com.google.appengine.api.urlfetch.HTTPRequest;
import com.google.appengine.api.urlfetch.HTTPResponse;
import com.google.appengine.api.urlfetch.URLFetchServiceFactory;
import com.topdish.api.util.FacebookConstants;

public class FacebookUtils {

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = FacebookUtils.class.getSimpleName();

	/**
	 * Given a "code" call the Facebook Auth server and returns the values
	 * returned by Facebook
	 * 
	 * @param code
	 *            - the "code" recieved from Facebook Auth
	 * @return a map containing name values of all data returned by Facebook
	 */
	public static Map<String, String> getAccessToken(final String code) throws Exception {

		Logger.getLogger(TAG).info("Running with the Code: " + code);

		final Map<String, String> toBeReturned = new HashMap<String, String>();

		final String redirectURL = FacebookConstants.FACEBOOK_BASE_REDIRECT_URI + "/facebookLogin";

		final String url = "https://graph.facebook.com/oauth/access_token?client_id="
				+ FacebookConstants.APP_ID + "&redirect_uri=" + redirectURL + "&client_secret="
				+ FacebookConstants.APP_SECRET + "&code=" + URLEncoder.encode(code, "UTF-8");

		// response.sendRedirect(url);
		Logger.getLogger(TAG).info("URL : " + url);

		URL address = new URL(url);

		// Create the request
		// TODO: Remove when GAE fixing bug
		HTTPRequest httpReq = new HTTPRequest(address, HTTPMethod.GET, doNotValidateCertificate());

		// Get the response
		HTTPResponse httpResp = URLFetchServiceFactory.getURLFetchService().fetch(httpReq);

		// Get the fields from text returned
		final String fields = new String(httpResp.getContent());

		Logger.getLogger(TAG).info("Final: " + fields);

		// Break fields along &
		final String[] brokenUpFields = fields.split("&");

		// Traverse fields
		for (final String field : brokenUpFields) {
			// Split on an equals
			final String[] curFields = field.split("=");
			// Check that it split name value and none are null
			if (curFields.length == 2 && (null != curFields[0] && !curFields[0].isEmpty())
					&& (null != curFields[1] && !curFields[1].isEmpty())) {

				Logger.getLogger(TAG).info("Adding: " + curFields[0] + "\t:\t" + curFields[1]);

				// Put in the map
				toBeReturned.put(curFields[0], curFields[1]);
			}
		}

		return toBeReturned;
	}

	/**
	 * Get the Facebook Id
	 * 
	 * @param facebookApiKey
	 *            - the OAUTH Key
	 * @return the id or null
	 * @throws Exception
	 * @throws Exception
	 */
	public static JSONObject getFacebookDataAsJSON(final String facebookApiKey) throws Exception {
		final String BASE_URL = "https://graph.facebook.com/me?access_token=";

		return ((null != facebookApiKey && !facebookApiKey.isEmpty()) ? new JSONObject(readFromURL(
				BASE_URL, facebookApiKey)) : null);

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
	public static String readFromURL(final String url, final String key) throws Exception {

		Logger.getLogger(TAG).info("FINAL URL : " + url + URLEncoder.encode(key, "UTF-8"));

		// Create the URL. Making sure to UTF-8 encode the key
		URL address = new URL(url + URLEncoder.encode(key, "UTF-8"));

		// Create the request
		// FIXME: Remove when GAE fixing bug
		HTTPRequest request = new HTTPRequest(address, HTTPMethod.GET, doNotValidateCertificate());

		// Get the response
		HTTPResponse response = URLFetchServiceFactory.getURLFetchService().fetch(request);
		return new String(response.getContent());

	}

}
