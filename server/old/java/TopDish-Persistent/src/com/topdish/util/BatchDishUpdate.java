package com.topdish.util;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;

public final class BatchDishUpdate {

	@SuppressWarnings("unchecked")
	public static void setCity(String city, List<Key> dishKeys){
		if(dishKeys.size() > 0){
			PersistenceManager pm = PMF.get().getPersistenceManager();
			Query q = pm.newQuery(Dish.class, ":key.contains(key)");
			List<Dish> dishes = (List<Dish>) q.execute(dishKeys);
			
			for(Dish d : dishes){
				d.setCity(city);
			}
			pm.makePersistentAll(dishes);
		}
	}
	
	@SuppressWarnings("unchecked")
	public static void setState(String state, List<Key> dishKeys){
		if(dishKeys.size() > 0){
			PersistenceManager pm = PMF.get().getPersistenceManager();
			Query q = pm.newQuery(Dish.class, ":key.contains(key)");
			List<Dish> dishes = (List<Dish>) q.execute(dishKeys);
			
			for(Dish d : dishes){
				d.setState(state);
			}
			pm.makePersistentAll(dishes);
		}
	}
	
	@SuppressWarnings("unchecked")
	public static void setNeighborhood(String neighborhood, List<Key> dishKeys){
		if(dishKeys.size() > 0){
			PersistenceManager pm = PMF.get().getPersistenceManager();
			Query q = pm.newQuery(Dish.class, ":key.contains(key)");
			List<Dish> dishes = (List<Dish>) q.execute(dishKeys);
			
			for(Dish d : dishes){
				d.setNeighborhood(neighborhood);
			}
			pm.makePersistentAll(dishes);
		}
	}
	
	@SuppressWarnings("unchecked")
	public static void setLocation(double latitude, double longitude, List<String> geoCells, 
			List<Key> dishKeys){
		if(dishKeys.size() > 0){
			PersistenceManager pm = PMF.get().getPersistenceManager();
			Query q = pm.newQuery(Dish.class, ":key.contains(key)");
			List<Dish> dishes = (List<Dish>) q.execute(dishKeys);
			
			for(Dish d : dishes){
				d.setLocation(latitude, longitude, geoCells);
			}
			pm.makePersistentAll(dishes);
		}
	}
	
	@SuppressWarnings("unchecked")
	public static void setRestaurantName(String restaurantName, List<Key> dishKeys){
		if(dishKeys.size() > 0){
			PersistenceManager pm = PMF.get().getPersistenceManager();
			Query q = pm.newQuery(Dish.class, ":key.contains(key)");
			List<Dish> dishes = (List<Dish>) q.execute(dishKeys);
			
			for(Dish d : dishes){
				d.setRestaurantName(restaurantName);
			}
			pm.makePersistentAll(dishes);
		}
	}
}
