package com.topdish.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Logger;

import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.Query;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.GeocellQuery;
import com.beoui.geocell.model.Point;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.google.appengine.api.users.User;
import com.topdish.api.DishSearchServlet;
import com.topdish.api.util.UserConstants;
import com.topdish.comparator.DishPosReviewsComparator;
import com.topdish.comparator.RestaurantPosReviewsComparator;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.Source;
import com.topdish.jdo.TDPersistable;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.TDUserRole;
import com.topdish.jdo.Tag;

public class TDQueryUtils {

	private static final String TAG = DishSearchServlet.class.getSimpleName();

	/**
	 * Performs a query over all objects of type <T>
	 * 
	 * @param <T>
	 *            any object that extends LocationCapable
	 * @param terms
	 *            Array of string search terms
	 * @param location
	 *            a Point to use as the center of the query
	 * @param maxResults
	 *            maximum number of results returned
	 * @param maxDistance
	 *            maximum distance to search in meters
	 * @param t
	 *            instance of T
	 * @return list of <T> matching the search terms
	 */
	@SuppressWarnings("unchecked")
	public static <T extends TDPersistable> Set<T> searchGeoItems(String[] terms, Point location,
			int maxResults, int maxDistance, T t) {
		final List<Object> paramList;
		String queryS = "";
		String paramS = "";
		final GeocellQuery baseQuery;

		if (null != terms) {
			paramList = new ArrayList<Object>();

			for (int i = 0; i < terms.length; i++) {
				if (i > 0) {
					queryS += " && searchTerms.contains(s" + i + ")";
				} else {
					queryS += "searchTerms.contains(s" + i + ")";
				}

				paramList.add(terms[i].toLowerCase());

				if (paramS.length() > 0) {
					paramS += ", String s" + i;
				} else {
					paramS += "String s" + i;
				}
			}
			Logger.getLogger(TAG).info("Creating query with params: " + paramList);
			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		} else {
			Logger.getLogger(TAG).info("Creating query without params.");
			baseQuery = new GeocellQuery("", "", new ArrayList<Object>());
		}

		try {
			Logger.getLogger(TAG).info("Sending query to GeocellManager.");
			return new HashSet<T>((Collection<? extends T>) GeocellManager.proximityFetch(location,
					maxResults, maxDistance, t, baseQuery, PMF.get().getPersistenceManager()));
		} catch (Exception e) {
			Logger.getLogger(TAG).info("GeocellManager failed: " + e.getMessage());
			e.printStackTrace();
		}

		return null;
	}

	/**
	 * Searches for all geo-aware items near a {@link Point}.
	 * 
	 * @param <T>
	 *            type of item to search for.
	 * @param location
	 *            {@link Point} as the center of the search
	 * @param maxResults
	 *            maximum number of results
	 * @param maxDistance
	 *            maximum distance to search in meters
	 * @param t
	 *            instance of the type T
	 * @return {@link List} of items of type T
	 */
	@SuppressWarnings("unchecked")
	public static <T extends TDPersistable> List<T> searchGeoItems(Point location, int maxResults,
			int maxDistance, T t) {
		final GeocellQuery baseQuery = new GeocellQuery("", "", new ArrayList<Object>());

		try {
			return (List<T>) GeocellManager.proximityFetch(location, maxResults, maxDistance, t,
					baseQuery, PMF.get().getPersistenceManager());
		} catch (Exception e) {
			e.printStackTrace();
			// TODO: handle exception properly
		}

		return null;
	}

