package com.topdish.util;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.code.geocoder.GeocodeResponse;
import com.google.code.geocoder.Geocoder;
import com.google.code.geocoder.GeocoderRequest;
import com.google.code.geocoder.GeocoderResult;
import com.google.code.geocoder.LatLng;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Review;
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
	 * Fetches the user currently logged in.  PersistenceManager is required so the returned 
	 * object can be persisted again within the same session.
	 * 
	 * @return the user currently logged in
	 * 
	 * @throws UserNotLoggedInException
	 * @throws UserNotFoundException
	 */
	@SuppressWarnings("unchecked")
	public static TDUser getUser(PersistenceManager pm)
			throws UserNotLoggedInException, UserNotFoundException {
		UserService userService = UserServiceFactory.getUserService();
		User user = userService.getCurrentUser();

		if (user != null) {
			// check if user is logged in
			Query query = pm.newQuery(TDUser.class);
			query.setFilter("userID == idParam");
			query.declareParameters("String idParam");
			List<TDUser> results = (List<TDUser>) query.execute(user
					.getUserId());
			if (results.size() > 0) {
				// user found in datastore
				TDUser tdUser= results.get(0);
				int role=tdUser.getRole();
				// for existing users where role does not exists
				if(role<=0)
				{
					TDUser roledUser=pm.getObjectById(TDUser.class,tdUser.getKey().getId());
					if(userService.isUserLoggedIn() && userService.isUserAdmin())
					{
						roledUser.setRole(TDUserRole.ROLE_ADMIN);
					}
					else
						roledUser.setRole(TDUserRole.ROLE_STANDARD);
					
					pm.makePersistent(roledUser);
					return roledUser;
					
				}
				return tdUser;
			} else {
				// user not found in datastore
				throw new UserNotFoundException();
			}
		} else {
			// user not logged in
			throw new UserNotLoggedInException();
		}
	}

	/**
	 * Adds a user to the datastore
	 * 
	 * @param user
	 *            the {@link User} object
	 * @param email
	 *            the user's chosen email address
	 * @param nickname
	 *            the user's chosen nickname
	 */
	public static void addUser(User user, String email, String nickname) {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		// add user to datastore
		UserService userService = UserServiceFactory.getUserService();
		TDUser tdUser=null;
		// if user is admin create user with role as admin else default user(role as standard)
		if(userService.isUserAdmin())
		{
			 tdUser = new TDUser( user, user.getNickname(), user.getEmail(), null,TDUserRole.ROLE_ADMIN);
		}
		else
			tdUser = new TDUser(user);
		pm.makePersistent(tdUser);
	}

	/**
	 * Returns <code>true</code> if the current user is logged in
	 * 
	 * @return <code>true</code> if the current user is logged in
	 */
	@SuppressWarnings("unchecked")
	public static boolean getUserLoggedIn() {
		UserService userService = UserServiceFactory.getUserService();
		User user = userService.getCurrentUser();
		PersistenceManager pm = PMF.get().getPersistenceManager();

		if (user != null) {
			Query query = pm.newQuery(TDUser.class);
			query.setFilter("userID == idParam");
			query.declareParameters("String idParam");
			List<TDUser> results = (List<TDUser>) query.execute(user
					.getUserId());

			if (results.size() > 0) {
				// user found in datastore
				return true;
			}
		} else {
			// user not found, therefore not logged in
			return false;
		}

		return false;
	}

	/**
	 * Returns the user's latest vote on a dish. Refer to <@link Review> for
	 * return value
	 * 
	 * @param userKey
	 *            key of the user
	 * @param dishKey
	 *            key of the dish
	 * @return Review.POSITIVE_DIRECTION, Review.NEGATIVE_DIRECTION, or 0 for no
	 *         vote
	 */
	@SuppressWarnings("unchecked")
	public static int getUserVote(Key userKey, Key dishKey) {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Query q = pm.newQuery(Review.class);
		q.setFilter("dish == :dishKeyParam && creator == :userKeyParam");
		q.setOrdering("dateCreated desc"); // sort newest to oldest
		q.setRange("0,1"); // only the newest one review
		List<Review> reviews = (List<Review>) q.execute(dishKey, userKey);

		if (reviews.size() > 0) {
			// found a review
			return reviews.get(0).getDirection();
		} else {
			return 0;
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

		// Check for cookies
		final Cookie cookies[] = request.getCookies();

		// Set to default location SF Civic Center
		TDPoint toBeReturned = new TDPoint(37.78245, -122.420687,
				"San Francisco, CA");

		// Check for cookies
		if (null != cookies) {
			// If any exception is thrown, default location will be provided
			try {

				Double lat = null;
				Double lon = null;
				String city = "";
				String state = "";

				// Traverse all cookies
				for (final Cookie curCookie : cookies) {

					if (curCookie.getName().equals("lat")) {
						// Store the Lat cookie
						lat = Double.valueOf(curCookie.getValue());
					} else if (curCookie.getName().equals("lng")) {
						// Store the Lon cookie
						lon = Double.valueOf(curCookie.getValue());
					} else if (curCookie.getName().equals("city")) {
						// Store the City cookie
						city = curCookie.getValue();
					} else if (curCookie.getName().equals("state")) {
						// Store the City cookie
						state = curCookie.getValue();
					}

					// If both are identified
					if (null != lat && null != lon && !city.isEmpty()
							&& !state.isEmpty()) {
						// Set the new Point
						toBeReturned = new TDPoint(lat, lon, city + ", "
								+ state);

						// Stop Looking
						break;
					}
				}

			} catch (Exception e) {
				e.printStackTrace();
			}

		}

		// Return point to user
		return toBeReturned;
	}

	/**
	 * Set the user's location and recieve it back as a Point
	 * 
	 * @param address
	 *            - the address the user entered
	 * @param request
	 *            - the current HTTP Request
	 * @return the point of the new location if lookup is successful. Otherwise
	 *         last known good location of user is returned
	 */
	public static TDPoint setUserLocation(String address,
			HttpServletRequest request) {

		// Instaitate the GeoCoder
		final Geocoder geocoder = new Geocoder();

		// Do a look up for the given address
		final GeocodeResponse result = geocoder.geocode(new GeocoderRequest(
				address));

		// Point to be returned
		final TDPoint toBeReturned;

		// Check Emtpy Results
		if (null != result && !result.getResults().isEmpty()) {

			// Get the current result
			final GeocoderResult curResult = result.getResults().get(0);
			// Pull out lat and long
			final LatLng geo = curResult.getGeometry().getLocation();

			// Set the new Point
			toBeReturned = new TDPoint(geo.getLat().doubleValue(), geo.getLng()
					.doubleValue(), curResult.getFormattedAddress());

		} else {
			// Return default location if lookup failed
			toBeReturned = getUserLocation(request);
		}

		return toBeReturned;
	}
}