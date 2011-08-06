package com.topdish.dao;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Flag;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDPersistable;
import com.topdish.util.TDQueryUtils;

public class ReviewDAO implements EntityDAO {

	@Override
	public void addEntity(PersistenceManager pm, Object obj) {
		// TODO Auto-generated method stub

	}

	@SuppressWarnings("unchecked")
	@Override
	public void deleteEntities(PersistenceManager pm, List<Key> keys) {
		
		List<Key> flagKeys = TDQueryUtils.getFlagKeysByReviews(keys);
		FlagDAO f1=new FlagDAO();
		f1.deleteEntities(pm, flagKeys);
		
		Query query = pm.newQuery(Review.class, ":key.contains(key)");
		List<Review> reviews =(List<Review>) query.execute(keys);
		pm.deletePersistentAll(reviews);


	}

	@Override
	public void updateEntity(PersistenceManager pm, Object obj) {
		// TODO Auto-generated method stub

	}
	

}
