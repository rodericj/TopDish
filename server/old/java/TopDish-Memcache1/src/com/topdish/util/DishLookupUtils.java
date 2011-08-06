package com.topdish.util;

import java.util.List;

import javax.jdo.PersistenceManager;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Tag;

public class DishLookupUtils {
	public static Key getPriceKey(Key dishKey){
		PersistenceManager pm = PMF.get().getPersistenceManager();		
		Dish d = pm.getObjectById(Dish.class, dishKey);
		List<Key> dishTagKeys = d.getTags();
		
		for(Key k : dishTagKeys){
			Tag t = pm.getObjectById(Tag.class, k);
			if(t.getType() == Tag.TYPE_PRICE){
				System.out.println("Price found: " + k.getId());
				d.setPrice(k);
				pm.makePersistent(d);
				return k;
			}
		}
		
		return null;
	}
	
	public static Key getCategoryKey(Key dishKey){
		PersistenceManager pm = PMF.get().getPersistenceManager();		
		Dish d = pm.getObjectById(Dish.class, dishKey);
		List<Key> dishTagKeys = d.getTags();
		
		for(Key k : dishTagKeys){
			Tag t = pm.getObjectById(Tag.class, k);
			if(t.getType() == Tag.TYPE_MEALTYPE){
				System.out.println("Category found: " + k.getId());
				d.setCategory(k);
				pm.makePersistent(d);
				return k;
			}
		}
		
		return null;
	}
}
