package com.topdish.util;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.TDUser;

public class RemoveOrphans {

	@SuppressWarnings("unchecked")
	public static void removeReview(Key k){
		PersistenceManager pm = PMF.get().getPersistenceManager();
		//Dish
		Query q = pm.newQuery(Dish.class, "reviews.contains(:review)");
		List<Dish> dishes = (List<Dish>) q.execute(k);
		
		for(Dish d : dishes){
			d.removeReview(k);
		}
		pm.makePersistentAll(dishes);
		
		//TDUser
		Query q1 = pm.newQuery(TDUser.class, "reviews.contains(:review)");
		List<TDUser> users = (List<TDUser>) q1.execute(k);
		
		for(TDUser u : users){
			u.removeReviewKey(k);
		}
		pm.makePersistentAll(users);
	}
}
