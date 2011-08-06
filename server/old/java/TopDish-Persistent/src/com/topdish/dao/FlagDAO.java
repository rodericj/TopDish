package com.topdish.dao;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Flag;
import com.topdish.jdo.Review;
import com.topdish.util.PMF;

public class FlagDAO implements EntityDAO {

	@Override
	public void addEntity(PersistenceManager pm, Object obj) {
		// TODO Auto-generated method stub

	}

	@SuppressWarnings("unchecked")
	@Override
	public void deleteEntities(PersistenceManager pm, List<Key> keys) {
		if(keys.size()>0)
		{
			Query query = pm.newQuery(Flag.class);
			query.setFilter(":key.contains(key)");
			List<Flag> flags =(List<Flag>) query.execute(keys);
			pm.deletePersistentAll(flags);
		}

	}

	@Override
	public void updateEntity(PersistenceManager pm, Object obj) {
		// TODO Auto-generated method stub

	}

}
