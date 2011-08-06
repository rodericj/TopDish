package com.topdish.api.util;

import java.util.HashSet;
import java.util.Set;

import com.topdish.api.jdo.DishLite;
import com.topdish.api.jdo.RestaurantLite;
import com.topdish.api.jdo.ReviewLite;
import com.topdish.api.jdo.TagLite;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Datastore;

public final class ConvertToLite {

	public static Set<DishLite> convertDishes(final Set<Dish> dishes) {
		final Set<DishLite> dishLites = new HashSet<DishLite>();
		for (final Dish d : dishes) {
			dishLites.add(new DishLite(d));
		}
		return dishLites;
	}

	public static Set<RestaurantLite> convertRestaurants(
			final Set<Restaurant> restaurants) {
		final Set<RestaurantLite> restLites = new HashSet<RestaurantLite>();
		if (null != restaurants)
			for (final Restaurant r : restaurants) {
				restLites.add(new RestaurantLite(r));
			}
		return restLites;
	}

	public static Set<ReviewLite> convertReviews(final Set<Review> reviews) {
		final Set<ReviewLite> revLites = new HashSet<ReviewLite>();
		for (final Review r : reviews) {
			TDUser user = Datastore.get(r.getCreator());
			revLites.add(new ReviewLite(r, user.getNickname()));
		}
		return revLites;
	}

	public static Set<TagLite> convertTags(final Set<Tag> tags) {
		final Set<TagLite> tagLites = new HashSet<TagLite>();
		for (final Tag t : tags) {
			tagLites.add(new TagLite(t));
		}
		return tagLites;
	}
}