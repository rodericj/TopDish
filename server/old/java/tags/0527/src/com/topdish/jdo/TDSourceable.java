package com.topdish.jdo;

import java.util.Map;

import com.google.appengine.api.datastore.Key;

/**
 * Objects that are sourced from a foriegn database
 * 
 * @author Salil
 * 
 */
public interface TDSourceable {

	/**
	 * Add a Source and its associated Object Id
	 * 
	 * @param sourceId
	 * @param objectId
	 * @return
	 */
	public TDSourceable addSource(Key source, String objectId);

	public Map<Key, String> getSources();

	public String getObjectIdsForSource(Key source);

}
