package com.topdish.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.Map.Entry;

import javax.jdo.JDOObjectNotFoundException;

import com.beoui.geocell.GeocellManager;
import com.beoui.geocell.model.GeocellQuery;
import com.beoui.geocell.model.Point;
import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;

public class TDRecoUtils {

	/**
	 * Calculate frequency of tags in a give list. Converts tags to lower case
	 * 
	 * @param tagKeys
	 *            List of tag Keys
	 * @return frequency list as HashMap
	 */
	private static HashMap<Key, Double> tagFreq(List<Key> tagKeys) {
		HashMap<Key, Double> tagMap = new HashMap<Key, Double>();
		for (Key tagKey : tagKeys) {
			final Double tagFreq = tagMap.get(tagKey);
			if (tagFreq != null) {
				tagMap.put(tagKey, tagFreq + 1);
			} else {
				tagMap.put(tagKey, 1.0);
			}
		}
		return tagMap;
	}

	/**
	 * Normalize tag frequencies
	 * 
	 * @param tagFreq
	 *            Modifies input so that freqs are normalized
	 * @return Maximum frequency and corresponding tag after normalizing
	 */
	private static Entry<Key, Double> normalize(HashMap<Key, Double> tagFreqs) {
		int magnitude = 0;
		for (Double freq : tagFreqs.values()) {
			magnitude += freq * freq;
		}

		// normalize freq
		Entry<Key, Double> maxFreq = null;
		for (Entry<Key, Double> item : tagFreqs.entrySet()) {
			item.setValue(item.getValue() / magnitude);
			if (maxFreq == null) {
				maxFreq = item;
			} else if (item.getValue() > maxFreq.getValue()) {
				maxFreq = item;
			}
		}

		return maxFreq;
	}

	/**
	 * Filter tags that are not important given some tags (some tags can/will be
	 * repeated)
	 * 
	 * @param tagKeys
	 *            List of tags to process
	 * @return Returns tags that are considered important according to freq
	 *         cutoff.
	 */
	private static HashMap<Key, Double> topTags(List<Key> tagKeys) {
		HashMap<Key, Double> tagFreqs = tagFreq(tagKeys);
		Entry<Key, Double> maxFreq = normalize(tagFreqs);

		// Retain tags within 0.9*maxFreq
		final double cutoffFreq = 0.8;
		HashMap<Key, Double> outTagFreqs = new HashMap<Key, Double>();
		for (Entry<Key, Double> item : tagFreqs.entrySet()) {
			if (item.getValue() > cutoffFreq * maxFreq.getValue()) {
				outTagFreqs.put(item.getKey(), item.getValue());
			}
		}

		return outTagFreqs;
	}

	/**
	 * Calculate Jaccard similarity given profile tags and one dish tags
	 * 
	 * @param profTags
	 *            Array of strings representing user profile.
	 * @param dishTags
	 *            Array of strings representing dish
	 * @return similarity score between 0 and 1
	 */
	@SuppressWarnings("unused")
	private static double jaccardSim(List<String> profTags,
			List<String> dishTags) {
		Set<String> profTagSet = new HashSet<String>();
		Set<String> dishTagSet = new HashSet<String>();
		Set<String> unionSet = new HashSet<String>(); // Need this as tags can
														// be repeated in input

		for (String s : profTags) {
			profTagSet.add(s.toLowerCase());
		}

		for (String s : dishTags) {
			dishTagSet.add(s.toLowerCase());
		}

		unionSet.addAll(dishTagSet);
		unionSet.addAll(profTagSet);

		dishTagSet.retainAll(profTagSet);

		return dishTagSet.size() / unionSet.size();
	}

	/**
	 * Calculate cosine similarity given profile tags and tags of one Dish
	 * 
	 * @param profileTags
	 *            Array of strings representing user profile
	 * @param dishTags
	 *            Array of strings representing dish
	 * @return similarity score between 0 and 1
	 */
	private static double cosineSim(List<Key> profTags, List<Key> dishTags) {
		HashMap<Key, Double> profTagMap = tagFreq(profTags);
		HashMap<Key, Double> dishTagMap = tagFreq(dishTags);

		normalize(profTagMap);
		normalize(dishTagMap);
		double dot = 0;

		for (Entry<Key, Double> profEntry : profTagMap.entrySet()) {
			final Double freq2 = dishTagMap.get(profEntry.getKey());
			if (null != freq2) {
				dot += freq2 * profEntry.getValue();
			}
		}

		return dot;
	}

	/**
	 * Aggregates all tags of reviews written by user
	 * 
	 * @param userKey
	 *            Key of user of interest
	 * @return Concatenation of all Tags of dishes the user has reviewed
	 */
	private static List<Key> getTagsFromUser(TDUser user) {
		List<Key> dishTagKeys = new ArrayList<Key>();
		Set<Key> reviewKeys = TDQueryUtils.getReviewKeysByUser(user.getKey());

		for (Key reviewKey : reviewKeys) {
			try {
				Review review = Datastore.get(reviewKey);
				Key dishKey = review.getDish();
				Dish dish = Datastore.get(dishKey);

				dishTagKeys.addAll(dish.getTags());
			} catch (JDOObjectNotFoundException e) {
				// dish did not exist
			}

		}

		return dishTagKeys;
	}

