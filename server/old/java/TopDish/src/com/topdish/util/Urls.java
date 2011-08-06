package com.topdish.util;

import static com.google.appengine.api.urlfetch.FetchOptions.Builder.doNotValidateCertificate;

import java.net.URL;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;

import com.google.appengine.api.urlfetch.HTTPMethod;
import com.google.appengine.api.urlfetch.HTTPRequest;
import com.google.appengine.api.urlfetch.HTTPResponse;
import com.google.appengine.api.urlfetch.URLFetchServiceFactory;
import com.topdish.api.util.APIUtils;

/**
 * Class to create short urls using our custom tpdi.sh domain.
 * 
 * @author ralmand
 * 
 */
public class Urls {
	private static String BITLY_URL = "http://api.bitly.com/v3/shorten?login=topdish&apiKey=R_2c071ce1667fde164e4e13af609106e5&format=txt&longUrl=";
	private static String TAG = Urls.class.getSimpleName();

	/**
	 * Shortens a given url.
	 * 
	 * @param url
	 *            {@link String} url.
	 * @return a {@link String} shortened url.
	 */
	public static String shorten(String url) {
		return textRequest(url);
	}

	/**
	 * Shortens a url based on the given <@link {@link HttpServletRequest}.
	 * 
	 * @param request
	 *            a {@link HttpServletRequest}.
	 * @return a {@link String} shortened url.
	 */
	public static String shorten(HttpServletRequest request) {
		if (null != request.getQueryString()) {
			final String fullUrl = request.getRequestURL().append("?" + request.getQueryString())
					.toString();
			return textRequest(APIUtils.encode(fullUrl));
		} else {
			return textRequest(APIUtils.encode(request.getRequestURL().toString()));
		}
	}

	/**
	 * Private method to shorten a string url.
	 * 
	 * @param longUrl
	 *            {@link String} url.
	 * @return a {@link String} shortened url.
	 */
	private static String textRequest(String longUrl) {
		try {
			Logger.getLogger(TAG).info("Shortening url: " + longUrl);

			URL address = new URL(BITLY_URL + longUrl);

			Logger.getLogger(TAG).info("Sending request to bitly: " + address.toString());

			// Create the request
			// TODO: Remove when GAE fixing bug
			HTTPRequest httpReq = new HTTPRequest(address, HTTPMethod.GET,
					doNotValidateCertificate());

			// Get the response
			HTTPResponse httpResp = URLFetchServiceFactory.getURLFetchService().fetch(httpReq);

			// Get the fields from text returned
			final String fields = new String(httpResp.getContent());

			Logger.getLogger(TAG).info("Final: " + fields);

			return fields;
		} catch (Exception e) {
			// shit hit the fan
			Logger.getLogger(TAG).info("Shit hit the fan - could not generate short URL");
		}

		return null;
	}
}
