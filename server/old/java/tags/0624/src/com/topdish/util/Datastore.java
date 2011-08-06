package com.topdish.util;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import org.apache.log4j.Logger;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.memcache.MemcacheServiceFactory;
import com.topdish.jdo.TDPersistable;

public abstract class Datastore {

	private static final String TAG = Datastore.class.getSimpleName();

	/**
	 * Gets an item from the datastore. Items are returned from Memcache or
	 * pulled from the actual datastore and put in cache before returning.
	 * 
	 * @param <T>
	 *            Type of object to retrieve. Must extend {@link TDPersistable}.
	 * @param key
	 *            {@link Key} of the object
	 * @return Object from the datastore
	 */

	@SuppressWarnings("unchecked")
	public static <T extends TDPersistable> T get(final Key key) {
		//long start = System.currentTimeMillis();
		if(null == key){
			//Logger.getLogger(TAG).info("Datastore.get(null)");
			return null;
		}
		
		if (!MemcacheServiceFactory.getMemcacheService().contains(key)) {
			final PersistenceManager pm = PMF.get().getPersistenceManager();
			// Item not found in cache. Fetch from datastore.
			try {
				final T found = (T) pm.getObjectById(
						Class.forName("com.topdish.jdo." + key.getKind()), key);
				MemcacheServiceFactory.getMemcacheService().put(found.getKey(), found);
				//long time = System.currentTimeMillis() - start;
				//Logger.getLogger(TAG).info("Finished get(Key) in " + time + "ms");
				return pm.detachCopy(found);
			} catch (ClassNotFoundException e) {
				Logger.getLogger(TAG).error("Could not find object.", e);
				return null;
			} finally {
				pm.close();
			}
		} else {
			// Item found in cache, return from cache.
			return (T) MemcacheServiceFactory.getMemcacheService().get(key);
		}
	}

	/**
	 * Returns a {@link Set} of objects for a given collection of {@link Key}s.
	 * Objects are either returned from memcache or pulled from the actual
	 * datastore and put in cache before returning.
	 * 
	 * @param <T>
	 *            Type of the object to retrieve. Must extend
	 *            {@link TDPersistable}.
	 * @param keys
	 *            {@link Collection} of {@link Key}s to fetch objects for.
	 * @return {@link Set} of objects found in the datastore or cache.
	 */
	@SuppressWarnings("unchecked")
	public static <T extends TDPersistable> Set<T> get(final Collection<Key> keys) {
		//long start = System.currentTimeMillis();
		final PersistenceManager pm = PMF.get().getPersistenceManager();
		// get all objects found in cache
		final Map<Key, T> foundInCache = (Map<Key, T>) MemcacheServiceFactory.getMemcacheService()
				.getAll(keys);

		// build return set
		final Set<T> toReturn = new HashSet<T>(foundInCache.values());

		// if there are cache misses, pull objects from datastore
		if (null != keys && !keys.isEmpty() && keys.size() != foundInCache.size()) {

			// get a single key for class reference
			final Key classRefKey = keys.iterator().next();

			Collection<Key> keysToFetch = new ArrayList<Key>();

			// check for keys not found in cache
			for (Key k : keys) {
				if (!foundInCache.containsKey(k)) {
					keysToFetch.add(k);
				}
			}

			// query datastore for missing objects
			final Query q = pm.newQuery("select from com.topdish.jdo." + classRefKey.getKind()
					+ " where :keys.contains(key)");

			// items returned from datastore
			final Collection<T> objectsFound = pm.detachCopyAll((Collection<T>) q
					.execute(keysToFetch));

			Map<Key, T> itemsToCache = new HashMap<Key, T>();

			// put items in key/object map for easy dumping in to memcache
			for (final T obj : objectsFound) {
				itemsToCache.put(obj.getKey(), obj);
			}

			// close the query
			q.closeAll();

			// put all items not yet cached into memcache
			MemcacheServiceFactory.getMemcacheService().putAll(itemsToCache);

			// log items put in cache
			// Logger.getLogger(Datastore.class.getName()).info(
			// "CACHED keys: " + itemsToCache.keySet());

			// finish adding to return set
			toReturn.addAll(itemsToCache.values());
		}

		//long time = System.currentTimeMillis() - start;
		//Logger.getLogger(TAG).info("Finished get(Collection<Key>) in " + time + "ms");
		return toReturn;
	}

	/**
	 * Put a single object in the datastore. Also added to memcache.
	 * 
	 * @param <T>
	 *            type that extends {@link TDPersistable}
	 * @param toStore
	 *            object to store
	 */
	public static <T extends TDPersistable> void put(T toStore) {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		pm.makePersistent(toStore);
		Logger.getLogger(Datastore.class.getName()).info(
				"PERSISTED object with key " + toStore.getKey().toString());
		MemcacheServiceFactory.getMemcacheService().put(toStore.getKey(), toStore);
		// Logger.getLogger(Datastore.class.getName()).info(
		// "CACHED object with key " + toStore.getKey());
		pm.close();
	}

