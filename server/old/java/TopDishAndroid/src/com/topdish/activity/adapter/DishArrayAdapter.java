package com.topdish.activity.adapter;

import java.text.DecimalFormat;
import java.util.Collections;
import java.util.List;

import android.app.Application;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.imageloader.ImageLoader;
import com.topdish.R;
import com.topdish.TDApp;
import com.topdish.activity.adapter.view.DishListView;
import com.topdish.data.Dish;
import com.topdish.data.Tag;
import com.topdish.data.comparator.TagRelevanceComparator;

/**
 * Adapter to handle Dishes <br>
 * Based on the {@link ArrayAdapter}
 * 
 * @author Salil
 * 
 */
public class DishArrayAdapter extends ArrayAdapter<Dish> {

	/**
	 * Current {@link Context}
	 */
	private Context mContext;

	/**
	 * Current {@link Application} state as {@link TDApp}
	 */
	private TDApp mAppState;

	/**
	 * Image Loader
	 */
	private ImageLoader imageLoader;

	/**
	 * Constructor to set the {@link Context} and {@link List} of {@link Object}
	 * s
	 * 
	 * @param context
	 *            - curent {@link Context}
	 * @param objects
	 *            - {@link List} of {@link Object}s
	 */
	public DishArrayAdapter(Context context, List<Dish> objects) {
		this(context, 0, objects);
	}

	/**
	 * Constructor to create a {@link DishArrayAdapter} adapter
	 * 
	 * @param context
	 *            - current {@link Context}
	 * @param textViewResourceId
	 *            - <b> IGNORE THIS </b>
	 * @param objects
	 *            - {@link List} of {@link Object}s
	 */
	public DishArrayAdapter(Context context, int textViewResourceId, List<Dish> objects) {
		super(context, textViewResourceId, objects);

		this.mContext = context;
		this.mAppState = (TDApp) context.getApplicationContext();
		this.imageLoader = new ImageLoader();

		for (final Dish d : objects) {
			final String thumbnail = d.getThumbnailURL();
			if (null != thumbnail) {
				this.imageLoader.prefetch(thumbnail);
				this.imageLoader.preload(thumbnail);
			}
		}

	}

	/**
	 * <code>static</code> class to handle the current {@link View} row in the
	 * {@link DishArrayAdapter} <br>
	 * Current {@link Dish#id} is accessible via {@link ViewHolder#id}
	 * 
	 * @author Jen
	 * 
	 */
	public static class ViewHolder {

		/**
		 * {@link Dish#id}
		 */
		public long id;

		/**
		 * {@link Dish#photo}
		 */
		public ImageView dishPhotoView;

		/**
		 * {@link Dish#name}
		 */
		public TextView dishName;

		/**
		 * Distance to {@link Dish} <br>
		 * <b>Note:</b> use {@link Dish#distanceToDish(double, double)}
		 */
		public TextView distanceTV;

		/**
		 * {@link Dish#restaurantName}
		 */
		public TextView restaurantName;

		/**
		 * {@link Dish#description}
		 */
		// public TextView dishDescription;

		/**
		 * {@link Dish#tags}
		 */
		public TextView dishTags;

		/**
		 * {@link Dish#posReviews}
		 */
		public TextView posRev;

		/**
		 * {@link Dish#negReviews}
		 */
		public TextView negRev;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {

		// View to return
		View vi = convertView;

		// Static ViewHolder
		ViewHolder holder;

		// Check if row is null
		if (convertView == null) {

			// Create a new entry
			vi = new DishListView(getContext());

			// Store all references to static ViewHolder
			holder = new ViewHolder();
			holder.dishPhotoView = (ImageView) vi.findViewWithTag(DishListView.DISH_PHOTO_IV);
			holder.dishName = (TextView) vi.findViewWithTag(DishListView.DISH_NAME_TV);
			holder.distanceTV = (TextView) vi.findViewWithTag(DishListView.DISTANCE_TV);
			holder.restaurantName = (TextView) vi.findViewWithTag(DishListView.RESTAURANT_NAME_TV);
			// holder.dishDescription = (TextView)
			// vi.findViewWithTag(DishListView.DISH_DESCRIPTION_TV);
			holder.dishTags = (TextView) vi.findViewWithTag(DishListView.DISH_TAGS_TV);
			holder.posRev = (TextView) vi.findViewWithTag(DishListView.POS_REV_TV);
			holder.negRev = (TextView) vi.findViewWithTag(DishListView.NEG_REV_TV);

			// Save the Tag
			vi.setTag(holder);
		} else
			holder = (ViewHolder) vi.getTag();

		// Get the current dish
		final Dish dish = getItem(position);

		// Set required data for each entry
		holder.id = dish.id;
		holder.dishName.setText(dish.name);
		holder.distanceTV.setText(new DecimalFormat(".##").format(getDistance(dish) / 1609.344) + "mi");
		holder.restaurantName.setText(dish.restaurantName);
		// holder.dishDescription.setText(dish.description);
		Collections.sort(dish.tags, TagRelevanceComparator.getInstace());
		final StringBuilder tags = new StringBuilder();
		for (Tag curTag : dish.tags) {
			if (curTag.type.equals(Tag.CUISINE_NAME) || curTag.type.equals(Tag.MEALTYPE_NAME)
					|| curTag.type.equals(Tag.PRICE_NAME))
				tags.append(curTag.name + ", ");
		}
		holder.dishTags.setText(tags.subSequence(0, tags.length() - 2).toString());
		holder.posRev.setText(String.valueOf(dish.posReviews));
		holder.negRev.setText(String.valueOf(dish.negReviews));

		// Check if photoURLs are passed
		if (!dish.photoURL.isEmpty()) {

			// this.mAppState.imageLoader.displayImage(thumbnail, this.mContext,
			// holder.dishPhotoView);
			imageLoader.bind(this, holder.dishPhotoView, dish.getThumbnailURL());
		} else
			holder.dishPhotoView.setImageResource(R.drawable.nodishimg);

		return vi;

	}

	/**
	 * Get the distance from current location to dish <br>
	 * <b>Note:</b> Just calls {@link Dish#distanceToDish(double, double)} <br>
	 * <br>
	 * TODO: Make ASYNC! <br>
	 * 
	 * @param dish
	 *            - current {@link Dish}
	 * @return the <code>float</code> distance
	 */
	private float getDistance(final Dish dish) {
		return dish.distanceToDish(this.mAppState.getCurrentLocation().getLatitude(), this.mAppState
				.getCurrentLocation().getLongitude());
	}
}
