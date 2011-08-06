package com.topdish.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.StringTokenizer;

import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import org.apache.commons.lang.StringEscapeUtils;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Tag;

/**
 * Utilities related to Tags
 * 
 * @author Randy
 * 
 */
public class TagUtils {

	/**
	 * Key String = "key"
	 */
	public static final String KEY = "key";

	/**
	 * Name String = "name"
	 */
	public static final String NAME = "name";

	/**
	 * Description String = "description"
	 */
	public static final String DESCRIPTION = "description";

	/**
	 * Manual Order String = "order" <br>
	 * Used to define the order
	 */
	public static final String MANUAL_ORDER = "order";

	/**
	 * Returns a list of the tag keys.
	 * 
	 * @param pm
	 *            PersistanceManger Object
	 * @param listOfTags
	 *            Comma delimited tags "tag1, tag2"
	 * @param tagType
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public static List<Key> getTags(PersistenceManager pm, String listOfTags,
			int tagType) {
		if (pm == null || tagType < 0)
			throw new IllegalArgumentException(
					"Null PersistenceManager or Invalid TagType");
		if (listOfTags == null)
			listOfTags = "";

		final List<Key> tagKeysToAdd = new ArrayList<Key>();

		final StringTokenizer ingredientTokenizer = new StringTokenizer(
				listOfTags, ",");

		while (ingredientTokenizer.hasMoreTokens()) {
			String tagName = StringEscapeUtils.escapeSql(ingredientTokenizer
					.nextToken().trim());
			Query query = pm.newQuery(Tag.class);
			query.setFilter("name == :nameParam && type == :typeParam");

			try {
				for (Tag t : (List<Tag>) query.execute(tagName, tagType)) {
					Key k = t.getKey();
					tagKeysToAdd.add(k);
					if (t.getParentTag() != null)
						getAllParentTags(pm, tagKeysToAdd, k);
				}
			} finally {
				query.closeAll();
			}
		}
		return tagKeysToAdd;
	}

	/**
	 * Get Tag objects with names that exactly match those in tagNames
	 * 
	 * @param tagNames
	 *            array of string names of tags
	 * @return List of Tag objects
	 */
	@SuppressWarnings("unchecked")
	public static List<Key> getTagKeysByName(String[] tagNames) {
		String query = "select key from " + Tag.class.getName();
		Query q = PMF.get().getPersistenceManager().newQuery(query);
		String filter = "";
		String params = "";
		for (int i = 0; i < tagNames.length; i++) {
			// Switch it to lowercase
			tagNames[i] = tagNames[i].toLowerCase();
			if (i < tagNames.length - 1) {
				filter += "searchTerms.contains(n" + i + ") || ";
				params += "String n" + i + ", ";
			} else {
				filter += "searchTerms.contains(n" + i + ")";
				params += "String n" + i;
			}

		}
//		System.out.println("FILTER: " + filter);
//		System.out.println("PARAMS: " + params);
		q.setFilter(filter);
		q.declareParameters(params);
		return (List<Key>) q.executeWithArray((Object[]) tagNames);
	}

	/**
	 * Get all Tag objects of a specific tag type
	 * 
	 * @param type
	 *            Tag type
	 * @return List of Tag objects
	 */
	@SuppressWarnings("unchecked")
	public static List<Tag> getTagsByType(Integer type) {
		Query q = PMF.get().getPersistenceManager().newQuery(Tag.class);
		q.setFilter("type == :typeParam");
		return (List<Tag>) q.execute(type);
	}
	
	/**
	 * Get all Tag objects of specific tag types
	 * 
	 * @param type
	 *            List of Tag types
	 * @return List of Tag objects
	 */
	@SuppressWarnings("unchecked")
	public static List<Tag> getTagsByType(Integer[] types) {
		Query q = PMF.get().getPersistenceManager().newQuery(Tag.class);
		String filter = "";
		String params = "";
		for(int i = 0; i < types.length; i++){
			if(i < types.length - 1){
				filter += "type == n" + i + " || ";
				params += "int n" + i + ", ";
			}else{
				filter += "type == n" + i;
				params += "int n" + i;
			}
		}
		
		q.setFilter(filter);
		q.declareParameters(params);
		
		return (List<Tag>) q.executeWithArray((Object[]) types);
	}

	/**
	 * Returns a list of tags of the specified types
	 * 
	 * @param taglist
	 *            a List of tags
	 * @param types
	 *            a List of Integer types
	 * @return a List of Tags of the specified types
	 */
	public static List<Tag> filterTagsByType(List<Tag> tagList,
			List<Integer> types) {
		final List<Tag> filtered = new ArrayList<Tag>();
		for (Tag t : tagList) {
			if (types.contains(t.getType())) {
				filtered.add(t);
			}
		}
		return filtered;
	}

	/**
	 * Search tags by name and category.
	 * 
	 * @param pm
	 *            PersistanceManager object
	 * @param stringTag
	 *            name of a single tag
	 * @param tagType
	 *            type of the tag
	 * @param limit
	 *            maximum number of results
	 * @return List of Tag objects
	 */
	public static List<Tag> searchTagsByName(PersistenceManager pm,
			String stringTag, int tagType, int limit) {
		return searchTagsByNameType(pm, stringTag, Arrays.asList(tagType),
				limit);
	}

