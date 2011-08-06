package com.topdish.util;

import java.net.URL;
import java.net.URLEncoder;
import java.util.Map;

import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

import com.google.appengine.api.urlfetch.HTTPMethod;
import com.google.appengine.api.urlfetch.HTTPRequest;
import com.google.appengine.api.urlfetch.HTTPResponse;
import com.google.appengine.api.urlfetch.URLFetchServiceFactory;
import com.simplegeo.client.SimpleGeoPlacesClient;
import com.simplegeo.client.types.Feature;
import com.simplegeo.client.types.FeatureCollection;
import com.simplegeo.client.types.Point;
import com.topdish.jdo.TDPoint;
import com.topdish.jdo.TDUser;

/**
 * Class to reverse geocode given certain parameters
 * 
 * @author Salil (salil@topdish.com)
 * 
 */
public class GeoUtils {
	public static String TAG = GeoUtils.class.getSimpleName();

	/**
	 * Simple OAuth Key
	 */
	private static final String SIMPLE_KEY = "rBmx5XFqqgRHGNJXgmxffjfwXFuaKw5A";

	/**
	 * Simple Secrety Key
	 */
	private static final String SIMPLE_SECRET = "XvWEgLLUx4sY8XDs5bwGSZDa2DfrUEHc";

	/**
	 * Bing Ap Id
	 */
	private static final String BING_MAP_ID = "Akxt4STii8BTRAOJ6_tZc-E4VUO1VouXFjSZrQjf3hjK856FKn77drR72_WHkn6V";

	/**
	 * Names
	 */
	public static final String TAGS = "tags";
	public static final String PHONE = "phone";
	public static final String CLASSIFIERS = "classifiers";
	public static final String ADDRESS = "address";
	public static final String NAME = "name";
	public static final String PROVINCE = "province";
	public static final String OWNER = "owner";
	public static final String POSTCODE = "postcode";
	public static final String HREF = "href";
	public static final String CITY = "city";
	public static final String COUNTRY = "country";

	public static final int RADIUS = 25;

	/**
	 * Reverse GeoCode
	 * 
	 * @param ipAddress
	 *            -to reverse code
	 * @return the point as a {@link TDPoint}
	 */
	public static TDPoint reverseIP(String ipAddress) {

		try {
			final SimpleGeoPlacesClient client = SimpleGeoPlacesClient.getInstance();
			client.getHttpClient().setToken(SIMPLE_KEY, SIMPLE_SECRET);

			final FeatureCollection fc = client.searchByIP(ipAddress, "", "", RADIUS);

			if (null != fc.getFeatures() && !fc.getFeatures().isEmpty())
				return convertFeatureToTDPoint(fc.getFeatures().get(0));

		} catch (Exception e) {
			// e.printStackTrace();
		}

		Logger.getLogger(TAG).info("Using default point - San Francisco");
		return defaultTDPoint();
	}

	/**
	 * Reverse Geo-code the Address
	 * 
	 * @param streetAddress
	 *            - the street address
	 * @param city
	 *            - the city
	 * @param state
	 *            - the city
	 * @return the geocoded {@link TDPoint}
	 */
	public static TDPoint reverseAddress(String address, String city, String state) {
		return googleGeocode(address + " " + city + ", " + state);
	}

	private static TDPoint googleGeocode(String address) {
		try {
			// URL to send to Google
			final URL url = new URL("https://maps.googleapis.com/maps/api/geocode/json?"
					+ "address=" + URLEncoder.encode(address, "UTF-8") + "&sensor=false");

			Logger.getLogger(TAG).info("Connecting to url: " + url.toString());

			// Create the request
			final HTTPRequest request = new HTTPRequest(url, HTTPMethod.GET);

			// Get the response
			final HTTPResponse response = URLFetchServiceFactory.getURLFetchService()
					.fetch(request);

			final String respStr = new String(response.getContent());

			Logger.getLogger(TAG).info("response from google: " + respStr);

			// Pull out the returned data
			final JSONObject json = new JSONObject(respStr);
			final JSONArray results = json.getJSONArray("results");
			final String formattedAddress = results.getJSONObject(0).getString("formatted_address");
			final JSONObject location = results.getJSONObject(0).getJSONObject("geometry")
					.getJSONObject("location");
			// final JSONArray addressComponents =
			// results.getJSONObject(0).getJSONArray("address_components");

			double lat = location.getDouble("lat");
			double lng = location.getDouble("lng");

			return new TDPoint(lat, lng, formattedAddress, "", "");

		} catch (Exception e) {
			// e.printStackTrace();
		}
		Logger.getLogger(TAG).info("Using default point - San Francisco");
		return defaultTDPoint();
	}

