package com.topdish.util;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.code.geocoder.GeocodeResponse;
import com.google.code.geocoder.Geocoder;
import com.google.code.geocoder.GeocoderRequest;
import com.google.code.geocoder.GeocoderResult;
import com.google.code.geocoder.LatLng;
import com.topdish.api.util.FacebookConstants;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.TDPoint;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.TDUserRole;

/**
 * Provides various methods for checking a user's status or presence in the
 * datastore.
 * 
 * @author ralmand (Randy Almand)
 * 
 */
public class TDUserService {

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = TDUserService.class.getSimpleName();

	/**
	 * Return the currently logged in {@link TDUser}.
	 * 
	 * @param pm
	 *            a {@link PersistenceManager} instance.
	 * @return the currently logged in {@link TDUser}
	 * @throws UserNotLoggedInException
	 * @throws UserNotFoundException
	 * @deprecated Use {@link TDUserService#getUser()}
	 */
	@Deprecated
	public static TDUser getUser(PersistenceManager pm) throws UserNotLoggedInException,
			UserNotFoundException {
		return getUser();
	}

	/**
	 * Gets the currently logged in {@link TDUser}
	 * 
	 * @return The currently logged in {@link TDUser}
	 * @throws UserNotLoggedInException
	 * @throws UserNotFoundException
	 * @deprecated use {@link TDUserService#getUser(HttpSession)} instead
	 */
	@Deprecated
	public static TDUser getUser() throws UserNotLoggedInException, UserNotFoundException {
		final User user = UserServiceFactory.getUserService().getCurrentUser();
		if (null != user) {
			return Datastore.get(TDQueryUtils.getUserKeyByUserId(user.getUserId()));
		}
		return null;
	}

	/**
	 * Gets the current logged in user <br>
	 * &nbsp;Note: This does Facebook a lookup in the {@link HttpSession} for
	 * facebook id
	 * 
	 * @param session
	 *            - the current user's session
	 * @return the {@link TDUser}
	 * @throws UserNotFoundException
	 * @throws UserNotLoggedInException
	 */
	public static TDUser getUser(HttpSession session) throws UserNotFoundException,
			UserNotLoggedInException {
		TDUser toReturn = null;

		// Get Google User
		final User gUser = UserServiceFactory.getUserService().getCurrentUser();
		if (null != gUser) {
			final Key userKey = TDQueryUtils.getUserKeyByUserId(gUser.getUserId());
			if (null != userKey) {
				toReturn = Datastore.get(userKey);
			}
		}

		// Get Facebook User
		if (null == toReturn && null != session) {

			if (null == session.getAttribute(FacebookConstants.FACEBOOK_ID))
				throw new UserNotFoundException();

			if (null == session.getAttribute(FacebookConstants.FACEBOOK_OAUTH_KEY))
				throw new UserNotLoggedInException();

			Key key = TDQueryUtils.getUserForFacebookId(String.valueOf(session
					.getAttribute(FacebookConstants.FACEBOOK_ID)));

			if (null != key)
				toReturn = Datastore.get(key);

		}

		if (null == toReturn)
			throw new UserNotFoundException();

		return toReturn;
	}

	/**
	 * Return if the user is logged in or not.
	 * 
	 * @deprecated use {@link #isUserLoggedIn(HttpSession)} instead.
	 */
	@Deprecated
	public static boolean getUserLoggedIn() {
		return isUserLoggedIn();
	}

