package com.topdish.comms;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicHttpResponse;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.topdish.utils.QueryConstants;

/**
 * Class to handle HTTP Comms back to Server
 * 
 * @author Salil
 * 
 */
public class HTTPComms extends Thread {

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = HTTPComms.class.getName();

	/**
	 * Base URL
	 */
	// public static final String BASE_URL = "http://192.168.0.198:8888";
	// public static final String BASE_URL = "http://0223.topdish1.appspot.com";
	// public static final String BASE_URL = "http://0305.topdish1.appspot.com";
	public static final String BASE_URL = "http://www.topdish.com";

	/**
	 * Dish Search URL
	 */
	private static final String DISH_SEARCH = "/api/dishSearch?";

	/**
	 * Mobile Initialization URL
	 */
	private static final String MOBILE_INIT = "/api/mobileInit";

	/**
	 * Dish Detail URL
	 */
	private static final String DISH_DETAIL = "/api/dishSearch?";

	/**
	 * Restaurant Search URL
	 */
	private static final String RESTAURANT_SEARCH = "/api/restaurantSearch?";

	/**
	 * Dish Upload URL
	 */
	private static final String DISH_UPLOAD = "/api/dishUpload?";

	/**
	 * Handler to return data
	 */
	private Handler handler;

	/**
	 * Current URL
	 */
	private String url;

	/**
	 * Result
	 */
	private String result;

	/**
	 * Http Client
	 */
	HttpClient httpclient = new DefaultHttpClient();

	/**
	 * Start
	 */
	public static final int START = 0;

	/**
	 * Success
	 */
	public static final int SUCCESS = 1;

	/**
	 * Error
	 */
	public static final int ERROR = -1;

	/**
	 * Action to do get
	 */
	private static final int DO_GET = 0;

	/**
	 * Action to do post
	 */
	private static final int DO_POST = 1;

	/**
	 * Action to do {@link Bitmap}
	 */
	private static final int DO_BITMAP = 2;

	/**
	 * Current Action
	 */
	private int action = 0;

	/**
	 * Payload for Post Action
	 */
	private List<NameValuePair> payload = new ArrayList<NameValuePair>();

	/**
	 * Constructor that sets the Handler
	 * 
	 * @param handler
	 *            - to handle Async (or Synchronous if you use .join())
	 *            responses
	 */
	public HTTPComms(final Handler handler) {

		// Set the Handler
		this.handler = handler;

	}

	/**
	 * Default Constructor <br>
	 * <b>NOTE:</b> Make sure to use {@link #setHandler(Handler)}
	 */
	public HTTPComms() {

	}

	/**
	 * Set the {@link Handler} <br>
	 * <b>Note:</b> This method is <code>reflexive</code>
	 * 
	 * @param handler
	 *            - the handler to set
	 * @return the current {@link HTTPComms} instance
	 */
	public HTTPComms setHandler(final Handler handler) {
		this.handler = handler;
		return this;
	}

	/**
	 * Uses {@link DISH_SEARCH} url to search for Dishes.
	 * 
	 * @param lat
	 *            - latitude to search
	 * @param lon
	 *            - longitude to search
	 * @param distance
	 *            - distance from point
	 * @param limit
	 *            - total number of results
	 * @param search
	 *            - actual query text
	 */
	public void searchDishes(final double lat, final double lon, final int distance, final int limit,
			final String search) {

		this.url = BASE_URL + DISH_SEARCH;
		this.result = new String();
		this.action = DO_GET;

		this.url += QueryConstants.formed(QueryConstants.LATITUDE, String.valueOf(lat), false);
		this.url += QueryConstants.formed(QueryConstants.LONGITUDE, String.valueOf(lon));
		this.url += QueryConstants.formed(QueryConstants.LIMIT, String.valueOf(limit));
		this.url += QueryConstants.formed(QueryConstants.DISTANCE, QueryConstants.cleanDistance(distance));
		this.url += QueryConstants.formed(QueryConstants.QUERY, search);

		start();

	}

	/**
	 * Uses {@link RESTAURANT_SEARCH} url to search for Restaurants.
	 * 
	 * @param lat
	 *            - the latitude
	 * @param lon
	 *            - the longitude
	 * @param limit
	 *            - max results to return
	 * @param search
	 *            - actual query text
	 */
	public void searchRestaurant(final double lat, final double lon, final int distance, final int limit,
			final String search) {

		this.url = BASE_URL + RESTAURANT_SEARCH;
		this.result = new String();
		this.action = DO_GET;

		this.url += QueryConstants.formed(QueryConstants.QUERY, search, false);
		this.url += QueryConstants.formed(QueryConstants.LATITUDE, lat);
		this.url += QueryConstants.formed(QueryConstants.LONGITUDE, lon);
		this.url += QueryConstants.formed(QueryConstants.DISTANCE, QueryConstants.cleanDistance(distance));
		this.url += QueryConstants.formed(QueryConstants.FOREIGN, true);

		start();

	}

