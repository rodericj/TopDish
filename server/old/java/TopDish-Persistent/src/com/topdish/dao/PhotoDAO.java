package com.topdish.dao;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Review;
import com.topdish.util.TDQueryUtils;

public class PhotoDAO implements EntityDAO {

	@Override
	public void addEntity(PersistenceManager pm, Object obj) {
		// TODO Auto-generated method stub

	}

	@SuppressWarnings("unchecked")
	@Override
	public void deleteEntities(PersistenceManager pm, List<Key> keys) {
		List<Key> flagKeys = TDQueryUtils.getFlagKeysByPhotos(keys);
		FlagDAO fDAO=new FlagDAO();
		fDAO.deleteEntities(pm, flagKeys);
		
		Query query = pm.newQuery(Photo.class, ":key.contains(key)");
		List<Photo> photos =(List<Photo>) query.execute(keys);
		pm.deletePersistentAll(photos);

	}

	@Override
	public void updateEntity(PersistenceManager pm, Object obj) {
		// TODO Auto-generated method stub

	}

}
