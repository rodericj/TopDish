package com.topdish.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.GeocellQuery;
import com.beoui.geocell.model.LocationCapable;
import com.beoui.geocell.model.Point;
import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Flag;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDPersistable;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.TDUserRole;
import com.topdish.jdo.Tag;

public class TDQueryUtils {
	/**
	 * Performs bulk get from datastore for given set of Keys for the same
	 * Entity type
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
			Query q = PMF
					.get()
					.getPersistenceManager()
					.newQuery(
							"select from " + t.getClass().getName()
									+ " where :keys.contains(key)");
			return (List<T>) q.execute(keys);
		} else {
			return new ArrayList<T>();
		}
	}
	
	
	/**
	 * Performs bulk get from datastore 
	 * Entity type
	 * 
	 * @param <T>
	 *            any object that extends TDPersistable
	 * @param t
	 *            instance of T
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public static <T extends TDPersistable> List<T> getAll(T t) {
			Query q = PMF
					.get()
					.getPersistenceManager()
					.newQuery(
							"select from " + t.getClass().getName());
			return (List<T>) q.execute();

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
	public static <T extends LocationCapable> List<T> searchGeoItems(
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
					maxResults, maxDistance, t.getClass(), baseQuery, PMF.get()
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
	public static <T extends LocationCapable> List<T> searchGeoItemsWithFilter(
			String[] terms, Point location, int maxResults, double maxDistance, T t,PersistenceManager pm,int offset,List<Key> tagKeys, Comparator<T> comparator) {
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
					maxResults, maxDistance, t.getClass(), baseQuery, pm);
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
	@SuppressWarnings("unchecked")
	public static Collection<Dish> getDishesByRestaurant(Key restKey) {
		Query q = PMF.get().getPersistenceManager().newQuery(Dish.class);
		q.setFilter("restaurant == :param");

		return ((Collection<Dish>) q.execute(restKey));
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
	 * Performs a query over all objects of type <T>
	 * 
	 * @param <T>
	 *            any object that extends LocationCapable
	 * @param terms
	 *            Array of string search terms
	 * @param t
	 *            instance of T
	 * @return list of <T> matching the search terms
	 */
	@SuppressWarnings("unchecked")
	public static <T extends TDPersistable> List<T> searchAllEntities(List<Object> paramList, String queryS,String paramS, T t) {
		//final List<Object> paramList;
		final GeocellQuery baseQuery;

		if (null != paramList && paramList.size()>0) {
			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		} else {
			baseQuery = new GeocellQuery("", " ", new ArrayList<Object>());
		}

		try {
	            Query query = PMF.get()
				.getPersistenceManager().newQuery(t.getClass(), baseQuery.getBaseQuery());

	            if(null!=baseQuery.getDeclaredParameters() && baseQuery.getDeclaredParameters().trim().length() > 0) {
	                query.declareParameters(baseQuery.getDeclaredParameters());
	            }

	            List<T> newResultEntities;
	            if(null!=baseQuery.getParameters() && !baseQuery.getParameters().isEmpty()) {
	                List<Object> parameters = new ArrayList<Object>(baseQuery.getParameters());
	                Object[] paramArray=parameters.toArray();
	                newResultEntities = (List<T>) query.executeWithArray(paramArray);
	               // System.out.println("newResultEntities:::"+newResultEntities.size());
	                return newResultEntities;
	            }

			return null;
		} catch (Exception e) {
			e.printStackTrace();
			// TODO: handle exception properly
		}

		return null;
	}
	
	/**
	 * Returns list of tag names seperated by comma
	 *  
	 * @param tags
	 *            tag keys
	 * 
	 * @return
	 */
	public static String getTagString(List<Key> tags)
	{
		String tagStr="";
		List<Tag> tagList=TDQueryUtils.getAll(tags, new Tag());
		for(Tag tl:tagList)
		{
			if(tagStr.trim().length()==0)
				tagStr=tl.getName();
			else
				tagStr+=","+tl.getName();
		}
		return tagStr;
	}
	
	
	/**
	 * Gets  the dish object based on photo
	 * 
	 * @param photoKey
	 *            {@link Key} of the {@link Photo}
	 * @return {@link Dish} object
	 */
	@SuppressWarnings("unchecked")
	public static Dish getDishByPhoto(Key photoKey) {
		Query q = PMF.get().getPersistenceManager().newQuery(Dish.class);
		q.setFilter("photos.contains(:param)");
		List<Dish> d=(List<Dish>)q.execute(photoKey);
		if(!d.isEmpty()){
			return d.get(0);
		}else{
			return null;
		}
	}
	
	/**
	 * Gets keys of all the flags for a review
	 * @param reviewKeys {@link List} of the {@link Review}
	 * @return {@link List} of {@link Key} 
	 */
	@SuppressWarnings("unchecked")
	public static List<Key> getFlagKeysByReviews(List<Key> reviewKeys) {
		String query = "select key from " + Flag.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter(":review.contains(review)");

		return (List<Key>) q.execute(reviewKeys);
	}
	
	/**
	 * Gets keys of all the flags for Photos
	 * @param photoKeys {@link List} of the {@link Photo}
	 * @return {@link List} of {@link Key} objects 
	 */
	@SuppressWarnings("unchecked")
	public static List<Key> getFlagKeysByPhotos(List<Key> photoKeys) {
		String query = "select key from " + Flag.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter(":photo.contains(photo)");

		return (List<Key>) q.execute(photoKeys);
	}
	
	
	/**
	 * Gets keys of all the flags for  Restaurants
	 * @param restKeys {@link List} of the {@link Restaurant}
	 * @return {@link List} of {@link Key} objects 
	 */
	@SuppressWarnings("unchecked")
	public static List<Key> getFlagKeysByRestaurants(List<Key> restKeys) {
		String query = "select key from " + Flag.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter(":restaurant.contains(restaurant)");

		return (List<Key>) q.execute(restKeys);
	}
	
	/**
	 * Gets keys of all the flags for Dishes
	 * @param dishKeys {@link List} of the {@link Dish}
	 * @return {@link List} of {@link Key} objects 
	 */
	@SuppressWarnings("unchecked")
	public static List<Key> getFlagKeysByDishes(List<Key> dishKeys) {
		String query = "select key from " + Flag.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		q.setFilter(":dish.contains(dish)");

		return (List<Key>) q.execute(dishKeys);
	}
	

	
	
	@SuppressWarnings("unchecked")
	public static <T extends TDPersistable> T getEntity(PersistenceManager pm,long id,T t)
	{
		try{
			T entity=(T)pm.getObjectById(t.getClass(), id);
			return entity;
		}
		catch(Exception e)
		{
			System.err.println("entity does not exists");
		}
		return null;
	}
}
