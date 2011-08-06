package com.topdish.activity.adapter.view;

import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils.TruncateAt;
import android.view.Gravity;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.topdish.R;
import com.topdish.TDApp;
import com.topdish.data.Dish;

public class DishListView extends LinearLayout {

	/**
	 * DEBUG Tag
	 */
	public static final String TAG = DishListView.class.getSimpleName();

	/**
	 * Size of Image to Download
	 */
	public static final int IMAGE_SIZE = 150;

	/**
	 * Current Dish
	 */
	// public Dish dish;

	/**
	 * Current Context
	 */
	Context mContext;

	/**
	 * Current Application State
	 */
	TDApp mAppState;

	public static final String DISH_PHOTO_IV = "dishPhotoView";
	public ImageView dishPhotoView;

	public static final String DISH_NAME_TV = "dishName";
	public TextView dishName;

	public static final String DISTANCE_TV = "distanceTV";
	public TextView distanceTV;

	public static final String RESTAURANT_NAME_TV = "restaurantName";
	public TextView restaurantName;

	// public static final String DISH_DESCRIPTION_TV = "dishDescription";
	// public TextView dishDescription;

	public static final String DISH_TAGS_TV = "dishTags";
	public TextView dishTags;

	public static final String POS_REV_TV = "posRev";
	public TextView posRev;

	public static final String NEG_REV_TV = "negRev";
	public TextView negRev;

	/**
	 * Constructor that takes the current {@link Dish} and {@link Context}
	 * 
	 * @param context
	 *            - current {@link Context}
	 * @param dish
	 *            - current {@link Dish} to display
	 */
	public DishListView(Context context) {
		super(context);

		this.mContext = context;
		this.mAppState = (TDApp) this.mContext.getApplicationContext();

		// Set master LinearLayout to Horizontal
		setOrientation(LinearLayout.HORIZONTAL);
		setGravity(Gravity.CENTER_VERTICAL);

		// Dish Photo
		this.dishPhotoView = new ImageView(this.mContext);
		this.dishPhotoView.setTag(DISH_PHOTO_IV);
		this.dishPhotoView.setImageResource(R.drawable.nodishimg);
		this.dishPhotoView.setPadding(5, 5, 5, 5);

		// Add to View
		addView(this.dishPhotoView, new LinearLayout.LayoutParams(IMAGE_SIZE, IMAGE_SIZE, 0));

		// LinearLayout containing all Dish Meta Data
		final LinearLayout infoLL = new LinearLayout(this.mContext);
		infoLL.setOrientation(LinearLayout.VERTICAL);

		// LinearLayout containing Dish name and Distance from User
		final LinearLayout nameDistLL = new LinearLayout(this.mContext);
		nameDistLL.setOrientation(LinearLayout.HORIZONTAL);

		// TextView of Dish Name
		this.dishName = new TextView(this.mContext);
		this.dishName.setTag(DISH_NAME_TV);
		this.dishName.setTextColor(Color.parseColor("#AFDCEC"));
		this.dishName.setTextSize(20);
		this.dishName.setMaxLines(2);
		this.dishName.setEllipsize(TruncateAt.END);

		// Add with Weight of 1
		nameDistLL.addView(this.dishName, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT,
				LinearLayout.LayoutParams.WRAP_CONTENT, 1));

		// TextView containing Distance
		this.distanceTV = new TextView(this.mContext);
		this.distanceTV.setTag(DISTANCE_TV);
		this.distanceTV.setTextColor(Color.LTGRAY);
		this.distanceTV.setTextSize(12);
		this.distanceTV.setGravity(Gravity.RIGHT);

		// Add Distance TextView with Weight of 1
		nameDistLL.addView(this.distanceTV, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT,
				LinearLayout.LayoutParams.WRAP_CONTENT, 1));

		// Add Name and Distance LinearLayout to overall LinearLayout
		infoLL.addView(nameDistLL);

		// TextView containing Restaurant Name
		this.restaurantName = new TextView(this.mContext);
		this.restaurantName.setTag(RESTAURANT_NAME_TV);
		this.restaurantName.setTextColor(Color.LTGRAY);
		this.restaurantName.setTextSize(18);

		// Add Restaurant Name to Info LinearLayout
		infoLL.addView(this.restaurantName);

		final LinearLayout descRevLL = new LinearLayout(this.mContext);
		descRevLL.setOrientation(LinearLayout.HORIZONTAL);

		// TextView containing Description Name
		// this.dishDescription = new TextView(this.mContext);
		// this.dishDescription.setTag(DISH_DESCRIPTION_TV);
		// this.dishDescription.setTextColor(Color.WHITE);
		// this.dishDescription.setTextSize(new Float(11.5));
		//
		// // Max Lines are Two with Ellipses
		// this.dishDescription.setMaxLines(2);
		// this.dishDescription.setEllipsize(TruncateAt.END);
		//
		// descRevLL.addView(this.dishDescription, new
		// LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,
		// LinearLayout.LayoutParams.WRAP_CONTENT, 1));

		this.dishTags = new TextView(this.mContext);
		this.dishTags.setTag(DISH_TAGS_TV);
		this.dishTags.setTextColor(Color.WHITE);
		this.dishTags.setTextSize(new Float(16));

		// Max Lines are Two with Ellipses
		this.dishTags.setMaxLines(2);
		this.dishTags.setEllipsize(TruncateAt.END);

		descRevLL.addView(this.dishTags, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,
				LinearLayout.LayoutParams.WRAP_CONTENT, 1));

		final LinearLayout revLL = new LinearLayout(this.mContext);
		revLL.setOrientation(LinearLayout.VERTICAL);
		// revLL.setPadding(0, 0, 0, 3);

		this.posRev = new TextView(this.mContext);
		this.posRev.setTag(POS_REV_TV);
		// posRev.setText(String.valueOf(dish.posReviews) + "  ");
		this.posRev.setTextColor(Color.GREEN);
		// posRev.setPadding(0, 0, 0, 3);

		this.negRev = new TextView(this.mContext);
		this.negRev.setTag(NEG_REV_TV);
		// negRev.setText(String.valueOf(dish.negReviews) + "  ");
		this.negRev.setTextColor(Color.RED);
		// negRev.setPadding(0, 0, 0, 3);

		revLL.addView(this.posRev);
		revLL.addView(this.negRev);

		descRevLL.addView(revLL, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT,
				LinearLayout.LayoutParams.WRAP_CONTENT, 1));

		// Add a Description
		// infoLL.addView(dishDescription);
		infoLL.addView(descRevLL, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,
				LinearLayout.LayoutParams.FILL_PARENT));

		// Add the Info LinearLayout
		addView(infoLL, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,
				LinearLayout.LayoutParams.FILL_PARENT));

	}

}
