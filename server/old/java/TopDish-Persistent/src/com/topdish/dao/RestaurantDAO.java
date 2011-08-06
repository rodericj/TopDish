package com.topdish.dao;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.util.TDQueryUtils;

public class RestaurantDAO implements EntityDAO {

	@Override
	public void addEntity(PersistenceManager pm, Object obj) {
		// TODO Auto-generated method stub

	}

	@SuppressWarnings("unchecked")
	@Override
	public void deleteEntities(PersistenceManager pm, List<Key> keys) {
		//deletes flags of dishes
		List<Key> flagKeys = TDQueryUtils.getFlagKeysByRestaurants(keys);
		FlagDAO fDAO=new FlagDAO();
		fDAO.deleteEntities(pm, flagKeys);
		
		Query query = pm.newQuery(Restaurant.class);
		query.setFilter(":keys.contains(key)");
		List<Restaurant> restaurants=(List<Restaurant>)query.execute(keys);
		
		if(null!=restaurants && restaurants.size()>0)
		{
			//deletes photos of dishes
			PhotoDAO pDAO=new PhotoDAO();
			DishDAO dDAO=new DishDAO();
			for(Restaurant r:restaurants)
			{
				//deletes photos of restaurants
				if(null!=r.getPhotos() && r.getPhotos().size()>0)
					pDAO.deleteEntities(pm, r.getPhotos());
				
				//deletes dishes of restaurants
				if(null!=r.getDishes() && r.getDishes().size()>0)
				{
					List<Key> dishKeys=r.getDishes();
					dDAO.deleteEntities(pm, dishKeys);
				}
			}
			
		}
		
		
		pm.deletePersistentAll(restaurants);

	}

	@Override
	public void updateEntity(PersistenceManager pm, Object obj) {
		// TODO Auto-generated method stub

	}

}
