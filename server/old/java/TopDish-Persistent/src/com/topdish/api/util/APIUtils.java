package com.topdish.api.util;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import org.json.JSONException;
import org.json.JSONObject;

import com.google.appengine.api.datastore.Key;
import com.topdish.api.UserLoginServlet;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;

/**
 * API Utils
 * 
 * @author Salil
 * 
 */
public class APIUtils {

	/**
	 * API Key Text = "apiKey"
	 */
	public static final String API_KEY = "apiKey";

	/**
	 * Return Code = "rc"
	 */
	public static final String RETURN_CODE = "rc";

	/**
	 * Return Message = "message"
	 */
	public static final String RETURN_MESSAGE = "message";

	/**
	 * Return Success Code = 0
	 */
	public static final int RETURN_SUCCESS = 0;

	/**
	 * Return Failure Code = 1
	 */
	public static final int RETURN_FAILURE = 1;

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
			json.put(RETURN_CODE, RETURN_SUCCESS);
			// Dont send empty message
			if (message.length() > 0)
				json.put(RETURN_MESSAGE, message);
		} catch (JSONException e) {
			// do nothing
		}
		return json.toString();
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
			json.put(RETURN_CODE, RETURN_FAILURE);
			json.put(RETURN_MESSAGE, message);
		} catch (JSONException e) {
			// do nothing
		}
		return json.toString();
	}
	
	
	/**
	 * Get the Users associated with a nickname
	 * 
	 * @param pm
	 *            - current {@link PersistenceManager}
	 * @param name
	 *            - nickname of the user
	 * @return the associated users or null
	 */
	@SuppressWarnings("unchecked")
	public static List<TDUser> getUsersAssociatedName(PersistenceManager pm,
			String name) {

		final Query q = pm.newQuery(TDUser.class);
		 q.setFilter("nickname == :param");
		final List<TDUser> users = (List<TDUser>) q.execute(name);

		return (!users.isEmpty() ? users : null);
	}
	
	
	/**
	 * Get the Users keys associated with a nickname
	 * 
	 * @param pm
	 *            - current {@link PersistenceManager}
	 * @param name
	 *            - nickname of the user
	 * @return the associated keys or null
	 */
	@SuppressWarnings("unchecked")
	public static List<Key> getUserKeysAssociatedName(PersistenceManager pm,
			String name) {
		String query = "select key from " + TDUser.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("nickname == :param");
		
		List<Key> results = (List<Key>)q.execute(name);
		
		if(!results.isEmpty()){
			return results;
		}else{
			return null;
		}
	}

}
