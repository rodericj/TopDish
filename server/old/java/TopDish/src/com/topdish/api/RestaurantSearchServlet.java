package com.topdish.api;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.beoui.geocell.model.Point;
import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.google.appengine.api.urlfetch.HTTPMethod;
import com.google.appengine.api.urlfetch.HTTPRequest;
import com.google.appengine.api.urlfetch.HTTPResponse;
import com.google.appengine.api.urlfetch.URLFetchServiceFactory;
import com.google.gson.Gson;
import com.topdish.api.jdo.RestaurantLite;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.ConvertToLite;
import com.topdish.api.util.RestaurantConstants;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Source;
import com.topdish.util.Datastore;
import com.topdish.util.DuplicateChecker;
import com.topdish.util.TDQueryUtils;

public class RestaurantSearchServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 2940294218710551199L;

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = RestaurantSearchServlet.class.getSimpleName();

	/**
	 * Bing Ap Id
	 */
	private static final String BING_AP_ID = "3F3D5CF7606BF4348DB45861A9D43B523171DA70";

	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		// resp.setCharacterEncoding(APIConstants.UTF8_ENCODING);

		final String query = req.getParameter(APIConstants.QUERY);
		double lat = 0.0;
		double lng = 0.0;
		int maxDistance = 16090; // 10 miles
		int maxResults = 20;
		String[] searchTerms = {};

		// Get lat and long
		try {
			lat = Double.parseDouble(req.getParameter(APIConstants.LAT));
			lng = Double.parseDouble(req.getParameter(APIConstants.LNG));
		} catch (NumberFormatException e) {
			e.printStackTrace();
		} catch (NullPointerException e) {
			e.printStackTrace();
		}

		// Preset Defaults
		try {
			maxDistance = Integer.parseInt(req.getParameter(APIConstants.DISTANCE));
			maxResults = Integer.parseInt(req.getParameter(APIConstants.LIMIT));
			maxResults = (maxResults <= 50 ? maxResults : 50);
		} catch (Exception e) {
			// No big deal, defaults set
		}

		if (null != query && !query.isEmpty())
			searchTerms = query.split(" ");

		Set<Restaurant> restaurants = TDQueryUtils.searchGeoItems(searchTerms, new Point(lat, lng),
				maxResults, maxDistance, new Restaurant());

		boolean checkBing = (null != req.getParameter("foreign") && Boolean.parseBoolean(req
				.getParameter("foreign")));

		if (checkBing)
			Logger.getLogger(TAG).info("User wants Bing data");

		boolean checkEmpty = (null == restaurants || (null != restaurants && restaurants.isEmpty()));

		if (checkEmpty)
			Logger.getLogger(TAG).info("TD Search is Empty, searching Bing!");

		// Check if user wants foreign results or not
		if (checkBing || checkEmpty) {
			try {
				if (null == restaurants)
					restaurants = new HashSet<Restaurant>();
				bingRestaurants(query, lat, lng, maxDistance, maxResults, restaurants);
			} catch (Exception e) {
				e.printStackTrace();
				Logger.getLogger(TAG).info("Failed Bing look up");
			}
		}

		if (null != restaurants && !restaurants.isEmpty()) {
			final JSONArray jsonArray = new JSONArray();

			final long startConvert = System.currentTimeMillis();

			// Traverse each restaurant
			for (final RestaurantLite r : ConvertToLite.convertRestaurants(restaurants)) {
				try {
					// Put it in the array
					jsonArray.put(new JSONObject(new Gson().toJson(r)));
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}

			final long endConvert = System.currentTimeMillis();

			Logger.getLogger(TAG).info(
					"Conversion from Restaurant to Lite: " + (endConvert - startConvert));

			// Write success with Array
			resp.getWriter()
					.write(
							APIUtils.generateJSONSuccessMessage(RestaurantConstants.RESTAURANTS,
									jsonArray));
		} else
			resp.getWriter().write(APIUtils.generateJSONFailureMessage("No restaurants found."));
	}

	/**
	 * Bing Restaurant search <br>
	 * Note: This method uses pass by reference, so pass it a the {@link Set} of
	 * existing {@link Restaurant}s and you will get back the orriginal list
	 * plus additional restaurants pulled from Bing's API.
	 * 
	 * @param query
	 *            - the query text
	 * @param lat
	 *            - the latitude
	 * @param lng
	 *            - the longitude
	 * @param radius
	 *            - the radius
	 * @param maxResults
	 *            - the max number of results
	 * @param existingRest
	 *            - list of existing {@link Restaurant}s to add the Bing results
	 *            to
	 * @throws Exception
	 */
	private void bingRestaurants(String query, double lat, double lng, int radius, int maxResults,
			Set<Restaurant> existingRest) throws Exception {

		// Restaurants to be return
		// final Set<Restaurant> restaurants = new HashSet<Restaurant>();

		// Get the source
		final Set<Source> sources = TDQueryUtils.searchSourcebyName("Bing", 1);

		Source source;

		// Check null or empty, if not get the first source
		if (null != sources && !sources.isEmpty())
			source = sources.iterator().next();
		else {
			// Create a new Source
			Link bingURL = new Link("http://www.bing.com");
			source = new Source("Bing", bingURL);
			Datastore.put(source);
		}

		// Convert to miles since thats what Bing API Requires
		radius /= 1609;

		// URL to get data from Bing
		final URL url = new URL("http://api.bing.net/json.aspx?" + "AppId=" + encode(BING_AP_ID)
				+ "&Query=restaurant" + encode(" " + (null != query ? query : new String()))
				+ "&Sources=Phonebook&Version=2.0&Market=en-us&UILanguage=en&Latitude=" + lat
				+ "&Longitude=" + lng + "&Radius=" + radius
				+ "&Options=EnableHighlighting&Phonebook.Count="
				+ (maxResults <= 25 ? maxResults : 25)
				+ "&Phonebook.Offset=0&Phonebook.FileType=YP&Phonebook.SortBy=Distance");
		Logger.getLogger(TAG).info("URL : " + url.toString());

		// Create the request
		final HTTPRequest request = new HTTPRequest(url, HTTPMethod.GET);

		final long startCall = System.currentTimeMillis();

		// Get the response
		final HTTPResponse response = URLFetchServiceFactory.getURLFetchService().fetch(request);

		final long endCall = System.currentTimeMillis();

		Logger.getLogger(TAG).info("Call to Bing took: " + (endCall - startCall));

		final long startTranslate = System.currentTimeMillis();

		final String respStr = new String(response.getContent());

		Logger.getLogger(TAG).info("RESPONSE SIZE: " + respStr.length());

		final JSONObject json;

		try {
			// Pull out the returned data
			json = new JSONObject(respStr).getJSONObject("SearchResponse").getJSONObject(
					"Phonebook");
		} catch (Exception e) {
			Logger.getLogger(TAG).info("Bing Returned No Data!");

			// Exit the method
			return;
		}

		// Check that items were returned
		if (json.getInt("Total") > 0) {

			// Array of Results
			final JSONArray resultsArray = json.getJSONArray("Results");

			// Traverse Objects returned
			for (int i = 0; i < resultsArray.length(); i++) {
				try {
					// Get the current object
					final JSONObject curObj = resultsArray.getJSONObject(i);

					// Pull out relevant data
					final String name = curObj.getString("Title");
					final String addressLine1 = curObj.getString("Address");
					final String addressLine2 = new String();
					final String city = curObj.getString("City");
					final String state = curObj.getString("StateOrProvince");
					final String neighborhood = new String();
					final double latitude = curObj.getDouble("Latitude");
					final double longitude = curObj.getDouble("Longitude");
					final PhoneNumber phone = new PhoneNumber(curObj.getString("PhoneNumber"));
					final String gid = new String();

					Link link;

					if (curObj.has("BusinessUrl"))
						link = new Link(URLDecoder.decode(curObj.getString("BusinessUrl"), "UTF-8"));
					else
						link = new Link(URLDecoder.decode(curObj.getString("Url"), "UTF-8"));

					// Create Restaurant object
					Restaurant curRest = new Restaurant(name, addressLine1, addressLine2, city,
							state, neighborhood, latitude, longitude, phone, gid, link, new Date(),
							source.getCreator());
					curRest.addSource(source.getKey(), curObj.getString("UniqueId"));

					if (!DuplicateChecker.checkDuplicate(curRest, existingRest)) {
						existingRest.add(curRest);
					}

				} catch (Exception e) {
					e.printStackTrace();

					Logger.getLogger(TAG).info("SKIPPED");
				}
			}

			if (!existingRest.isEmpty())
				Datastore.put(existingRest);

			final long endTranslate = System.currentTimeMillis();

			Logger.getLogger(TAG).info("Translation took: " + (endTranslate - startTranslate));

		}
	}

	/**
	 * URL Encode a String as UTF-8
	 * 
	 * @param str
	 * @return returns the encoded string or the orriginal string on error
	 */
	private String encode(String str) {
		try {
			return URLEncoder.encode(str, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return str;
		}
	}
}