	/**
	 * Recommends dishes to user
	 * 
	 * @param user
	 *            User for whom we are recommending
	 * @param location
	 *            a Point to use as the center of the query
	 * @param maxResults
	 *            maximum number of results returned
	 * @param maxDistance
	 *            maximum distance to search in meters
	 * 
	 * @return SortedMap of predicted rating <Double> and Dish. Sorted by
	 *         prediction.
	 */
	public static SortedMap<Double, Dish> recommendDishes(TDUser user,
			Point location, int maxResults, int maxDistance) {
		final List<Object> paramList;
		final GeocellQuery baseQuery;

		List<Key> profTagList = getTagsFromUser(user);

		if (null != profTagList) {
			final HashMap<Key, Double> topProfTags = topTags(profTagList);

			String queryS = "tags.contains(t0)";
			String paramS = "com.google.appengine.api.datastore.Key t0";
			paramList = new ArrayList<Object>();
			int i = 0;

			for (Key tagKey : topProfTags.keySet()) {
				if (i == 0) {
					paramList.add(tagKey);
					i++;
					continue;
				}
				queryS += " && tags.contains(t" + i + ")";
				paramS += ", com.google.appengine.api.datastore.Key t" + i;
				paramList.add(tagKey);
				i++;
			}

			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		} else {
			// Profile is empty TODO tell user to rate some dishes to get recos
			// Show message: More the ratings - better the recommendations
			// baseQuery = new GeocellQuery("", "", new ArrayList<Object>());
			return null;
		}

		try {
			List<Dish> recoDishes = GeocellManager.proximityFetch(location,
					maxResults, maxDistance, new Dish(), baseQuery, PMF.get()
							.getPersistenceManager());

			if (profTagList != null) {
				SortedMap<Double, Dish> dishPreds = new TreeMap<Double, Dish>(
						Collections.reverseOrder());

				for (Dish d : recoDishes) {
					if (maxResults-- <= 0) {
						break;
					}
					List<Key> dishTagKeys = new ArrayList<Key>(d.getTags());

					// double negReviews = d.getNumNegReviews();
					// double posReviews = d.getNumPosReviews();

					double sim = cosineSim(profTagList, dishTagKeys)
							* d.getPosReviewPercentage();
					dishPreds.put(sim, d);

				}
				return dishPreds;
			}

		} catch (Exception e) {
			e.printStackTrace();
			// TODO: handle exception properly
		}

		return null;
	}

	/**
	 * Recommends restaurants to user -- NOT IMPLEMENTED! TODO
	 * 
	 * @param user
	 *            User for whom we are recommending
	 * @param location
	 *            a Point to use as the center of the query
	 * @param maxResults
	 *            maximum number of results returned
	 * @param maxDistance
	 *            maximum distance to search in meters
	 * 
	 * @return SortedMap of predicted rating <Double> and restaurant. Sorted by
	 *         prediction.
	 */
	public static SortedMap<Double, Restaurant> recommendRestaurants(
			TDUser user, Point location, int maxResults, int maxDistance) {
		final List<Object> paramList;
		final GeocellQuery baseQuery;

		List<Key> profTagList = getTagsFromUser(user);

		if (null != profTagList) {
			final HashMap<Key, Double> topProfTags = topTags(profTagList);

			String queryS = "tags.contains(t0)";
			String paramS = "com.google.appengine.api.datastore.Key t0";
			paramList = new ArrayList<Object>();
			int i = 0;

			for (Key tagKey : topProfTags.keySet()) {
				if (i == 0) {
					paramList.add(tagKey);
					i++;
					continue;
				}
				queryS += " && tags.contains(t" + i + ")";
				paramS += ", com.google.appengine.api.datastore.Key t" + i;
				paramList.add(tagKey);
				i++;
			}

			baseQuery = new GeocellQuery(queryS, paramS, paramList);
		} else {
			// Profile is empty TODO tell user to rate some restaurants to get
			// recos
			// Show message: More the ratings - better the recommendations
			// baseQuery = new GeocellQuery("", "", new ArrayList<Object>());
			return null;
		}

		try {
			List<Restaurant> recoRestaurants = GeocellManager.proximityFetch(
					location, maxResults, maxDistance, new Restaurant(),
					baseQuery, PMF.get().getPersistenceManager());

			if (profTagList != null) {
				SortedMap<Double, Restaurant> restPreds = new TreeMap<Double, Restaurant>(
						Collections.reverseOrder());

				for (Restaurant rest : recoRestaurants) {
					if (maxResults-- <= 0) {
						break;
					}
					List<Key> restTagKeys = new ArrayList<Key>();
					for (Key dishKey : TDQueryUtils
							.getDishKeysByRestaurant(rest.getKey())) {
						Dish d = Datastore.get(dishKey);
						restTagKeys.addAll(d.getTags());
					}

					// double negReviews = d.getNumNegReviews();
					// double posReviews = d.getNumPosReviews();

					if (restTagKeys.size() != 0) {
						double sim = cosineSim(profTagList, restTagKeys);
						// TBD need to impl * rest.getPosReviewPercentage();
						restPreds.put(sim, rest);
					}

				}
				return restPreds;
			}

		} catch (Exception e) {
			e.printStackTrace();
			// TODO: handle exception properly
		}

		return null;
	}
}