	@SuppressWarnings("unused")
	private static TDPoint bingGeocode(String streetAddress, String city, String state) {
		if (null != streetAddress && !streetAddress.isEmpty())
			try {

				// URL to get data from Bing
				final URL url = new URL(
						"http://dev.virtualearth.net/REST/v1/Locations?addressLine="
								+ URLEncoder.encode(streetAddress, "UTF-8") + "&adminDistrict="
								+ URLEncoder.encode(state, "UTF-8") + "&locality="
								+ URLEncoder.encode(city, "UTF-8") + "&key="
								+ URLEncoder.encode(BING_MAP_ID, "UTF-8"));

				System.out.println("URL: " + url.toString());

				// Create the request
				final HTTPRequest request = new HTTPRequest(url, HTTPMethod.GET);

				// Get the response
				final HTTPResponse response = URLFetchServiceFactory.getURLFetchService().fetch(
						request);

				final String respStr = new String(response.getContent());

				System.out.println(respStr);

				final JSONObject json;

				// Pull out the returned data
				json = new JSONObject(respStr);
				final JSONArray array = json.getJSONArray("resourceSets");

				if (array.length() > 0) {

					final JSONObject firstObj = array.getJSONObject(0);
					final JSONArray resourceA = firstObj.getJSONArray("resources");

					if (resourceA.length() > 0) {

						Logger.getLogger(TAG).info("returned JSON: " + resourceA.getJSONObject(0));

						final JSONObject pointObj = resourceA.getJSONObject(0).getJSONObject(
								"point");
						final JSONArray pointA = pointObj.getJSONArray("coordinates");

						Logger.getLogger(TAG).info("point JSON: " + pointObj.toString());

						final JSONObject address = resourceA.getJSONObject(0).getJSONObject(
								"address");

						if (pointA.length() >= 2) {
							String foundCity = "";
							String foundState = "";
							String foundPostalCode = "";
							String compositeAddress = "";

							if (address.has("locality")) {
								foundCity = address.getString("locality");
								compositeAddress += foundCity;
							}
							if (address.has("adminDistrict")) {
								foundState = address.getString("adminDistrict");
								if (compositeAddress.length() > 0) {
									compositeAddress += ", " + foundState;
								} else {
									compositeAddress += foundState;
								}
							}
							if (address.has("postalCode")) {
								foundPostalCode = address.getString("postalCode");
								if (compositeAddress.length() > 0) {
									compositeAddress += " " + foundPostalCode;
								} else {
									compositeAddress += foundPostalCode;
								}
							}

							return new TDPoint(pointA.getDouble(0), pointA.getDouble(1),
									compositeAddress, foundCity, foundState);
						}
					}
				}

			} catch (Exception e) {
				// e.printStackTrace();
			}
		Logger.getLogger(TAG).info("Using default point - San Francisco");
		return defaultTDPoint();
	}

	/**
	 * Reverse a Lat Lon
	 * 
	 * @param lat
	 *            - latitude
	 * @param lon
	 *            - longitude
	 * @return the point as {@link TDPoint}
	 */
	public static TDPoint reverseLatLon(double lat, double lon) {
		return reverseLatLonGoogle(lat, lon);
	}

	private static TDPoint reverseLatLonGoogle(double lat, double lng) {
		try {
			// URL to send to Google
			final URL url = new URL("https://maps.googleapis.com/maps/api/geocode/json?"
					+ "latlng=" + lat + "," + lng + "&sensor=false");

			Logger.getLogger(TAG).info("Connecting to url: " + url.toString());

			// Create the request
			final HTTPRequest request = new HTTPRequest(url, HTTPMethod.GET);

			// Get the response
			final HTTPResponse response = URLFetchServiceFactory.getURLFetchService()
					.fetch(request);

			final String respStr = new String(response.getContent());

			Logger.getLogger(TAG).info("response from google: " + respStr);

			// Pull out the returned data
			final JSONObject json = new JSONObject(respStr);
			final JSONArray results = json.getJSONArray("results");
			final String formattedAddress = results.getJSONObject(0).getString("formatted_address");
			// final JSONObject location =
			// results.getJSONObject(0).getJSONObject("geometry").getJSONObject("location");
			// final JSONArray addressComponents =
			// results.getJSONObject(0).getJSONArray("address_components");

			return new TDPoint(lat, lng, formattedAddress, "", "");

		} catch (Exception e) {
			// e.printStackTrace();
		}

		Logger.getLogger(TAG).info("Using default point - San Francisco");
		return defaultTDPoint();
	}

	@SuppressWarnings("unused")
	private static TDPoint reverseLatLonSimpleGeo(double lat, double lon) {
		final SimpleGeoPlacesClient client = SimpleGeoPlacesClient.getInstance();
		client.getHttpClient().setToken(SIMPLE_KEY, SIMPLE_SECRET);

		try {
			final FeatureCollection fc = client.search(lat, lon, "", "", RADIUS);

			if (!fc.getFeatures().isEmpty())
				return convertFeatureToTDPoint(fc.getFeatures().get(0));

		} catch (Exception e) {
			e.printStackTrace();
		}
		return defaultTDPoint();
	}

	/**
	 * Get the default point
	 * 
	 * @return a {@link TDUser} point that points to San Francisco CA
	 */
	public static TDPoint defaultTDPoint() {
		Logger.getLogger(TAG).info("Using default point - San Francisco");
		return new TDPoint(37.77825, -122.42555, "San Francisco CA", "San Francisco", "CA");
	}

	/**
	 * Convert a {@link Feature} to a {@link TDPoint}
	 * 
	 * @param feature
	 *            - the feature
	 * @return the fixed {@link TDPoint}
	 */
	private static TDPoint convertFeatureToTDPoint(Feature feature) {
		final Map<String, Object> props = feature.getProperties();
		final Point point = feature.getGeometry().getPoint();
		return new TDPoint(point.getLat(), point.getLon(), String.valueOf(props.get(ADDRESS)),
				String.valueOf(props.get(CITY)), String.valueOf(props.get(PROVINCE)));
	}

	/**
	 * For Testing
	 * 
	 * @param args
	 *            - unused arguements
	 */
	public static void main(String[] args) {
		final String ip = "24.205.94.144";
		final String address = "479 St Francis Dr. Danville CA 94526";
		final double lat = 37.792028;
		final double lon = -121.968152;

		System.out.println("SEARCHING BY IP : " + ip + "\n" + GeoUtils.reverseIP(ip));
		System.out.println("SEARCHING BY ADDRESS : " + address + "\n"
				+ GeoUtils.reverseAddress("479 St Francis Dr", "Danville", "CA"));
		System.out.println("SEARCHING BY LAT,LON : " + lat + "," + lon + "\n"
				+ GeoUtils.reverseLatLon(lat, lon));

	}
}