	/**
	 * Return if the user is logged in or not.
	 * 
	 * @return true if the user is logged in, false otherwise
	 * @deprecated use {@link #isUserLoggedIn(HttpSession)} as it handles
	 *             sessions and can check for facebook users
	 */
	@Deprecated
	public static boolean isUserLoggedIn() {
		try {
			return (null != TDUserService.getUser());
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Returns if the user is <em>Authenticated</em>, not necessarily if they
	 * have a {@link TDUser} object yet.
	 * 
	 * @param request
	 *            the {@link HttpServletRequest}
	 * @return true if user is authenticated, false otherwise
	 */
	public static boolean isUserAuthenticated(HttpServletRequest request) {
		return isFacebookUser(request.getSession()) || isGoogleUser(request);
	}

	/**
	 * Return if the user is logged in or not
	 * 
	 * @param session
	 *            - the current session
	 * @return true if user is logged in, false otherwise
	 */
	public static boolean isUserLoggedIn(HttpSession session) {
		try {
			return (null != TDUserService.getUser(session));
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Return if the user is an admin
	 * 
	 * @return true if the user is an admin, false otherwise
	 */
	public static boolean isAdmin() {
		try {
			return TDUserService.getUser().getRole() == TDUserRole.ROLE_ADMIN;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Retrieve the User's Location by pulling out the cookies from an
	 * {@link HttpServletRequest}.
	 * 
	 * @param request
	 *            - the http request
	 * @return the users location as a Point, or the default location (SF Civic
	 *         Center)
	 */
	public static TDPoint getUserLocation(HttpServletRequest request) {
		if (null != request.getSession().getAttribute("location")) {
			return (TDPoint) request.getSession().getAttribute("location");
		} else {
			final TDPoint location = GeoUtils.reverseIP(request.getLocalAddr());
			request.getSession().setAttribute("location", location);
			return location;
		}
	}

	/**
	 * Set the user's location in the session.
	 * 
	 * @param location
	 *            a <@link TDPoint> location
	 * @param request
	 *            the current HTTP Request
	 */
	public static void setUserLocation(TDPoint location, HttpServletRequest request) {
		Logger.getLogger(TAG).info(
				"Setting location to " + location.getLat() + ", " + location.getLon() + "; "
						+ location.getCity() + ", " + location.getState());
		request.getSession(true).setAttribute("location", location);
	}

	/**
	 * Set the user's location and receive it back as a Point
	 * 
	 * @param address
	 *            - the address the user entered
	 * @param request
	 *            - the current HTTP Request
	 * @return the point of the new location if lookup is successful. Otherwise
	 *         last known good location of user is returned
	 * @deprecated No longer does what it was supposed to do.
	 */
	@Deprecated
	public static TDPoint setUserLocation(String address, HttpServletRequest request) {

		// Instaitate the GeoCoder
		final Geocoder geocoder = new Geocoder();

		// Do a look up for the given address
		final GeocodeResponse result = geocoder.geocode(new GeocoderRequest(address));

		// Point to be returned
		final TDPoint toBeReturned;

		// Check Emtpy Results
		if (null != result && !result.getResults().isEmpty()) {

			// Get the current result
			final GeocoderResult curResult = result.getResults().get(0);
			// Pull out lat and long
			final LatLng geo = curResult.getGeometry().getLocation();

			// Set the new Point
			toBeReturned = new TDPoint(geo.getLat().doubleValue(), geo.getLng().doubleValue(),
					curResult.getFormattedAddress());

		} else {
			// Return default location if lookup failed
			toBeReturned = getUserLocation(request);
		}

		return toBeReturned;
	}

	/**
	 * Check if the current user is a Facebook User
	 * 
	 * @param session
	 *            - the current {@link HttpSession}
	 * @return <code>true</code> if the user is a Facebook User,
	 *         <code>false</code> otherwise
	 */
	public static boolean isFacebookUser(HttpSession session) {
		return (null != session.getAttribute(FacebookConstants.FACEBOOK_ID) && null != session
				.getAttribute(FacebookConstants.FACEBOOK_OAUTH_KEY));
	}

	/**
	 * Check if the current user is a Facebook User
	 * 
	 * @param request
	 *            - the current {@link HttpServletRequest}
	 * @return <code>true</code> if the user is a Facebook User,
	 *         <code>false</code> otherwise
	 */
	public static boolean isFacebookUser(HttpServletRequest request) {
		return isFacebookUser(request.getSession());
	}

	/**
	 * Checkif the current user is a Google user
	 * 
	 * @param request
	 *            - the current request
	 * @return <code>true</code> if the {@link User} is a Google User,
	 *         <code>false</code> otherwise
	 */
	public static boolean isGoogleUser(HttpServletRequest request) {
		return null != UserServiceFactory.getUserService().getCurrentUser();
	}

	/**
	 * Get the Facebook login URL with a given redirect.
	 * 
	 * @param redirect
	 *            the url to redirect to after a successful login
	 * @return the login URL
	 */
	public static String getFacebookLoginURL(final String redirect) {
		final String loginUrl = "https://www.facebook.com/dialog/oauth?client_id=%1$s&redirect_uri=%2$s";
		return String.format(loginUrl, FacebookConstants.APP_ID, redirect);
	}

	/**
	 * Get the Google login URL with a given redirect.
	 * 
	 * @param redirect
	 * @return
	 */
	public static String getGoogleLoginURL(final String redirect) {
		return UserServiceFactory.getUserService().createLoginURL(redirect);
	}

	/**
	 * Return the logout URL to redirect to index.jsp.
	 * 
	 * @return logout URL
	 */
	public static String getGoogleLogoutURL() {
		return getGoogleLogoutURL("index.jsp");
	}

	/**
	 * Return the logout URL to redirect to the given destination.
	 * 
	 * @param destination
	 *            URL to redirect to after a successful logout
	 * @return logout URL
	 */
	public static String getGoogleLogoutURL(final String destination) {
		return UserServiceFactory.getUserService().createLogoutURL(destination);
	}

	/**
	 * Get a logout url with the default redirect back to index.jsp.
	 * 
	 * @return the properly formatted logout url
	 */
	public static String getLogoutURL() {
		return getLogoutURL("../index.jsp");
	}

	/**
	 * Get a Logout URL and redirect to a given address
	 * 
	 * @param destination
	 *            - redirect location
	 * @return the properly formatted logout url
	 */
	public static String getLogoutURL(final String redirect) {
		return "../api/logout?redirect=" + redirect;
	}

	/**
	 * Pairs a given {@link TDUser} with either a Google {@link User} or a
	 * Facebook ID. <br>
	 * 
	 * @param tdUser
	 *            the {@link TDUser} to pair.
	 * @param gUser
	 *            the Google {@link User} to add to this {@link TDUser}.
	 * @param facebookId
	 *            the Facebook ID to add to this {@link TDUser}.
	 */
	public static void pairGoogleFacebookUser(final TDUser tdUser, final User gUser,
			final String facebookId) {
		if (null == gUser && null == facebookId) {
			Logger.getLogger(TAG).info("Google User or Facebook Id is null");
		} else {
			if (null != tdUser.getFacebookId() && !tdUser.getFacebookId().isEmpty()) {
				// has facebook, adding google
				tdUser.setUserObj(gUser);
				Datastore.put(tdUser);
				Logger.getLogger(TAG).info(
						"Paired " + tdUser.getKey().getId() + " with Google id "
								+ gUser.getUserId());
			} else {
				// has google, adding facebook
				tdUser.setFacebookId(facebookId);
				Datastore.put(tdUser);
				Logger.getLogger(TAG).info(
						"Paired " + tdUser.getKey().getId() + " with Facebook id " + facebookId);
			}
		}
	}
}