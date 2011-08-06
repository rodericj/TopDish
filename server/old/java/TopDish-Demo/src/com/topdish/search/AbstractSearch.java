package com.topdish.search;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.logging.Logger;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.GeocellQuery;
import com.beoui.geocell.model.Point;
import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDPersistable;
import com.topdish.jdo.Tag;
import com.topdish.util.SearchUtils;
import com.topdish.util.TDQueryUtils;

/**
 * Provides methods for searching objects in the datastore that implement {@link TDPersistable}
 * 
 * @author ralmand (Randy Almand)
 *
 */
public abstract class AbstractSearch {        
	/**
	 * The maximum number of words to use when generating search terms
	 */
    public static final int MAXIMUM_NUMBER_OF_WORDS_TO_SEARCH = 5;
    /**
     * The maximum number of search terms to generate
     */
    public static final int MAX_NUMBER_OF_WORDS_TO_PUT_IN_INDEX = 200;
    /**
     * The maximum length of a search term
     */
    public static final int MAX_STUB_WORD_LENGTH = 8;
    
    /**
     * A logger used for datastore events
     */
	protected static final Logger log = Logger.getLogger(AbstractSearch.class.getName());
	
	 /**
     * Allows searching through objects using multiple query strings.  Used for general searches across the 
     * site.   This function will use the search parameter provided by the object, for example "searchTerms".
     * 
     * @deprecated see {@link TDQueryUtils}
     * 
     * @param queryWords an array of strings to search for
     * @param pm the {@link PersistanceManager} to use when performing the query
     * @param type an {@link TDPersistable} object of the class type used in this query
     * @param limit the maximum number of results to return
     * @return a list of {@link TDPersistable} objects as the result of the query or <code>null</code> if none 
     * found
     */
	@SuppressWarnings("unchecked")
	@Deprecated
	public static List<Tag> searchTags(List<String> queryWords, PersistenceManager pm, int limit){
		List<Tag> result = null;
        Query query = pm.newQuery(Tag.class);
        query.setFilter("searchTerms == searchParam");
        query.setRange(0, limit);
        query.declareParameters("String searchParam");
        
        try {
        	result = (List<Tag>) query.execute(queryWords);
        }catch(Exception e){
        	e.printStackTrace();
        }
		
		return result;
	}
	
	/**
	 * Allows searching through restaurants using multiple query strings, a reference location, and a search 
	 * radius.
	 * 
	 * @deprecated see {@link TDQueryUtils}
	 * 
	 * @param queryWords an array of stings to search for
	 * @param pm the {@link PersistanceManager} to use when performing the query
	 * @param lat the latitude of the reference point to search around
	 * @param lng the longitude of the reference point to search around
	 * @param maxResults the maximum number of results to return
	 * @param maxDistance the maximum distance in meters from the reference point to include in the search 
	 * results
	 * @return a {@link List} of {@link Restaurant} objects
	 */
	@Deprecated
	public static List<Restaurant> searchRestaurants(List<String> queryWords, PersistenceManager pm, 
			double lat, double lng, int maxResults, int maxDistance){
		
		Point center = new Point(lat, lng);
		List<Restaurant> result = null;
		List<Object> paramList = null;
		String queryS = "";
		String paramS = "";
		GeocellQuery baseQuery;
		
		if(!queryWords.isEmpty()){
			paramList = new ArrayList<Object>();
			
			for(int i = 0; i < queryWords.size(); i++){
				if(i > 0){
					queryS += " && searchTerms.contains(s" + i + ")";
				}else{
					queryS += "searchTerms.contains(s" + i + ")";
				}
				
				paramList.add(queryWords.get(i));
				
				if(paramS.length() > 0){
					paramS += ", String s" + i;
				}else{
					paramS += "String s" + i;
				}
			}

			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		}else{
			baseQuery = new GeocellQuery("", "", new ArrayList<Object>());
		}
		
		try{
			result = GeocellManager.proximityFetch(center, maxResults, maxDistance, Restaurant.class, baseQuery, pm);
		}catch(Exception e){
			e.printStackTrace();
		}
		
		return result;
	}
	
	/**
	 * Allows searching through dishes using multiple query strings, a reference location, and a search radius.
	 * 
	 * @deprecated see {@link TDQueryUtils}
	 * 
	 * @param queryWords an array of stings to search for
	 * @param pm the {@link PersistanceManager} to use when performing the query
	 * @param lat the latitude of the reference point to search around
	 * @param lng the longitude of the reference point to search around
	 * @param maxResults the maximum number of results to return
	 * @param maxDistance the maximum distance in meters from the reference point to include in the search 
	 * results
	 * @return a {@link List} of {@link Dish} objects
	 */
	@Deprecated
	public static List<Dish> searchDishes(List<String> queryWords, PersistenceManager pm, double lat, double lng, 
			int maxResults, int maxDistance){
		
		Point center = new Point(lat, lng);
		List<Dish> result = new ArrayList<Dish>();
		List<Object> paramList = null;
		String queryS = "";
		String paramS = "";
		GeocellQuery baseQuery;
		
		if(!queryWords.isEmpty()){
			paramList = new ArrayList<Object>();
			
			for(int i = 0; i < queryWords.size(); i++){
				if(i > 0){
					queryS += " && searchTerms.contains(s" + i + ")";
				}else{
					queryS += "searchTerms.contains(s" + i + ")";
				}
				
				paramList.add(queryWords.get(i));
				
				if(paramS.length() > 0){
					paramS += ", String s" + i;
				}else{
					paramS += "String s" + i;
				}
			}

			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		}else{
			baseQuery = new GeocellQuery("", "", new ArrayList<Object>());
		}
		
		try{
			result = GeocellManager.proximityFetch(center, maxResults, maxDistance, Dish.class, baseQuery, pm);
		}catch(Exception e){
			e.printStackTrace();
		}

		return result;
	}
	
