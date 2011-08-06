package com.topdish.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.GeocellQuery;
import com.beoui.geocell.model.LocationCapable;
import com.beoui.geocell.model.Point;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.topdish.comparator.DishPosReviewsComparator;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDPersistable;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.TDUserRole;
import com.topdish.jdo.Tag;

public class TDQueryUtils {
	static boolean DEBUG = false;
	static boolean DEBUG_VERBOSE = false;
	
	/**
	 * Performs bulk get from datastore for given set of Keys for the same
	 * Entity type. <br /><b><i>Now with more memcache!</i></b>
	 * 
	 * @param <T>
	 *            any object that extends TDPersistable
	 * @param keys
	 *            List of Key objects
	 * @param t
	 *            instance of T
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public static <T extends TDPersistable> List<T> getAll(
			Collection<Key> keys, T t) {
		if (!keys.isEmpty()) {
			
			Collection<Key> notCached = new ArrayList<Key>();
			List<T> toReturn = new ArrayList<T>();
			
			for(Key k : keys){
				if(!MemcacheServiceFactory.getMemcacheService().contains(k)){
					notCached.add(k);
					
					if(DEBUG_VERBOSE){
						System.out.println("cache miss: " + k.getKind() + "(" + k.getId() + ")");
					}
				}else{
					toReturn.add((T)MemcacheServiceFactory.getMemcacheService().get(k));
					
					if(DEBUG_VERBOSE){
						System.out.println("cache hit: " + k.getKind() + "(" + k.getId() + ")");
					}
				}
			}
			
			Query q = PMF
					.get()
					.getPersistenceManager()
					.newQuery(
							"select from " + t.getClass().getName()
									+ " where :keys.contains(key)");
			
			if(!notCached.isEmpty())
				toReturn.addAll((List<T>)q.execute(notCached));
			
			HashMap<Key,T> toCache = new HashMap<Key,T>();
			
			for(T c : toReturn){
				toCache.put(c.getKey(), c);
			}
			
			MemcacheServiceFactory.getMemcacheService().putAll(toCache);
			
			if(DEBUG){
				final long hits = MemcacheServiceFactory.getMemcacheService().getStatistics().getHitCount();
				final long misses = MemcacheServiceFactory.getMemcacheService().getStatistics().getMissCount();
				
				System.out.println("memcahce hits: " + hits + " misses: " + misses);
			}
			return toReturn;
		} else {
			return new ArrayList<T>();
		}
	}

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
	public static <T extends TDPersistable> List<T> searchGeoItems(
			String[] terms, Point location, int maxResults, int maxDistance, T t) {
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

			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		} else {
			baseQuery = new GeocellQuery("", "", new ArrayList<Object>());
		}

		try {
			return (List<T>) GeocellManager.proximityFetch(location,
					maxResults, maxDistance, t, baseQuery, PMF.get()
							.getPersistenceManager());
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
	 * 			PersistentManager to be used to create new queries
	 * @param tagKeys 
	 * 			a list of {@link Key} objects representing the tags to filter by
	 * @return list of <T> matching the search terms
	 */
	@SuppressWarnings("unchecked")
	public static <T extends LocationCapable, K extends TDPersistable> List<T> searchGeoItemsWithFilter(
			String[] terms, Point location, int maxResults, double maxDistance, K k, PersistenceManager pm,int offset,List<Key> tagKeys, Comparator<T> comparator) {
		final List<Object> paramList;
		String queryS = "";
		String paramS = "";
		final GeocellQuery baseQuery;
		
		maxResults += offset;
		
		paramList = new ArrayList<Object>();
		boolean paramsAdded=false;
		if(tagKeys.size()>0)
		{
			for(int i = 0; i < tagKeys.size(); i++){
				if(i > 0){
					queryS += " && tags.contains(k" + i + ")";
				}else{
					queryS += "tags.contains(k" + i + ")";
				}
				
				paramList.add(tagKeys.get(i));
				
				if(paramS.length() > 0){
					paramS += ", " + Key.class.getName() + " k" + i;
				}else{
					paramS += Key.class.getName() + " k" + i;
				}
				
				
			}
			paramsAdded=true;
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
			
			paramsAdded=true;

			
		} 

		if(paramsAdded)
		{
			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		}
		else {
			baseQuery = new GeocellQuery("", "", paramList);
		}
		List<T> result = new ArrayList<T>();
		try{
			result = (List<T>) GeocellManager.proximityFetch(location,
					maxResults, maxDistance, k, baseQuery, pm);
		}catch(Exception e){
			e.printStackTrace();
		}
		
		if(comparator != null){
			Collections.sort(result, comparator);
		}
		
		if(offset >= result.size()){
			return new ArrayList<T>();
		}else if(offset > 0 && result.size() > 0){
			//skip the first _offset_ results
			return result.subList(offset, result.size());
		}else{
			return result;
		}

	}

