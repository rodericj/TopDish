package com.topdish.api.util;

import java.net.URI;
import java.net.URLEncoder;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.appengine.api.datastore.Key;
import com.topdish.api.UserLoginServlet;
import com.topdish.util.TDQueryUtils;

/**
 * API Utils
 * 
 * @author Salil
 * 
 */
public class APIUtils {
	/**
	 * Get the User associated with a given API Key
	 * 
	 * @param apiKey
	 *            - current API Key issued by the {@link UserLoginServlet}
	 * @return the associated user or null
	 * 
	 * @deprecated use {@link TDQueryUtils#getUserKeyByAPIKey}. Remove after
	 *             16-April-2011.
	 */
	@Deprecated
	public static Key getUserAssociatedWithApiKey(String apiKey) {
		return TDQueryUtils.getUserKeyByAPIKey(apiKey);
	}

	/**
	 * Generate a Success Message
	 * 
	 * @return properly formatted json success
	 */
	public static String generateJSONSuccessMessage() {
		// Redirect with empty string
		return generateJSONSuccessMessage(new JSONObject());
	}

	/**
	 * Generate a Success Message
	 * 
	 * @param message
	 *            - message to send back (optional)
	 * @return properly formatted json success
	 */
	public static String generateJSONSuccessMessage(String message) {
		try {
			return generateJSONSuccessMessage(message.length() > 0 ? new JSONObject()
					.put(APIConstants.RETURN_MESSAGE, message)
					: new JSONObject());
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return generateJSONSuccessMessage();
	}

	/**
	 * Add Success to existing {@link JSONObject}
	 * 
	 * @param json
	 *            - the current json object
	 * @return properly formatted json success
	 */
	public static String generateJSONSuccessMessage(JSONObject json) {
		try {
			json.put(APIConstants.RETURN_CODE, APIConstants.RETURN_SUCCESS);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return json.toString();
	}

	/**
	 * Add JSON Array to Success Message
	 * 
	 * @param key
	 *            - name of array
	 * @param jsonArray
	 *            - the array
	 * @return properly formatted json success with array
	 */
	public static String generateJSONSuccessMessage(String key,
			JSONArray jsonArray) {

		try {
			return generateJSONSuccessMessage(new JSONObject().put(key,
					jsonArray));
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return generateJSONSuccessMessage();

	}

	/**
	 * Generate a Failure Message
	 * 
	 * @param message
	 *            - error message to send back
	 * @return properly formatted json failure
	 */
	public static String generateJSONFailureMessage(String message) {
		return generateJSONFailureMessage(new JSONObject(), message);
	}

	/**
	 * Generate a Failure Message
	 * 
	 * @param e
	 *            - exception thrown
	 * @return properly formatted json failure
	 */
	public static String generateJSONFailureMessage(Exception e) {
		return generateJSONFailureMessage(e.getMessage());
	}

	/**
	 * Generate a Generic Failure Message
	 * 
	 * @param json
	 *            - json data to send back
	 * @param message
	 *            - message to send back
	 * @return properly formatted json failure with json object
	 */
	public static String generateJSONFailureMessage(JSONObject json,
			String message) {
		return generateJSONFailureMessage(APIConstants.RETURN_FAILURE, json,
				message);
	}

	/**
	 * Generate a Failure Message with Specific Error Code
	 * 
	 * @param returnCode
	 *            - the error code
	 * @param message
	 *            - the related message
	 * @return properly formatted json failure with message and return code
	 */
	public static String generateJSONFailureMessage(int returnCode,
			String message) {
		return generateJSONFailureMessage(returnCode, new JSONObject(), message);
	}

	/**
	 * Generate a Failure Message with Specific Error Code and JSON
	 * 
	 * @param returnCode
	 *            - error code
	 * @param json
	 *            - json data to send back
	 * @param message
	 *            - the related message
	 * @return properly formatted json failure with message and json
	 */
	public static String generateJSONFailureMessage(int returnCode,
			JSONObject json, String message) {
		try {
			json.put(APIConstants.RETURN_CODE, returnCode);
			json.put(APIConstants.RETURN_MESSAGE, message);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return json.toString();
	}

	/**
	 * <a href="http://en.wikipedia.org/wiki/UTF-8">UTF-8</a> encodes a
	 * {@link String} using the {@link URLEncoder}. If encoding fails, returns
	 * the original {@link String}
	 * 
	 * @param strToEncode
	 *            - {@link String} to encode
	 * @return the <a href="http://en.wikipedia.org/wiki/UTF-8">UTF-8</a>
	 *         encoded {@link String}
	 */
	public static String encode(String strToEncode) {
		try {
			return (new URI(null, strToEncode, null)).toString();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return strToEncode;
	}

}
