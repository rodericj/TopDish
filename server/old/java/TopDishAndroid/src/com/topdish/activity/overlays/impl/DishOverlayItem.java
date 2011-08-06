package com.topdish.activity.overlays.impl;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.OverlayItem;
import com.topdish.data.Dish;

public class DishOverlayItem extends OverlayItem {

	public final Dish mDish;

	public DishOverlayItem(Dish dish) {
		this(dish.getGeoPoint(), dish.name, dish.restaurantName, dish);
	} 

	public DishOverlayItem(GeoPoint point, String title, String snippet,
			Dish dish) {
		super(point, title, snippet);

		this.mDish = dish;
	}

}