	/**
	 * Search through all tags given an Array of string terms
	 * 
	 * @param queryWords
	 *            Array of string terms to search with
	 * @param maxResults
	 *            maximum number of results
	 * @return list of Tags matching the search terms
	 */
	@SuppressWarnings("unchecked")
	public static List<Tag> searchTags(String[] queryWords, int maxResults) {
		// TODO: can this be replaced by a generic searchItems somehow?
		// Using a TDSearchable Interface would work

		final Query query = PMF.get().getPersistenceManager()
				.newQuery(Tag.class);
		query.setFilter("searchTerms.contains(:searchParam)");
		query.setRange(0, maxResults);

		if (queryWords.length > 0) {
			try {
				return (List<Tag>) query.execute(Arrays.asList(queryWords));
			} catch (Exception e) {
				e.printStackTrace();
				// TODO: handle exception properly
			}
		}

		return null;
	}

	/**
	 * Gets keys of all the dishes at a restaurant
	 * 
	 * @param restKey
	 *            {@link Key} of the {@link Restaurant}
	 * @return {@link Collection} of {@link Key} objects
	 */
	@SuppressWarnings("unchecked")
	public static Collection<Key> getDishKeysByRestaurant(Key restKey) {
		String query = "select key from " + Dish.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("restaurant == :param");

		return (Collection<Key>) q.execute(restKey);
	}

	/**
	 * Gets all of the dish objects at a restaurant
	 * 
	 * @param restKey
	 *            {@link Key} of the {@link Restaurant}
	 * @return {@link Collection} of {@link Dish} objects
	 */
	public static Collection<Dish> getDishesByRestaurant(Key restKey) {		
		Collection<Key> dishKeys = TDQueryUtils.getDishKeysByRestaurant(restKey);
		
		Collection<Key> toGet = new ArrayList<Key>();
		Collection<Dish> toReturn = new ArrayList<Dish>();
		
		for(Key key : dishKeys){
			if(!MemcacheServiceFactory.getMemcacheService().contains(key)){
				//put in cache
				toGet.add(key);
				
				if(DEBUG_VERBOSE)
					System.out.println("cache miss: " + key.getKind() + "(" + key.getId() + ")");
			}else{
				//get from cache
				toReturn.add((Dish) MemcacheServiceFactory.getMemcacheService().get(key));
				
				if(DEBUG_VERBOSE)
					System.out.println("cache hit: " + key.getKind() + "(" + key.getId() + ")");
			}
		}
		
		toReturn.addAll(TDQueryUtils.getAll(toGet, new Dish()));
		
		HashMap<Key,Dish> toCache = new HashMap<Key,Dish>();
		
		for(Dish d : toReturn){
			toCache.put(d.getKey(), d);
		}
		
		MemcacheServiceFactory.getMemcacheService().putAll(toCache);

		return toReturn;
	}

	/**
	 * Gets keys of all the review keys for a dish
	 * @param dishKey {@link Key} of the {@link Dish}
	 * @return {@link List} of {@link Key} objects sorted from newest to oldest
	 */
	@SuppressWarnings("unchecked")
	public static List<Key> getReviewKeysByDish(Key dishKey) {
		String query = "select key from " + Review.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("dish == :param");
		q.setOrdering("dateCreated desc");

		return (List<Key>) q.execute(dishKey);
	}

