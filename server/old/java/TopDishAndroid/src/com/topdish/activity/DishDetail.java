package com.topdish.activity;

import java.text.DecimalFormat;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Display;
import android.view.Gravity;
import android.view.Window;
import android.widget.Gallery;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.LinearLayout.LayoutParams;

import com.topdish.TDApp;
import com.topdish.activity.adapter.DishPhotoAdapter;
import com.topdish.activity.adapter.ReviewListAdapter;
import com.topdish.api.util.DishConstants;
import com.topdish.data.Dish;

public class DishDetail extends Activity {

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = DishDetail.class.getSimpleName();

	/**
	 * Size of the Image to download
	 */
	private static int IMAGE_SIZE = 256;

	/**
	 * The current dish
	 */
	private Dish mDish;

	/**
	 * The Current Application State
	 */
	private TDApp mAppState;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);

		// Get the application
		mAppState = (TDApp) this.getApplication();

		// Check for incoming intent
		Intent intent = null;
		if (null != (intent = getIntent()) && intent.hasExtra(DishConstants.DISH_ID)) {

			// Set the dish
			mDish = mAppState.dishes.get(intent.getLongExtra(DishConstants.DISH_ID, 0));

		}

		// Check that dish was not null
		if (null != mDish) {

			// Get width and height of screen
			Display display = getWindowManager().getDefaultDisplay();
			final int width = display.getWidth();
			final int height = display.getHeight();

			// Set image size to 3/4ths the size of the screen
			IMAGE_SIZE = (int) ((width < height ? width : height) * .75);

			final LinearLayout ll = new LinearLayout(this);
			ll.setOrientation(LinearLayout.VERTICAL);
			ll.setGravity(Gravity.CENTER_HORIZONTAL);
			
			final Gallery dishPhotoGallery = new Gallery(this);
			dishPhotoGallery.setAdapter(new DishPhotoAdapter(this, this.mDish));
			ll.setScrollBarStyle(LinearLayout.SCROLLBARS_INSIDE_OVERLAY);
			
			ll.addView(dishPhotoGallery, new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));

			// TextView of Dish Name
			final TextView dishName = new TextView(this);
			dishName.setTextSize(20);
			dishName.setText(mDish.name);
			dishName.setTextColor(Color.parseColor("#AFDCEC"));

			ll.addView(dishName);

			final LinearLayout restDistLL = new LinearLayout(this);

			// TextView containing Restaurant Name
			final TextView restaurantName = new TextView(this);
			restaurantName.setText(mDish.restaurantName);
			restaurantName.setTextSize(16);
			restaurantName.setTextColor(Color.LTGRAY);
			restDistLL.addView(restaurantName, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT,
					LinearLayout.LayoutParams.WRAP_CONTENT, 1));

			if (null != mAppState.currentLocation) {

				float distance = mDish.distanceToDish(this.mAppState.currentLocation.getLatitude(),
						this.mAppState.currentLocation.getLongitude());

				// TextView containing Distance
				final TextView distanceTV = new TextView(this);
				// Set to two decimal places
				distanceTV.setText(new DecimalFormat(".##").format(distance / 1609.344) + "mi");
				distanceTV.setTextColor(Color.LTGRAY);
				distanceTV.setTextSize(10);
				distanceTV.setGravity(Gravity.RIGHT);

				restDistLL.addView(distanceTV, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT,
						LinearLayout.LayoutParams.WRAP_CONTENT, 1));

			}

			// Add Restaurant and Distance
			ll.addView(restDistLL);

			// TextView containing Description Name
			final TextView dishDescription = new TextView(this);
			dishDescription.setText(mDish.description);
			dishDescription.setTextColor(Color.WHITE);
			dishDescription.setTextSize(new Float(14));

			ll.addView(dishDescription);
			// sv.addView(ll);

			final ListView lv = new ListView(this);
			lv.addHeaderView(ll);
			lv.setAdapter(new ReviewListAdapter(this, this.mDish.reviews));
			// lv.setBackgroundDrawable(getResources().getDrawable(com.topdish.R.drawable.tile));
			// lv.setBackgroundDrawable(getResources().getDrawable(com.topdish.R.drawable.bgtile));

			// ll.addView(lv, new LinearLayout.LayoutParams(
			// LinearLayout.LayoutParams.WRAP_CONTENT,
			// LinearLayout.LayoutParams.FILL_PARENT));

			setContentView(lv);
			// setContentView(sv);

		} else
			finish();

	}

	@Override
	public void onBackPressed() {
		finish();
	}
}