	/**
	 * Allows searching through dishes using several tags for filtering.
	 * 
	 * @param pm the {@link PersistanceManager} to use when performing the query
	 * @param maxResults the maximum number of results to return
	 * @param tagKeys a list of {@link Key} objects representing the tags to filter by
	 * @return a {@link List} of {@link Dish} objects
	 */
	public static List<Dish> filterDishes(PersistenceManager pm, int maxResults, List<Key> tagKeys, 
			double maxDistance, double lat, double lng){
		return filterDishes(pm, maxResults, tagKeys, maxDistance, lat, lng, 0);
	}
	
	public static List<Dish> filterDishes(PersistenceManager pm, int maxResults, List<Key> tagKeys,
			double maxDistance, double lat, double lng, int offset){
		return filterDishes(pm, maxResults, tagKeys, maxDistance, lat, lng, 0, null);
	}
	public static List<Dish> filterDishes(PersistenceManager pm, int maxResults, List<Key> tagKeys,
			double maxDistance, double lat, double lng, int offset, Comparator<Dish> comparator){
		String queryS = "";
		List<Object> paramList = new ArrayList<Object>();
		String paramS = "";
		Point center = new Point(lat, lng);
		List<Dish> result = new ArrayList<Dish>();
		maxResults += offset;
		
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
		
		GeocellQuery baseQuery = null;
		
		if(paramList.size() > 0){
			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		}else{
			baseQuery = new GeocellQuery("", "", paramList);
		}
		
		try{
			result = GeocellManager.proximityFetch(center, maxResults, maxDistance, Dish.class, baseQuery, pm);
		}catch(Exception e){
			e.printStackTrace();
		}
		
		if(comparator != null){
			Collections.sort(result, comparator);
		}
		
		if(offset >= result.size()){
			return new ArrayList<Dish>();
		}else if(offset > 0 && result.size() > 0){
			//skip the first _offset_ results
			return result.subList(offset, result.size());
		}else{
			return result;
		}
	}
    
	public static List<Dish> getDishesNearLocation(PersistenceManager pm, int maxResults, double maxDistance, double lat, double lng){
		return getDishesNearLocation(pm, maxResults, maxDistance, lat, lng, null);
	}
	
	public static List<Dish> getDishesNearLocation(PersistenceManager pm, int maxResults, double maxDistance, double lat, double lng, Comparator<Dish> comparator){
		GeocellQuery baseQuery = new GeocellQuery("", "", new ArrayList<Object>());
		Point center = new Point(lat, lng);
		List<Dish> result = new ArrayList<Dish>();
		
		try{
			result = GeocellManager.proximityFetch(center, maxResults, maxDistance, Dish.class, baseQuery, pm);
		}catch(Exception e){
			e.printStackTrace();
		}
		
		if(comparator != null){
			Collections.sort(result, comparator);
		}
		
		return result;
	}
	
	public static List<Restaurant> getRestaurantsNearLocation(PersistenceManager pm, int maxResults, double maxDistance, double lat, double lng){
		GeocellQuery baseQuery = new GeocellQuery("", "", new ArrayList<Object>());
		Point center = new Point(lat, lng);
		List<Restaurant> result = new ArrayList<Restaurant>();
		
		try{
			result = GeocellManager.proximityFetch(center, maxResults, maxDistance, Restaurant.class, baseQuery, pm);
		}catch(Exception e){
			e.printStackTrace();
		}
		
		return result;
	}
	
	@SuppressWarnings("unchecked")
	public static List<Dish> searchDishesByRestaurant(ArrayList<String> queryWords, PersistenceManager pm, int maxResults, Key restKey){
		List<Dish> result = new ArrayList<Dish>();
		List<Object> paramList = null;
		String paramS = "";
		String queryS = "";
		Query q = pm.newQuery(Dish.class);
		
		if(!queryWords.isEmpty()){
			paramList = new ArrayList<Object>();
			
			
			queryS += "restaurant == restParam";
			paramS = Key.class.getName() + " restParam";
			paramList.add(restKey);
			
			for(int i = 0; i < queryWords.size(); i++){
				queryS += " && searchTerms.contains(s" + i + ")";
				paramS += ", String s" + i;
				paramList.add(queryWords.get(i));
			}
			
			q.setFilter(queryS);
			q.declareParameters(paramS);
			
			result = (List<Dish>)q.executeWithArray(paramList.toArray());
		}
		
		return result;
	}
	
	/**
	 * Generates search terms for a given string using {@link SearchUtils#getSearchTerms(String, int)}
	 * 
	 * @param name the input string
	 * @return a {@link Set} of strings containing the generated search terms
	 */
    public static Set<String> getSearchTerms(String name){
        return SearchUtils.getSearchTerms(name, MAX_STUB_WORD_LENGTH);
    }
}