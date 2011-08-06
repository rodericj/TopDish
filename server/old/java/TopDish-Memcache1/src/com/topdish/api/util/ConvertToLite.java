package com.topdish.api.util;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.jdo.PersistenceManager;

import com.topdish.api.jdo.DishLite;
import com.topdish.api.jdo.RestaurantLite;
import com.topdish.api.jdo.ReviewLite;
import com.topdish.api.jdo.TagLite;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;

public final class ConvertToLite{

	public static List<DishLite> convertDishes(List<Dish> dishes){
		List<DishLite> dishLites = new ArrayList<DishLite>();
		for(Dish d : dishes){
			dishLites.add(new DishLite(d));
		}
		return dishLites;
	}
	
	public static List<RestaurantLite> convertRestaurants(List<Restaurant> restaurants){
		List<RestaurantLite> restLites = new ArrayList<RestaurantLite>();
		for(Restaurant r : restaurants){
			restLites.add(new RestaurantLite(r));
		}
		return restLites;
	}
	
	public static List<ReviewLite> convertReviews(Collection<Review> reviews){
		List<ReviewLite> revLites = new ArrayList<ReviewLite>();
		PersistenceManager pm = PMF.get().getPersistenceManager();
		for(Review r : reviews){
			TDUser user = pm.getObjectById(TDUser.class, r.getCreator());
			revLites.add(new ReviewLite(r, user.getNickname()));
		}
		return revLites;
	}

	public static List<TagLite> convertTags(Collection<Tag> tags) {
		List<TagLite> tagLites = new ArrayList<TagLite>();
		for(Tag t : tags){
			tagLites.add(new TagLite(t));
		}
		return tagLites;
	}
}
