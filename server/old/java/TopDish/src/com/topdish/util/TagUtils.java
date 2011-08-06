package com.topdish.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;

import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.memcache.Expiration;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Tag;

public class TagUtils {
	private static final String TAG = TagUtils.class.getSimpleName();

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
	 *            a PersistanceManger Instance
	 * @param listOfTags
	 *            Comma delimited list of tags (e.g. "tag1, tag2")
	 * @param tagType
	 *            type of tag. See {@link Tag}.
	 * @return {@link List} of {@link Tag} {@link Key}s
	 * 
	 * @deprecated Use {@link TagUtils#getTagKeysByName(String[])} instead.
	 */
	@SuppressWarnings("unchecked")
	@Deprecated
	public static List<Key> getTags(PersistenceManager pm, String listOfTags, int tagType) {
		if (pm == null || tagType < 0)
			throw new IllegalArgumentException("Null PersistenceManager or Invalid TagType");
		if (listOfTags == null)
			listOfTags = "";

		final List<Key> tagKeysToAdd = new ArrayList<Key>();

		final StringTokenizer ingredientTokenizer = new StringTokenizer(listOfTags, ",");

		while (ingredientTokenizer.hasMoreTokens()) {
			String tagName = StringEscapeUtils.escapeSql(ingredientTokenizer.nextToken().trim());
			Query query = PMF.get().getPersistenceManager().newQuery(Tag.class);
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
	 * Get Tag objects with names that exactly match those in tagNames. Case
	 * insensitive.
	 * 
	 * @param tagNames
	 *            array of string names of tags
	 * @return {@link List} of {@link Tag}s
	 */
	@SuppressWarnings("unchecked")
	public static List<Key> getTagKeysByName(final String[] tagNames) {
		long start = System.currentTimeMillis();
		final String query = "SELECT key FROM " + Tag.class.getName();
		final Query q = PMF.get().getPersistenceManager().newQuery(query);
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
		q.setFilter(filter);
		q.declareParameters(params);
		
		long time = System.currentTimeMillis() - start;
		Logger.getLogger(TAG).info("Finished getTagKeysByName in " + time + "ms");
		return (List<Key>) q.executeWithArray((Object[]) tagNames);
	}

	/**
	 * Get all Tag objects of a specific tag type. Results cached up to 30
	 * minutes.
	 * 
	 * @param type
	 *            {@link Tag} type.
	 * @return {@link List} of {@link Tag}s.
	 */
	@SuppressWarnings("unchecked")
	public static Set<Tag> getTagsByType(Integer type) {
		long start = System.currentTimeMillis();
		final String mKey = "tagType-" + type;
		if (MemcacheServiceFactory.getMemcacheService().contains(mKey)) {
			return (Set<Tag>) MemcacheServiceFactory.getMemcacheService().get(mKey);
		}
		final String queryString = "SELECT key FROM " + Tag.class.getName();
		final Query query = PMF.get().getPersistenceManager().newQuery(queryString);
		query.setFilter("type == :type");

		final Set<Tag> results = Datastore.get(new HashSet<Key>((Collection<Key>) query
				.execute(type)));

		MemcacheServiceFactory.getMemcacheService().put(mKey, results,
				Expiration.byDeltaSeconds(60 * 30));
		
		long time = System.currentTimeMillis() - start;
		Logger.getLogger(TAG).info("Finished getTagsByType in " + time + "ms");
		return results;
	}

	/**
	 * Get all Tag objects of specific tag types. Results cached up to 30
	 * minutes.
	 * 
	 * @param type
	 *            array of {@link Integer} {@link Tag} types.
	 * @return {@link List} of {@link Tag}s.
	 */
	@SuppressWarnings("unchecked")
	public static Set<Tag> getTagsByType(Integer[] types) {
		long start = System.currentTimeMillis();
		final ArrayList<Integer> sortedTypes = new ArrayList<Integer>(Arrays.asList(types));
		Collections.sort(sortedTypes);
		final String mKey = "tagTypes-" + sortedTypes.toString();
		if (MemcacheServiceFactory.getMemcacheService().contains(mKey)) {
			return (Set<Tag>) MemcacheServiceFactory.getMemcacheService().get(mKey);
		}

		final Set<Tag> results = new HashSet<Tag>();
		for (int i = 0; i < types.length; i++) {
			results.addAll(getTagsByType(types[i]));
		}

		MemcacheServiceFactory.getMemcacheService().put(mKey, results,
				Expiration.byDeltaSeconds(60 * 30));
		
		long time = System.currentTimeMillis() - start;
		Logger.getLogger(TAG).info("Finished getTagsByType[] in " + time + "ms");
		return results;
	}

	/**
	 * Returns a list of tags of the specified types
	 * 
	 * @param taglist
	 *            {@link Collection} of {@link Tag}s.
	 * @param types
	 *            {@link List} of {@link Tag} types.
	 * @return a List of Tags of the specified types
	 */
	public static Set<Tag> filterTagsByType(Collection<Tag> tagList, List<Integer> types) {
		final Set<Tag> filtered = new HashSet<Tag>();
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
	 *            a PersistanceManager instance.
	 * @param stringTag
	 *            name of a single tag
	 * @param tagType
	 *            type of the tag
	 * @param limit
	 *            maximum number of results
	 * @return {@link List} of {@link Tag}s
	 * @deprecated Use {@link TDQueryUtils#searchTagsByName(String, int, int)}
	 *             instead.
	 */
	@Deprecated
	public static List<Tag> searchTagsByName(PersistenceManager pm, String stringTag, int tagType,
			int limit) {
		return searchTagsByNameType(pm, stringTag, Arrays.asList(tagType), limit);
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
	 * @deprecated Use
	 *             {@link TDQueryUtils#searchTagsByNameType(String, Set, int)}
	 *             instead.
	 */
	@Deprecated
	@SuppressWarnings("unchecked")
	public static List<Tag> searchTagsByNameType(PersistenceManager pm, String stringTag,
			List<Integer> types, int limit) {
		if (pm == null) {
			throw new IllegalArgumentException("Null PersistenceManager");
		}

		List<Tag> toReturn;
		Query q = PMF.get().getPersistenceManager().newQuery(Tag.class);
		q.setFilter("searchTerms.contains(:searchTerm) && :typeParam.contains(type)");
		q.setRange("0, " + limit);
		toReturn = (List<Tag>) q.execute(
				StringEscapeUtils.escapeJavaScript(stringTag.toLowerCase()), types);
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
	 * @deprecated This is a silly function. Use
	 *             {@link Datastore#get(Collection)} instead.
	 */
	@Deprecated
	public static List<Tag> getTagsByKey(PersistenceManager pm, List<Key> tagKeys, int tagType) {
		if (pm == null)
			throw new IllegalArgumentException("Null PersistenceManager");

		final List<Tag> allTags = new ArrayList<Tag>();
		for (Key tagkey : tagKeys) {
			if (tagkey == null)
				continue;
			try {
				Tag t = Datastore.get(tagkey);
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
	 * @deprecated You must be supremely lazy not to use
	 *             {@link String#split(String)}.
	 */
	@Deprecated
	public static List<String> parseTagString(String listOfTags) {
		final List<String> toRet = new ArrayList<String>();
		if (listOfTags != null && !listOfTags.isEmpty()) {
			final StringTokenizer tagTokenizer = new StringTokenizer(listOfTags, ",");

			while (tagTokenizer.hasMoreTokens())
				toRet.add(StringEscapeUtils.escapeJavaScript(tagTokenizer.nextToken().trim()));
		}
		return toRet;
	}

	/**
	 * Formats a list of tags to HTML output
	 * 
	 * @param tagList
	 * @return HTML representation of string list
	 */
	public static String formatTagHTML(Set<Tag> tagList) {
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
	 * @deprecated Use {@link TagUtils#getParentTagKeys(Set)} or
	 *             {@link TagUtils#getParentTags(Set)} instead.
	 */
	@Deprecated
	public static void getAllParentTags(PersistenceManager pm, List<Key> tags, Key k) {
		final Tag t = Datastore.get(k);
		if (t.getParentTag() != null && !tags.contains(t)) {
			tags.add(t.getParentTag());
			getAllParentTags(pm, tags, t.getParentTag());
		}
	}

	/**
	 * Get all the parent {@link Tag} {@link Key}s for a list of {@link Tag}
	 * {@link Key}s.
	 * 
	 * @param tagKeys
	 *            {@link Set} of {@link Key}s
	 * @return a {@link Set} of parent {@link Key}s found, if any.
	 */
	public static Set<Key> getParentTagKeys(final Set<Key> tagKeys) {
		final Set<Tag> childTags = Datastore.get(tagKeys);
		final Set<Key> parentKeys = new HashSet<Key>();
		for (Tag t : childTags) {
			if (t.hasParent()) {
				parentKeys.add(t.getParentTag());
			}
		}
		return parentKeys;
	}

	/**
	 * Get all the parent {@link Tag}s for a list of {@link Tag} {@link Key}s
	 * 
	 * @param tagKeys
	 *            {@link Set} of {@link Key}s
	 * @return a {@link Set} of {@link Tag}s found, if any.
	 */
	public static Set<Tag> getParentTags(final Set<Key> tagKeys) {
		return Datastore.get(getParentTagKeys(tagKeys));
	}

	/**
	 * Deletes a Tag Instance
	 * 
	 * @param pm
	 * @param k
	 *            - key of tag to be deleted
	 * @deprecated Use {@link Datastore#delete(Set)} instead.
	 */
	@SuppressWarnings("unchecked")
	@Deprecated
	private static void deleteTagInstances(PersistenceManager pm, Key k) {
		final Query q = PMF.get().getPersistenceManager().newQuery(Dish.class);
		q.setFilter("tags.contains(:tagKey)");
		final List<Dish> dishes = (List<Dish>) q.execute(k);

		for (Dish d : dishes) {
			d.removeTag(k);
			Datastore.put(d);
		}
	}

	/**
	 * 
	 * @param ids
	 * @return
	 * @deprecated This is a silly function. Use
	 *             {@link KeyFactory#createKey(String, long)} instead.
	 */
	@Deprecated
	public static List<Key> getTagKeysById(String[] ids) {
		List<Key> results = new ArrayList<Key>();
		for (int i = 0; i < ids.length; i++) {
			try {
				results.add(KeyFactory.createKey(Tag.class.getSimpleName(), Long.parseLong(ids[i])));
			} catch (JDOObjectNotFoundException e) {
				System.err.println("Tag not foud for id: " + ids[i]);
			}
		}
		return results;
	}
}