	/**
	 * Search tags by name and types
	 * 
	 * @param pm
	 *            PersistanceManger object
	 * @param stringTag
	 *            name of a single tag
	 * @param types
	 *            List of Integer tag types
	 * @param limit
	 *            maximum number of results
	 * @return List of Tag objects
	 */
	@SuppressWarnings("unchecked")
	public static List<Tag> searchTagsByNameType(PersistenceManager pm,
			String stringTag, List<Integer> types, int limit) {
		if (pm == null) {
			throw new IllegalArgumentException("Null PersistenceManager");
		}

		List<Tag> toReturn;
		Query q = pm.newQuery(Tag.class);
		q
				.setFilter("searchTerms.contains(:searchTerm) && :typeParam.contains(type)");
		q.setRange("0, " + limit);
		toReturn = (List<Tag>) q.execute(StringEscapeUtils
				.escapeJavaScript(stringTag.toLowerCase()), types);
		q.closeAll();
		return toReturn;
	}

	/**
	 * Get all TAGS from LIST<KEY> of TYPE
	 * 
	 * @param pm
	 * @param tagKeys
	 * @param tagType
	 *            Tag type, -1 for all.
	 * @return The List of Tags of Type
	 */
	public static List<Tag> getTagsByKey(PersistenceManager pm,
			List<Key> tagKeys, int tagType) {
		if (pm == null)
			throw new IllegalArgumentException("Null PersistenceManager");

		final List<Tag> allTags = new ArrayList<Tag>();
		for (Key tagkey : tagKeys) {
			if (tagkey == null)
				continue;
			try {
				Tag t = pm.getObjectById(Tag.class, tagkey);
				if (t != null && (t.getType() == tagType || tagType < 0))
					allTags.add(t);
			} catch (JDOObjectNotFoundException e) {
				// clean up references to nonexistant tag
				deleteTagInstances(pm, tagkey);
			}
		}
		return allTags;
	}

	/**
	 * Format a list of Tags to comma deliminated list
	 * 
	 * @param tagList
	 *            - list of tags
	 * @return list of tags as comma delminated string (ie. Bacon, American,
	 *         Cheese)
	 */
	public static String formatTagString(final List<Tag> tagList) {
		final StringBuilder s = new StringBuilder("");
		Iterator<Tag> tagI = tagList.iterator();
		while (tagI.hasNext())
			s.append((tagI.next().getName()) + (tagI.hasNext() ? ", " : ""));

		return s.toString();
	}

	/**
	 * Parse a String of Tags to a list <br>
	 * Converts: "Bacon, American, Cheese" to { [Bacon], [American], [Cheese] }
	 * 
	 * @param listOfTags
	 * @return the equivalent as a list
	 */
	public static List<String> parseTagString(String listOfTags) {
		final List<String> toRet = new ArrayList<String>();
		if (listOfTags != null && !listOfTags.isEmpty()) {
			final StringTokenizer tagTokenizer = new StringTokenizer(
					listOfTags, ",");

			while (tagTokenizer.hasMoreTokens())
				toRet.add(StringEscapeUtils.escapeJavaScript(tagTokenizer
						.nextToken().trim()));
		}
		return toRet;
	}

	/**
	 * Formats a list of tags to HTML output
	 * 
	 * @param tagList
	 * @return HTML representation of string list
	 */
	public static String formatTagHTML(List<Tag> tagList) {
		final StringBuilder s = new StringBuilder("");
		final Iterator<Tag> tagI = tagList.iterator();
		while (tagI.hasNext()) {
			final Tag t = tagI.next();
			s.append("<a href=\"#\">");
			s.append(t.getName());
			s.append("</a>");
			if (tagI.hasNext()) {
				s.append(", ");
			}
		}
		return s.toString();
	}

	/**
	 * Adds all Key of all parentTag's to the supplied ArrayList.
	 * 
	 * @param tags
	 *            List to add parent tags to
	 * @param k
	 *            Initial Tag Key
	 */
	public static void getAllParentTags(PersistenceManager pm, List<Key> tags,
			Key k) {
		final Tag t = pm.getObjectById(Tag.class, k);
		if (t.getParentTag() != null && !tags.contains(t)) {
			tags.add(t.getParentTag());
			getAllParentTags(pm, tags, t.getParentTag());
		}
	}

	/**
	 * Deletes a Tag Instance
	 * 
	 * @param pm
	 * @param k
	 *            - key of tag to be deleted
	 */
	@SuppressWarnings("unchecked")
	private static void deleteTagInstances(PersistenceManager pm, Key k) {
		final Query q = pm.newQuery(Dish.class);
		q.setFilter("tags.contains(:tagKey)");
		final List<Dish> dishes = (List<Dish>) q.execute(k);

		for (Dish d : dishes) {
			d.removeTag(k);
			pm.makePersistent(d);
		}
	}
	
	public static List<Key> getTagKeysById(String[] ids){
		List<Key> results = new ArrayList<Key>();
		for(int i = 0; i < ids.length; i++){
			try{
				results.add(PMF.get().getPersistenceManager().getObjectById(Tag.class, Long.parseLong(ids[i])).getKey());
			}catch(JDOObjectNotFoundException e){
				System.err.println("Tag not foud for id: " + ids[i]);
			}
		}
		return results;
	}
}
