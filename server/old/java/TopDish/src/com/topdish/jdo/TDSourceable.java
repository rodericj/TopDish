package com.topdish.jdo;

import java.util.Map;

import com.google.appengine.api.datastore.Key;

/**
 * Interface to handle Objects {@link Source}d from foreign datastores
 * 
 * @author Salil
 * 
 */
public interface TDSourceable {

	/**
	 * Add a {@link Source}'s {@link Key} to this Object
	 * 
	 * @param source
	 *            - they {@link Key} of the {@link Source}
	 * @param foriegnId
	 *            - the foreign id for this object stored by the foreign
	 *            datastore
	 * @return the current instance of the object
	 */
	public TDSourceable addSource(Key source, String foriegnId);

	/**
	 * Get a {@link Map} of the {@link Source}s and their associated foriegn ids
	 * 
	 * @return a {@link Map} of the {@link Source}s and foreign ids
	 */
	public Map<Key, String> getSources();

	/**
	 * Get the Foreign Ids for a given {@link Source} {@link Key}
	 * 
	 * @param source
	 *            - the {@link Key} of the {@link Source}
	 * @return the foreign id
	 */
	public String getForeignIdForSource(Key source);

}