	/**
	 * Put a {@link Set} of objects in the datastore. Also added to memcache.
	 * 
	 * @param <T>
	 *            type that extends {@link TDPersistable}
	 * @param toStore
	 *            {@link Set} of objects to store
	 */
	public static <T extends TDPersistable> void put(Set<T> toStore) {
		PMF.get().getPersistenceManager().makePersistentAll(toStore);

		final Map<Key, T> toCache = new HashMap<Key, T>();

		for (final T obj : toStore) {
			toCache.put(obj.getKey(), obj);
		}

		// log the persisted keys
		Logger.getLogger(Datastore.class.getName()).info(
				"PERSISTED object with keys: " + toCache.keySet());

		MemcacheServiceFactory.getMemcacheService().putAll(toCache);

		// log the cache put
		// Logger.getLogger(Datastore.class.getName()).info("CACHED keys: " + toCache.keySet());
	}

	/**
	 * Delete an object from the datastore and cache.
	 * 
	 * @param <T>
	 *            type that extends {@link TDPeristable}
	 * @param obj
	 *            object to delete
	 * @deprecated Just use the key insetad {@link Datastore#delete(Key)}
	 */
	public static <T extends TDPersistable> void delete(T obj) {
		delete(obj.getKey());
	}

	/**
	 * Delete an object from the datastore and cache.
	 * 
	 * @param <T>
	 *            type that extends {@link TDPeristable}
	 * @param key
	 *            {@link Key} of object to delete
	 */
	public static void delete(Key key) {
		deleteKey(key);
		// remove objects from memcache
		MemcacheServiceFactory.getMemcacheService().delete(key);
	}

	/**
	 * Delete a {@link Set} of objects from the datastore and cache.
	 * 
	 * @param keys
	 *            {@link Set} of {@link Key}s to delete
	 * 
	 */
	@SuppressWarnings("unchecked")
	public static void delete(Set<Key> keys) {
		final PersistenceManager pm = PMF.get().getPersistenceManager();
		try {
			final Set<TDPersistable> toDelete = (Set<TDPersistable>) pm.getObjectsById(keys);
			pm.deletePersistentAll(toDelete);
		} catch (Exception e) {
			Logger.getLogger(TAG).error("Could not delete objects.", e);
		} finally {
			pm.close();
		}
		// remove objects from memcache
		MemcacheServiceFactory.getMemcacheService().deleteAll(keys);
	}

	/**
	 * Delete an object from the datastore corresponding to the given key.
	 * 
	 * @param key
	 *            a {@link Key} of an object to delete.
	 */
	@SuppressWarnings("unchecked")
	private static void deleteKey(Key key) {
		final PersistenceManager pm = PMF.get().getPersistenceManager();
		try {
			final Class<Object> fc = (Class<Object>) Class.forName("com.topdish.jdo."
					+ key.getKind());
			final Object obj = pm.getObjectById(fc.newInstance().getClass(), key.getId());
			pm.deletePersistent(obj);
			// log key to be deleted
			Logger.getLogger(Datastore.class.getSimpleName()).info("DELETED key " + key);
		} catch (Exception e) {
			Logger.getLogger(TAG).error("Could not delete objects.", e);
		} finally {
			pm.close();
		}
	}

	/**
	 * Check if an object exists in the datastore corresponding to the given
	 * key.
	 * 
	 * @param key
	 *            a {@link Key} object to look up.
	 * @return <code>true</code> if the object exists, <code>false</code>
	 *         otherwise.
	 */
	@SuppressWarnings("unchecked")
	public static boolean exists(Key key) {
		long start = System.currentTimeMillis();
		if (MemcacheServiceFactory.getMemcacheService().contains(key)) {
			// Assume that if its in memcache, it exists in the datastore
			return true;
		} else {
			// If not in cache, check the datastore.
			try {
				// TODO(randy): Make this faster. Just look up the ID instead!
				final PersistenceManager pm = PMF.get().getPersistenceManager();
				final Class<Object> fc = (Class<Object>) Class.forName("com.topdish.jdo."
						+ key.getKind());
				pm.getObjectById(fc.newInstance().getClass(), key.getId());
				// If we got this far, the object does exist.
				long time = System.currentTimeMillis() - start;
				Logger.getLogger(TAG).info("Finished exists in " + time + "ms");
				return true;
			} catch (Exception e) {
				return false;
			}
		}
	}
}
