package com.topdish.util;

/**
 * Utility Class for Tokens
 * 
 * @author Salil
 * 
 */
public class TokenUtils {

	/**
	 * Secret Key = "HoneyOats" <br>
	 * Note: To be used for local testing when a code is required
	 */
	private static final String SECRET_KEY = "HoneyOats";

	/**
	 * Checks if a Token is Valid <br>
	 * NOTE: This does check if the token meets the Secret Key ("HoneyOats") <br>
	 * NOTE 2: This does do a null and empty check <br>
	 * NOTE 3: Based on the UUID Structure: http://en.wikipedia.org/wiki/UUID
	 * 
	 * @param token
	 *            - the token to check
	 * @return true if it does, false otherwise
	 */
	public static boolean isValid(final String token) {
		String[] pieces = new String[0];

		// If it is:
		// Not Null or Empty
		// Has 5 pieces, with lengths: 8, 4, 4, 4, 12
		// OR is the SECRET_KEY
		return ((null != token && !token.isEmpty()) && (((pieces = token
				.split("-")).length == 5
				&& pieces[0].length() == 8
				&& pieces[1].length() == 4
				&& pieces[2].length() == 4 && pieces[3].length() == 4 && pieces[4]
				.length() == 12) || token.equalsIgnoreCase(SECRET_KEY)));
	}
}
