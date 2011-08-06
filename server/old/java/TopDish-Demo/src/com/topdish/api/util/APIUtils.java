package com.topdish.api.util;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.topdish.api.UserLoginServlet;
import com.topdish.jdo.TDUser;

/**
 * API Utils
 * 
 * @author Salil
 * 
 */
public class APIUtils {

	/**
	 * Check if the Api Key is Valid
	 * 
	 * @param pm
	 *            - current {@link PersistenceManager}
	 * @param apiKey
	 *            - current API Key issued by the {@link UserLoginServlet}
	 * @return true if user exists, false otherwise
	 */
	public static boolean checkValidApiKey(PersistenceManager pm, String apiKey) {
		return (null != getUserAssociatedWithApiKey(pm, apiKey));
	}

	/**
	 * Get the User associated with a given API Key
	 * 
	 * @param pm
	 *            - current {@link PersistenceManager}
	 * @param apiKey
	 *            - current API Key issued by the {@link UserLoginServlet}
	 * @return the associated user or null
	 */
	@SuppressWarnings("unchecked")
	public static TDUser getUserAssociatedWithApiKey(PersistenceManager pm,
			String apiKey) {

		final Query q = pm.newQuery(TDUser.class);
		q.setFilter("ApiKey == :param");
		final List<TDUser> users = (List<TDUser>) q.execute(apiKey);

		return (!users.isEmpty() ? users.get(0) : null);
	}

	/**
	 * Generate a Success Message
	 * 
	 * @return properly formatted json success
	 */
	public static String generateJSONSuccessMessage() {
		// Redirect with empty string
		return generateJSONSuccessMessage(new String());
	}

	/**
	 * Generate a Success Message
	 * 
	 * @param message
	 *            - message to send back (optional)
	 * @return properly formatted json success
	 */
	public static String generateJSONSuccessMessage(String message) {
		final JSONObject json = new JSONObject();
		try {
			json.put(APIConstants.RETURN_CODE, APIConstants.RETURN_SUCCESS);
			// Dont send empty message
			if (message.length() > 0)
				json.put(APIConstants.RETURN_MESSAGE, message);
		} catch (JSONException e) {
			// do nothing
		}
		return json.toString();
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

		final JSONObject jsonO = new JSONObject();

		try {
			jsonO.put(APIConstants.RETURN_CODE, APIConstants.RETURN_SUCCESS);
			jsonO.put(key, jsonArray);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return jsonO.toString();
	}

	/**
	 * Generate a Failure Message
	 * 
	 * @param message
	 *            - error message to send back
	 * @return properly formatted json failure
	 */
	public static String generateJSONFailureMessage(String message) {
		final JSONObject json = new JSONObject();
		try {
			json.put(APIConstants.RETURN_CODE, APIConstants.RETURN_FAILURE);
			json.put(APIConstants.RETURN_MESSAGE, message);
		} catch (JSONException e) {
			// do nothing
		}
		return json.toString();
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

}
