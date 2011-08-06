package com.topdish.dao;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;

public class DishDAO implements EntityDAO {

	@Override
	public void addEntity(PersistenceManager pm, Object obj) {
		// TODO Auto-generated method stub

	}

	@Override
	public void deleteEntities(PersistenceManager pm, List<Key> keys) {
		//deletes flags of dishes
		List<Key> flagKeys = TDQueryUtils.getFlagKeysByDishes(keys);
		FlagDAO fDAO=new FlagDAO();
		fDAO.deleteEntities(pm, flagKeys);
		
		Query query = pm.newQuery(Dish.class);
		query.setFilter(":keys.contains(key)");
		List<Dish> dishes=(List<Dish>)query.execute(keys);
		
		try{
		if(null!=dishes && dishes.size()>0)
		{
			//deletes photos of dishes
			PhotoDAO pDAO=new PhotoDAO();
			ReviewDAO rDAO=new ReviewDAO();
			for(Dish d:dishes)
			{
				//deletes photos of dishes
				if(null!=d.getPhotos() && d.getPhotos().size()>0)
					pDAO.deleteEntities(pm, d.getPhotos());
				
				//deletes reviews of dishes
				if(null!=d.getReviews() && d.getReviews().size()>0)
					rDAO.deleteEntities(pm, d.getReviews());
			}
			
		}
		}
		catch(Exception e)
		{
			System.err.println("error is "+e.getMessage());
		}
		
		pm.deletePersistentAll(dishes);

	}

	@Override
	public void updateEntity(PersistenceManager pm, Object obj) {
		// TODO Auto-generated method stub

	}

}