	/**
	 * Performs a query over all objects of type <T> along with filters
	 * 
	 * @param <T>
	 *            any object that extends LocationCapable
	 * @param terms
	 *            Array of string search terms
	 * @param location
	 *            a Point to use as the center of the query
	 * @param maxResults
	 *            maximum number of results returned
	 * @param maxDistance
	 *            maximum distance to search in meters
	 * @param t
	 *            instance of T
	 * @param pm
	 *            PersistentManager to be used to create new queries
	 * @param tagKeys
	 *            a list of {@link Key} objects representing the tags to filter
	 *            by
	 * @return list of <T> matching the search terms
	 */
	@SuppressWarnings("unchecked")
	public static <T extends TDPersistable> List<T> searchGeoItemsWithFilter(String[] terms,
			Point location, int maxResults, double maxDistance, T t, int offset, List<Key> tagKeys,
			Comparator<T> comparator) {
		final List<Object> paramList;
		String queryS = "";
		String paramS = "";
		final GeocellQuery baseQuery;

		maxResults += offset;

		paramList = new ArrayList<Object>();
		boolean paramsAdded = false;
		if (tagKeys.size() > 0) {
			for (int i = 0; i < tagKeys.size(); i++) {
				if (i > 0) {
					queryS += " && tags.contains(k" + i + ")";
				} else {
					queryS += "tags.contains(k" + i + ")";
				}

				paramList.add(tagKeys.get(i));

				if (paramS.length() > 0) {
					paramS += ", " + Key.class.getName() + " k" + i;
				} else {
					paramS += Key.class.getName() + " k" + i;
				}

			}
			paramsAdded = true;
		}

		if (null != terms) {

			for (int i = 0; i < terms.length; i++) {
				if (i > 0 || paramsAdded) {
					queryS += " && searchTerms.contains(s" + i + ")";
				} else {
					queryS += "searchTerms.contains(s" + i + ")";
				}

				paramList.add(terms[i].toLowerCase());

				if (paramS.length() > 0 || paramsAdded) {
					paramS += ", String s" + i;
				} else {
					paramS += "String s" + i;
				}
			}

			paramsAdded = true;

		}

		if (paramsAdded) {
			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		} else {
			baseQuery = new GeocellQuery("", "", paramList);
		}
		List<T> result = new ArrayList<T>();
		try {
			result = (List<T>) GeocellManager.proximityFetch(location, maxResults, maxDistance, t,
					baseQuery, PMF.get().getPersistenceManager());
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (comparator != null) {
			Collections.sort(result, comparator);
		}

		if (offset >= result.size()) {
			return new ArrayList<T>();
		} else if (offset > 0 && result.size() > 0) {
			// skip the first _offset_ results
			return result.subList(offset, result.size());
		} else {
			return result;
		}

	}

	/**
	 * Search through all {@link Tag}s given an array of {@link String} search
	 * terms
	 * 
	 * @param queryWords
	 *            array of {@link String} terms to search with
	 * @param maxResults
	 *            maximum number of results
	 * @return list of Tags matching the search terms
	 */
	@SuppressWarnings("unchecked")
	public static Set<Tag> searchTags(String[] queryWords, int maxResults) {
		// TODO: can this be replaced by a generic searchItems somehow?
		// Using a TDSearchable Interface would work

		final String queryString = "SELECT key FROM " + Tag.class.getName();
		final Query query = PMF.get().getPersistenceManager().newQuery(queryString);
		query.setFilter("searchTerms.contains(:searchParam)");
		query.setRange(0, maxResults);

		if (queryWords.length > 0) {
			return Datastore.get((Collection<Key>) query.execute(Arrays.asList(queryWords)));
		}

		return new HashSet<Tag>();
	}

	/**
	 * Gets {@link Key}s of all the {@link Dish}es at a {@link Restaurant}
	 * 
	 * @param restKey
	 *            {@link Key} of the {@link Restaurant}
	 * @return {@link Collection} of {@link Key} objects
	 */
	@SuppressWarnings("unchecked")
	public static Collection<Key> getDishKeysByRestaurant(Key restKey) {
		String query = "SELECT key FROM " + Dish.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("restaurant == :param");

		return (Collection<Key>) q.execute(restKey);
	}

	/**
	 * Gets all of the {@link Dish}es at a {@link Restaurant}
	 * 
	 * @param restKey
	 *            {@link Key} of the {@link Restaurant}
	 * @return {@link Collection} of {@link Dish} objects
	 */
	public static Set<Dish> getDishesByRestaurant(Key restKey) {
		return Datastore.get(getDishKeysByRestaurant(restKey));
	}

	/**
	 * Gets {@link Key}s of all the {@link Review}s for a {@link Dish}
	 * 
	 * @param dishKey
	 *            {@link Key} of the {@link Dish}
	 * @return {@link Collection} of {@link Key} objects sorted from newest to
	 *         oldest
	 */
	@SuppressWarnings("unchecked")
	public static Collection<Key> getReviewKeysByDish(Key dishKey) {
		String query = "select key from " + Review.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("dish == :param");
		q.setOrdering("dateCreated desc");

		return (Collection<Key>) q.execute(dishKey);
	}

	/**
	 * Gets all of the review objects for a dish
	 * 
	 * @param dishKey
	 *            {@link Key} of the {@link Dish}
	 * @return {@link List} of {@link Dish} objects sorted from newest to oldest
	 */
	public static Set<Review> getReviewsByDish(Key dishKey) {
		return Datastore.get(getReviewKeysByDish(dishKey));
	}

	/**
	 * Get the {@link Key}s of all of the {@link Review}s created by a
	 * {@link TDUser}
	 * 
	 * @param userKey
	 *            {@link Key} of the {@link TDUser}
	 * @return {@link List} of {@link Key} objects sorted from newest to oldest
	 */
	@SuppressWarnings("unchecked")
	public static Set<Key> getReviewKeysByUser(Key userKey) {
		String query = "SELECT key FROM " + Review.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("creator == :param");
		// q.setOrdering("dateCreated desc");

		return (Set<Key>) q.execute(userKey);
	}

	/**
	 * Gets all of the {@link Review}s created by a {@link TDUser}
	 * 
	 * @param userKey
	 *            {@link Key} of the {@link TDUser}
	 * @return {@link List} of {@link Review} objects sorted from newest to
	 *         oldest
	 */
	public static Set<Review> getReviewsByUser(Key userKey) {
		return Datastore.get(getReviewKeysByUser(userKey));
	}

	/**
	 * Get the {@link Key} of the first {@link Review} written about a
	 * {@link Dish}.
	 * 
	 * @param dishKey
	 *            {@link Key} of the {@link Dish}
	 * @return {@link Key} of the {@link Review}
	 */
	@SuppressWarnings("unchecked")
	public static Key getFirstReviewKeyByDish(Key dishKey) {
		String query = "SELECT key FROM " + Review.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("dish == :param");
		q.setOrdering("dateCreated asc");
		q.setRange("0,1");

		List<Key> results = (List<Key>) q.execute(dishKey);

		if (!results.isEmpty()) {
			return results.get(0);
		} else {
			return null;
		}
	}

	/**
	 * Get the first review written about a dish.
	 * 
	 * @param dishKey
	 *            {@link Key} of the {@link Dish}
	 * @return the {@link Review}
	 */
	public static Review getFirstReviewByDish(Key dishKey) {
		final Key reviewKey = getFirstReviewKeyByDish(dishKey);
		if (null != reviewKey) {
			return (Review) Datastore.get(reviewKey);
		} else {
			return null;
		}
	}

	/**
	 * Get the {@link Key} of the latest {@link Review} written about a
	 * {@link Dish}
	 * 
	 * @param dishKey
	 *            {@link Key} of the {@link Dish}
	 * @return {@link Key} of the {@link Review}
	 */
	@SuppressWarnings("unchecked")
	public static Key getLatestReviewKeyByDish(Key dishKey) {
		String query = "SELECT key FROM " + Review.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("dish == :param");
		q.setOrdering("dateCreated desc");
		q.setRange("0,1");

		List<Key> results = (List<Key>) q.execute(dishKey);

		if (!results.isEmpty()) {
			return results.get(0);
		} else {
			return null;
		}
	}

	/**
	 * Get the latest {@link Review} written for a {@link Dish}.
	 * 
	 * @param dishKey
	 *            {@link Key} of the {@link Dish}
	 * @return the {@link Review}
	 */
	public static Review getLatestReviewByDish(Key dishKey) {
		final Key reviewKey = getLatestReviewKeyByDish(dishKey);
		if (null != reviewKey) {
			return Datastore.get(getLatestReviewKeyByDish(dishKey));
		} else {
			return null;
		}
	}

	/**
	 * Gets the {@link Key} of the latest {@link Review} submitted by a
	 * {@link TDUser} .
	 * 
	 * @param userKey
	 *            {@link Key} of the {@link TDUser}
	 * @return {@link Key} of the {@link Review}
	 */
	@SuppressWarnings("unchecked")
	public static Key getLatestReviewKeyByUser(Key userKey) {
		String query = "select key from " + Review.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("creator == :param");
		q.setOrdering("dateCreated desc");
		q.setRange("0,1");

		List<Key> results = (List<Key>) q.execute(userKey);

		if (!results.isEmpty()) {
			return results.get(0);
		} else {
			return null;
		}
	}

	/**
	 * Gets the latest {@link Review} submitted by a {@link TDUser}
	 * 
	 * @param userKey
	 *            {@link Key} of the {@link TDUser}
	 * @return the {@link Review}
	 */
	public static Review getLatestReviewByUser(Key userKey) {
		final Key reviewKey = getLatestReviewKeyByUser(userKey);
		if (null != reviewKey) {
			return Datastore.get(reviewKey);
		} else {
			return null;
		}
	}

	/**
	 * Returns whether user is allowed to edit the entity if he created the
	 * entity
	 * 
	 * @param <T>
	 *            any object that extends TDPersistable
	 * @param tdUser
	 *            logged in user
	 * @param t
	 *            instance of T
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public static <T extends TDPersistable> boolean isAccessible(Long id, T t) {
		boolean isAccessAllowed = true;
		try {
			TDUser tdUser = TDUserService.getUser();
			if (id != null && null != tdUser && tdUser.getRole() == TDUserRole.ROLE_STANDARD) {
				try {
					T returnValT = (T) Datastore.get(KeyFactory.createKey(t.getClass()
							.getSimpleName(), id));
					if (returnValT != null) {
						if (returnValT.getCreator().getId() != Long
								.valueOf(tdUser.getKey().getId())) {
							isAccessAllowed = false;
						}
					}
				} catch (JDOObjectNotFoundException jdoe) {
					isAccessAllowed = false;
				} catch (Exception e) {
					isAccessAllowed = false;
				}
			}
			return isAccessAllowed;

		} catch (UserNotLoggedInException e) {
			return false;
		} catch (UserNotFoundException e) {
			return false;
		}
	}

	/**
	 * Searches for {@link Dish}es belonging to a {@link Restauarnt} using the
	 * supplied search terms
	 * 
	 * @param queryWords
	 *            terms to search with
	 * @param restKey
	 *            {@link Key} to the {@link Restaurant} to search within
	 * @param maxResults
	 *            maximum number of results to return
	 * @return {@link Collection} of {@link Dish}es
	 */
	@SuppressWarnings("unchecked")
	public static Set<Dish> searchDishesByRestaurant(String[] queryWords, Key restKey,
			int maxResults) {
		List<Object> paramList = null;
		String paramS = "";
		String queryS = "";
		final String queryString = "SELECT key FROM " + Dish.class.getName();
		final Query q = PMF.get().getPersistenceManager().newQuery(queryString);

		if (queryWords.length > 0) {
			paramList = new ArrayList<Object>();
			queryS += "restaurant == restParam";
			paramS = Key.class.getName() + " restParam";
			paramList.add(restKey);

			for (int i = 0; i < queryWords.length; i++) {
				queryS += " && searchTerms.contains(s" + i + ")";
				paramS += ", String s" + i;
				paramList.add(queryWords[i]);
			}

			q.setFilter(queryS);
			q.declareParameters(paramS);

			return Datastore.get(new HashSet<Key>((List<Key>) q.executeWithArray(paramList
					.toArray())));
		}

		return new HashSet<Dish>();
	}

	/**
	 * Gets the top <code>numDishes</code> {@link Dish}es ranked from most to
	 * least positive reviews
	 * 
	 * @param numDishes
	 *            number of {@link Dish}es to return
	 * @return {@link List} of {@link Dish}es
	 */
	@SuppressWarnings("unchecked")
	public static List<Dish> getTopDishes(int numDishes) {
		final String query = "SELECT key FROM " + Dish.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setOrdering("posReviews desc");
		q.setRange("0," + numDishes);

		final Set<Dish> results = Datastore.get((Collection<Key>) q.execute());
		final List<Dish> toReturn = new ArrayList<Dish>(results);
		Collections.sort(toReturn, new DishPosReviewsComparator());

		return toReturn;
	}

	/**
	 * Returns the most recent <code>numDishes</code> {@link Dish}es added
	 * 
	 * @param numDishes
	 *            number of {@link Dish}es to return
	 * @return {@link List} of {@link Dish}es ordered from newest to oldest
	 */
	@SuppressWarnings("unchecked")
	public static Set<Dish> getNewestDishes(int numDishes) {
		final String query = "SELECT key FROM " + Dish.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setOrdering("dateCreated desc");
		q.setRange("0, " + numDishes);

		return Datastore.get((Collection<Key>) q.execute());
	}

	/**
	 * Gets the top <code>numRestaurantss</code> {@link Restaurant}s ranked from
	 * most to least positive reviews <br />
	 * <b>Note: this does not actually return the top X restaurants, just a
	 * random X restaurants!</b>
	 * 
	 * @param numRestaurants
	 *            number of {@link Restaurant}s to return
	 * @return {@link List} of {@link Restaurant}s
	 */
	@SuppressWarnings("unchecked")
	public static List<Restaurant> getTopRestaurants(int numRestaurants) {
		final String query = "SELECT key FROM " + Restaurant.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		// TODO: return a query that actually chooses the X highest rated
		// restaurants
		// q.setOrdering("posReviews desc");
		q.setRange("0," + numRestaurants);

		final Set<Restaurant> results = Datastore.get((Collection<Key>) q.execute());
		final List<Restaurant> toReturn = new ArrayList<Restaurant>(results);
		Collections.sort(toReturn, new RestaurantPosReviewsComparator());

		return toReturn;
	}

	/**
	 * Gets the top <code>numUsers</code> sorted by most to least ratings.
	 * 
	 * @param numUsers
	 *            number of {@link TDUser}s to return
	 * @return {@link List} of {@link TDUser}s
	 */
	@SuppressWarnings("unchecked")
	public static List<TDUser> getTopUsers(int numUsers) {
		final String query = "SELECT key FROM " + TDUser.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setOrdering("numReviews desc");
		q.setRange("0, " + numUsers);

		final Set<TDUser> results = Datastore.get((Collection<Key>) q.execute());
		final List<TDUser> toReturn = new ArrayList<TDUser>(results);
		// Collections.sort(toReturn, )

		return toReturn;
	}

	/**
	 * Filters dishes based on a center latitude/longitude pair, distance,
	 * number of results, and a list of {@link Tag}s.
	 * 
	 * @param maxResults
	 *            number of results to return
	 * @param tagKeys
	 *            {@link List} of {@link Tag} {@link Key}s to filter by
	 * @param maxDistance
	 *            maximum distance in meters
	 * @param lat
	 *            latitude of center of search
	 * @param lng
	 *            longitude of center of search
	 * @return {@link List} of {@link Dish}es
	 */
	public static Set<Dish> filterDishes(int maxResults, Set<Key> tagKeys, double maxDistance,
			double lat, double lng) {
		return filterDishes(maxResults, tagKeys, maxDistance, lat, lng, 0, null);
	}

	/**
	 * Filters dishes based on a center latitude/longitude pair, distance,
	 * number of results, and a list of {@link Tag}s.
	 * 
	 * @param maxResults
	 *            number of results to return
	 * @param tagKeys
	 *            {@link List} of {@link Tag} {@link Key}s to filter by
	 * @param maxDistance
	 *            maximum distance in meters
	 * @param lat
	 *            latitude of center of search
	 * @param lng
	 *            longitude of center of search
	 * @param offset
	 *            number of results to ignore for paging through results
	 * @return {@link List} of {@link Dish}es
	 */
	public static Set<Dish> filterDishes(int maxResults, Set<Key> tagKeys, double maxDistance,
			double lat, double lng, int offset) {
		return filterDishes(maxResults, tagKeys, maxDistance, lat, lng, offset, null);
	}

	/**
	 * Filters dishes based on a center latitude/longitude pair, distance,
	 * number of results, and a list of {@link Tag}s. <br>
	 * FIXME: {@link HashSet}s do not hold order. As such, the supplied
	 * {@link Comparator} cannot be relied upon. This needs to be fixed.
	 * 
	 * @param maxResults
	 *            number of results to return
	 * @param tagKeys
	 *            {@link List} of {@link Tag} {@link Key}s to filter by
	 * @param maxDistance
	 *            maximum distance in meters
	 * @param lat
	 *            latitude of center of search
	 * @param lng
	 *            longitude of center of search
	 * @param offset
	 *            number of results to ignore for paging through results
	 * @param comparator
	 *            comparator to use to override the natural sorting of results
	 * @return {@link List} of {@link Dish}es
	 * @deprecated You can't sort a {@link Set}!
	 */
	@Deprecated
	public static Set<Dish> filterDishes(int maxResults, Set<Key> tagKeys, double maxDistance,
			double lat, double lng, int offset, Comparator<Dish> comparator) {
		String queryS = "";
		List<Object> paramList = new ArrayList<Object>();
		String paramS = "";
		List<Dish> result = new ArrayList<Dish>();
		maxResults += offset;

		Key[] tagKeyArray = tagKeys.toArray(new Key[tagKeys.size()]);

		for (int i = 0; i < tagKeyArray.length; i++) {
			if (i > 0) {
				queryS += " && tags.contains(k" + i + ")";
			} else {
				queryS += "tags.contains(k" + i + ")";
			}

			paramList.add(tagKeyArray[i]);

			if (paramS.length() > 0) {
				paramS += ", " + Key.class.getName() + " k" + i;
			} else {
				paramS += Key.class.getName() + " k" + i;
			}
		}

		GeocellQuery baseQuery = null;

		if (paramList.size() > 0) {
			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		} else {
			baseQuery = new GeocellQuery("", "", paramList);
		}

		result = GeocellManager.proximityFetch(new Point(lat, lng), maxResults, maxDistance,
				new Dish(), baseQuery, PMF.get().getPersistenceManager());

		// Check within offset, if not return empty set
		if (offset >= result.size())
			return new HashSet<Dish>();

//		Logger.getLogger(TAG).info("BEFORE SORT: " + result);

		// Run Dish sort
//		if (null != comparator)
//			Collections.sort(result, comparator);

//		Logger.getLogger(TAG).info("AFTER SORT: " + result);

		// Get the section of the list desired
		if (offset > 0 && result.size() > 0) {
			result = result.subList(offset, result.size());
		}

		// Return the dishes
		return new HashSet<Dish>(result);
	}

	/**
	 * Get a {@link TDUser}'s {@link Key} matching their API Key.
	 * 
	 * @param apiKey
	 *            an API Key {@link String}
	 * @return a {@link Key} or <code>null</code>
	 */
	@SuppressWarnings("unchecked")
	public static Key getUserKeyByAPIKey(String apiKey) {
		// check if APIKey -> TDUser Key found in cache
		if (MemcacheServiceFactory.getMemcacheService().contains(apiKey)) {
			// if so, return from cache
			return (Key) MemcacheServiceFactory.getMemcacheService().get(apiKey);
		} else {
			// query for matching user
			final String queryString = "SELECT key FROM " + TDUser.class.getName();
			final Query q = PMF.get().getPersistenceManager().newQuery(queryString);
			q.setFilter("ApiKey == :p");
			q.setRange("0,1");

			final List<Key> keys = (List<Key>) q.execute(apiKey);

			final Key result = (keys.size() > 0 ? keys.get(0) : null);

			if (null != result) {
				// put ApiKey -> TDUser Key map in cache
				MemcacheServiceFactory.getMemcacheService().put(apiKey, result);
			}

			// return the found key
			return result;
		}
	}

	/**
	 * Get a {@link Key} of a {@link TDUser} given the {@link User} ID.
	 * 
	 * @param userId
	 *            the user ID from a {@link User} object.
	 * @return the {@link Key} of this {@link TDUser}.
	 */
	@SuppressWarnings("unchecked")
	public static Key getUserKeyByUserId(String userId) {
		final String queryString = "SELECT key FROM " + TDUser.class.getName();
		final Query query = PMF.get().getPersistenceManager().newQuery(queryString);
		query.setFilter("userID == :param");
		query.setRange("0, 1");

		final Set<Key> results = new HashSet<Key>((List<Key>) query.execute(userId));

		if (null != results && !results.isEmpty()) {
			return results.iterator().next();
		}
		return null;
	}

	/**
	 * Get a User {@link Key} for a facebook id
	 * 
	 * @param facebookId
	 * @return the user {@link Key} or null
	 */
	@SuppressWarnings("unchecked")
	public static Key getUserForFacebookId(String facebookId) {

		// check if APIKey -> TDUser Key found in cache
		if (MemcacheServiceFactory.getMemcacheService().contains(facebookId)) {
			// if so, return from cache
			return (Key) MemcacheServiceFactory.getMemcacheService().get(facebookId);
		} else {
			// query for matching user
			final String queryString = "SELECT key FROM " + TDUser.class.getName();
			final Query q = PMF.get().getPersistenceManager().newQuery(queryString);
			q.setFilter("facebookId == :p");
			q.setRange("0,1");

			final List<Key> keys = (List<Key>) q.execute(facebookId);

			final Key result = (keys.size() > 0 ? keys.get(0) : null);

			if (null != result) {
				// put ApiKey -> TDUser Key map in cache
				MemcacheServiceFactory.getMemcacheService().put(facebookId, result);
			}

			// return the found key
			return result;
		}

	}

	/**
	 * Method to get the "default" user to use as an object's creator.
	 * 
	 * @return {@link Key} of the "default" user
	 */
	@SuppressWarnings("unchecked")
	public static Key getDefaultUser() {
		if (MemcacheServiceFactory.getMemcacheService().contains(UserConstants.DEFAULT_USER_EMAIL)) {
			return (Key) MemcacheServiceFactory.getMemcacheService().get(
					UserConstants.DEFAULT_USER_EMAIL);
		} else {
			final String queryString = "SELECT key FROM " + TDUser.class.getName();
			final Query q = PMF.get().getPersistenceManager().newQuery(queryString);
			q.setFilter("email == :p");
			q.setRange("0,1");

			final List<Key> keys = (List<Key>) q.execute(UserConstants.DEFAULT_USER_EMAIL);

			if (null != keys && !keys.isEmpty()) {

				final Key result = (Key) keys.get(0);
				MemcacheServiceFactory.getMemcacheService().put(UserConstants.DEFAULT_USER_EMAIL,
						result);

				return result;
			}
			return null;
		}
	}

	/**
	 * Search {@link Tag}s by name and type
	 * 
	 * @param stringTag
	 *            name of a tag
	 * @param tagType
	 *            type of the tag
	 * @param limit
	 *            maximum number of results
	 * @return {@link Set} of {@link Tag}s
	 */
	public static Set<Tag> searchTagsByName(String stringTag, int tagType, int limit) {
		return searchTagsByNameType(stringTag, new HashSet<Integer>(tagType), limit);
	}

	/**
	 * Search tags by name and types
	 * 
	 * @param stringTag
	 *            name of a single tag
	 * @param types
	 *            {@link Set} of tag types
	 * @param limit
	 *            maximum number of results
	 * @return {@link Set} of {@link Tag}s
	 */
	@SuppressWarnings("unchecked")
	public static Set<Tag> searchTagsByNameType(String stringTag, Set<Integer> types, int limit) {

		final String queryString = "SELECT key FROM " + Tag.class.getName();
		final Query q = PMF.get().getPersistenceManager().newQuery(queryString);
		q.setFilter("searchTerms.contains(:searchTerm) && :typeParam.contains(type)");
		q.setRange("0, " + limit);

		return Datastore.get(new HashSet<Key>((Collection<Key>) q.execute(stringTag.toLowerCase(),
				types)));
	}

	/**
	 * Find sources by Name
	 * 
	 * @param name
	 *            - name of source
	 * @return the {@link Set} of {@link Source}s
	 */
	public static Set<Source> searchSourceByName(String name) {
		return searchSourcebyName(name, 25);
	}

	/**
	 * Find {@link Source}s by name with a limit
	 * 
	 * @param name
	 *            - the source's name
	 * @param limit
	 *            - limit results
	 * @return a {@link Set} of related {@link Source}s
	 */
	@SuppressWarnings("unchecked")
	public static Set<Source> searchSourcebyName(String name, int limit) {

		final String queryString = "SELECT key FROM " + Source.class.getName();
		final Query q = PMF.get().getPersistenceManager().newQuery(queryString);
		q.setFilter("name == :p");
		q.setRange("0, " + limit);

		return Datastore.get(new HashSet<Key>((List<Key>) q.execute(name.toLowerCase())));

	}

	/**
	 * Gets the direction of the latest {@link Review} by a given {@link TDUser}
	 * for a given {@link Dish}.
	 * 
	 * @param userKey
	 *            {@link Key} of the {@link TDUser}
	 * @param dishKey
	 *            {@link Key} of the {@link Dish}
	 * @return {@link Review#POSITIVE_DIRECTION},
	 *         {@link Review#NEGATIVE_DIRECTION}, or 0 if none found
	 */
	public static int getLatestUserVoteByDish(Key userKey, Key dishKey) {
		final Key revKey = getLatestReviewKeyByUserDish(userKey, dishKey);
		if (null != revKey) {
			final Review review = Datastore.get(revKey);
			if (null != review) {
				return review.getDirection();
			} else {
				return 0;
			}
		} else {
			return 0;
		}
	}

	/**
	 * Gets the latest {@link Review} {@link Key} for a given {@link TDUser}
	 * {@link Key} and {@link Dish} {@link Key}.
	 * 
	 * @param userKey
	 *            {@link Key} of the {@link TDUser}
	 * @param dishKey
	 *            {@link Key} of the {@link Dish}
	 * @return {@link Key} of the {@link Review} or <code>null</code> if none
	 *         found.
	 */
	@SuppressWarnings("unchecked")
	public static Key getLatestReviewKeyByUserDish(Key userKey, Key dishKey) {
		final String queryString = "SELECT key FROM " + Review.class.getName();
		final Query q = PMF.get().getPersistenceManager().newQuery(queryString);
		q.setFilter("dish == :dishKeyParam && creator == :userKeyParam");
		q.setOrdering("dateCreated desc"); // sort newest to oldest
		q.setRange("0,1"); // only the newest one review
		final Set<Key> revKeys = new HashSet<Key>((Collection<Key>) q.execute(dishKey, userKey));

		if (!revKeys.isEmpty()) {
			return revKeys.iterator().next();
		} else {
			return null;
		}
	}

	/**
	 * Get {@link Key}s of {@link TDUser}s with the same name.
	 * 
	 * @param name
	 *            the name to find
	 * @return a {@link Set} of {@link Keys}
	 */
	@SuppressWarnings("unchecked")
	public static Set<Key> getUserKeysByName(final String name) {
		final String queryString = "SELECT key FROM " + TDUser.class.getName();
		final Query q = PMF.get().getPersistenceManager().newQuery(queryString);
		q.setFilter("nickname == :name");
		final Set<Key> userKeys = new HashSet<Key>((Collection<Key>) q.execute(name));

		if (!userKeys.isEmpty()) {
			return userKeys;
		} else {
			return new HashSet<Key>();
		}
	}

	/**
	 * Get {@link Key}s of {@link TDUser}s with the same name.
	 * 
	 * @param email
	 *            the email to find
	 * @return a {@link Set} of {@link Key}s
	 */
	@SuppressWarnings("unchecked")
	public static Set<Key> getUserKeysByEmail(final String email) {
		final String queryString = "SELECT key FROM " + TDUser.class.getName();
		final Query q = PMF.get().getPersistenceManager().newQuery(queryString);
		q.setFilter("email == :email");
		final Set<Key> userKeys = new HashSet<Key>((Collection<Key>) q.execute(email));

		if (!userKeys.isEmpty()) {
			return userKeys;
		} else {
			return new HashSet<Key>();
		}
	}
}
