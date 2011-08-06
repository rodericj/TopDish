package com.topdish.dao;

import java.util.List;

import javax.jdo.PersistenceManager;

import com.google.appengine.api.datastore.Key;

public interface EntityDAO {
	public void addEntity(PersistenceManager pm,Object obj);
	
	public void deleteEntities(PersistenceManager pm,List<Key> keys);
	
	public void updateEntity(PersistenceManager pm,Object obj);
	
	

}