	/**
	 * Get the Initialized Data from the {@link MOBILE_INIT} url
	 * 
	 */
	public void mobileInit() {

		// Set url
		this.url = BASE_URL + MOBILE_INIT;

		// Set action to post
		this.action = DO_POST;

		start();

	}

	/**
	 * Uses {@link DISH_DETAIL} url to get data on a specific dish.
	 * 
	 * @param id
	 * @param handler
	 */
	public void getDish(final int id, final Handler handler) {
		this.handler = handler;
	}

	@Override
	public synchronized void start() {
		this.handler.handleMessage(Message.obtain(this.handler, START));
		super.start();
	}

	@Override
	public void run() {
		try {

			if (action == DO_GET) {
				// Send back success and data
				this.handler.handleMessage(Message.obtain(this.handler, SUCCESS, doGet()));
			} else if (action == DO_POST) {

				// Send back success and data
				this.handler.handleMessage(Message.obtain(this.handler, SUCCESS, doPost(payload)));

			} else if (action == DO_BITMAP) {

				// Send back success and image
				this.handler.handleMessage(Message.obtain(this.handler, SUCCESS, bitmap()));
			}

		} catch (Exception e) {
			e.printStackTrace();
			// Send back failure and the exception
			this.handler.handleMessage(Message.obtain(this.handler, ERROR, e));
		}
	}

	/**
	 * Get the data from the URL
	 * 
	 * @return contents returned from Get
	 * @throws Exception
	 */
	public String doGet() throws Exception {
		Log.d(TAG, "Request : " + url);

		HttpGet httpget = new HttpGet(this.url);

		// Excute against the wsdl
		BasicHttpResponse httpResponse = (BasicHttpResponse) httpclient.execute(httpget);

		return getResponse(httpResponse);
	}

	/**
	 * Post the data to a URL
	 * 
	 * @param json
	 * @return confirmation from server if any
	 */
	public String doPost(List<NameValuePair> pairs) {

		// Create Post
		HttpPost post = new HttpPost(this.url);
		BasicHttpResponse httpResponse = null;

		try {

			// Set Values
			post.setEntity(new UrlEncodedFormEntity(pairs));

			// Get the response
			httpResponse = (BasicHttpResponse) httpclient.execute(post);

		} catch (Exception e) {
			e.printStackTrace();
		}

		// Return read response
		return getResponse(httpResponse);
	}

	/**
	 * Get the response from a server after action completed
	 * 
	 * @param httpResponse
	 * @return the text returned if any
	 */
	private String getResponse(BasicHttpResponse httpResponse) {
		String toBeReturned = "";

		if (null != httpResponse)
			try {

				// Get the inputstream
				InputStream is = httpResponse.getEntity().getContent();

				// Convert to buffered reader
				BufferedReader br = new BufferedReader(new InputStreamReader(is));

				String line = "";

				// Get the full text
				while (null != (line = br.readLine())) {
					toBeReturned += line;
				}

				// For debug purposes
				Log.d(TAG, "Response: " + toBeReturned);

			} catch (Exception e) {
				e.printStackTrace();
			}

		// Return to user
		return toBeReturned;
	}

	/**
	 * Given a URL get an Image as a {@link Bitmap}
	 * 
	 * @param url
	 *            - url of the image
	 * @throws Exception
	 */
	public void getImage(String url) {
		Log.d(TAG, "Getting Image At URL: " + url);

		// Set URL and Action
		this.url = url;
		this.action = DO_BITMAP;

		// Start
		start();
	}

	/**
	 * Get the {@link Bitmap} from the address
	 * 
	 * @return the downloaded {@link Bitmap}
	 * @throws Exception
	 */
	private Bitmap bitmap() throws Exception {

		// Convert to URI
		URI uri = new URI(url);

		// Open Connection
		URLConnection connection = uri.toURL().openConnection();
		connection.connect();

		// Convert InputStream to BufferedInputStream
		InputStream is = connection.getInputStream();
		BufferedInputStream bis = new BufferedInputStream(is, 8 * 1024);

		// Decode Bitmap
		Bitmap bmp = BitmapFactory.decodeStream(bis);

		// Close Streams
		bis.close();
		is.close();

		// Return Bitmap
		return bmp;
	}

	/**
	 * Check if RC is not an Error
	 * 
	 * @param i
	 *            - the error code
	 * @return true if not error, false otherwise
	 */
	public static boolean checkError(int i) {
		return (i == 0);
	}

	public Handler getHandler() {
		return this.handler;
	}

}