	/**
	 * Gets all of the review objects for a dish
	 * @param dishKey {@link Key} of the {@link Dish}
	 * @return {@link List} of {@link Dish} objects sorted from newest to oldest
	 */
	@SuppressWarnings("unchecked")
	public static List<Review> getReviewsByDish(Key dishKey) {
		Query q = PMF.get().getPersistenceManager().newQuery(Review.class);
		q.setFilter("dish == :param");
		q.setOrdering("dateCreated desc");

		return (List<Review>) q.execute(dishKey);
	}
	
	/**
	 * Gets all of the keys of reviews authored by a user
	 * @param userKey {@link Key} of the {@link TDUser}
	 * @return {@link List} of {@link Key} objects sorted from newest to oldest
	 */
	@SuppressWarnings("unchecked")
	public static List<Key> getReviewKeysByUser(Key userKey) {
		String query = "select key from " + Review.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("creator == :param");
		q.setOrdering("dateCreated desc");

		return (List<Key>) q.execute(userKey);
	}
	
	/**
	 * Gets all of the reviews authored by a user
	 * @param userKey {@link Key} of the {@link TDUser}
	 * @return {@link List} of {@link Review} objects sorted from newest to oldest
	 */
	@SuppressWarnings("unchecked")
	public static List<Review> getReviewsByUser(Key userKey){
		Query q = PMF.get().getPersistenceManager().newQuery(Review.class);
		q.setFilter("creator == :param");
		q.setOrdering("dateCreated desc");
		
		return (List<Review>) q.execute(userKey);
	}
	
	/**
	 * Get the first review written about a dish
	 * @param dishKey {@link Key} of the {@link Dish}
	 * @return {@link Key} of the {@link Review}
	 */
	@SuppressWarnings("unchecked")
	public static Key getFirstReviewByDish(Key dishKey) {
		String query = "select key from " + Review.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("dish == :param");
		q.setOrdering("dateCreated asc");
		q.setRange("0,1");
		
		List<Key> results = (List<Key>)q.execute(dishKey);
		
		if(!results.isEmpty()){
			return results.get(0);
		}else{
			return null;
		}
	}

	/**
	 * Get the latest review written about a dish
	 * @param dishKey {@link Key} of the {@link Dish}
	 * @return {@link Key} of the {@link Review}
	 */
	@SuppressWarnings("unchecked")
	public static Key getLatestReviewByDish(Key dishKey) {
		String query = "select key from " + Review.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter("dish == :param");
		q.setOrdering("dateCreated desc");
		q.setRange("0,1");
		
		List<Key> results = (List<Key>)q.execute(dishKey);
		
		if(!results.isEmpty()){
			return results.get(0);
		}else{
			return null;
		}
	}
	
	/**
	 * Returns whether user is allowed to edit the entity if he created the entity
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
	public static <T extends TDPersistable> boolean isAccessible(Long id, T t,PersistenceManager pm,TDUser tdUser) {
		boolean isAccessAllowed=true;
		if(id!=null && null!=tdUser && tdUser.getRole() == TDUserRole.ROLE_STANDARD){
				try{
					T returnValT = (T) pm.getObjectById(t.getClass(), id);
					if(returnValT!=null){
						if(returnValT.getCreator().getId() != Long.valueOf(tdUser.getKey().getId())){
							isAccessAllowed = false;
						}
					}
				}
				catch(JDOObjectNotFoundException jdoe){
					isAccessAllowed = false;
				}
				catch(Exception e){
					isAccessAllowed = false;
				}
			}
		return isAccessAllowed;
	}
	
	/**
	 * Returns the top X dishes ranked from most to least positive reviews
	 * @param numDishes
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public static List<Dish> getTopDishes(int numDishes){
		final String query = "SELECT key FROM " + Dish.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setOrdering("posReviews desc");
		q.setRange("0," + numDishes);
		
		final List<Dish> toReturn = TDQueryUtils.getAll((Collection<Key>)q.execute(), new Dish());
		Collections.sort(toReturn, new DishPosReviewsComparator());
		
		return toReturn;
	}
	
	/**
	 * Returns the last X added dishes
	 * @param numDishes
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public static List<Dish> getNewestDishes(int numDishes){
		final String query = "SELECT key FROM " + Dish.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setOrdering("dateCreated desc");
		q.setRange("0," + numDishes);
		
		return TDQueryUtils.getAll((List<Key>) q.execute(), new Dish());
	}
 }
