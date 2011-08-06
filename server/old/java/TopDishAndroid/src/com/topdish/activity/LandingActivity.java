package com.topdish.activity;

import android.R;
import android.app.Activity;
import android.app.ListActivity;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.LinearLayout;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

import com.topdish.TDApp;
import com.topdish.activity.adapter.HomeScreenShortcutAdapter;
import com.topdish.activity.header.HeaderView;
import com.topdish.data.HomeScreenItem;
import com.topdish.data.SearchAction;
import com.topdish.utils.TDUtils;

public class LandingActivity extends Activity {

	/**
	 * DEBUG Tag
	 */
	public static final String TAG = ListActivity.class.getSimpleName();

	/**
	 * Dishes Near Me
	 */
	private static final String DISHES_NEAR_ME = "Dishes Near Me";

	/**
	 * Map View
	 */
	private static final String MAP_DISHES = "Map View";

	/**
	 * Rate a Dish
	 */
	private static final String RATE_A_DISH = "Rate a Dish";

	/**
	 * Account Info
	 */
	private static final String ACCOUNT_INFO = "Account Info";

	/**
	 * The Current Application State
	 */
	private TDApp mAppState;

	/**
	 * Action to be completed
	 */
	private SearchAction action;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);

		// Application state
		this.mAppState = (TDApp) this.getApplication();

		final LinearLayout ll = new LinearLayout(this);
		ll.setOrientation(LinearLayout.VERTICAL);
		action = new SearchAction(this) {

			@Override
			public boolean doAction() {
				startActivity(new Intent(LandingActivity.this, ResultListActivity.class));
				return true;
			}
		};
		ll.addView(new HeaderView(this, action), 0, new LayoutParams(LayoutParams.FILL_PARENT,
				LayoutParams.WRAP_CONTENT));

		// The GridView
		final GridView grid = new GridView(this);
		grid.setNumColumns(2);
		grid.setHorizontalSpacing(20);
		grid.setVerticalSpacing(20);
		grid.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
		
		// Set the adapter with the Icons
		grid.setAdapter(new HomeScreenShortcutAdapter(this, getIcons()));
		grid.setGravity(Gravity.CENTER);
		grid.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View v, int position, long id) {

				if (null != v.getTag()) {
					final HomeScreenItem his = ((HomeScreenItem) v.getTag());
					his.doAction(LandingActivity.this);
				}

			}
		});

		ll.addView(grid, 1, new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));

		setContentView(ll);

	}

	private HomeScreenItem[] getIcons() {

		final HomeScreenItem[] icons = new HomeScreenItem[4];

		icons[0] = new HomeScreenItem(DISHES_NEAR_ME, this.getResources().getDrawable(R.drawable.ic_menu_compass)) {

			@Override
			public void doAction(Context context) {

				final Location curLoc = mAppState.getCurrentLocation();
				TDUtils.generateDishSearchComms(LandingActivity.this, ResultListActivity.class, mAppState, action)
						.searchDishes(curLoc.getLatitude(), curLoc.getLongitude(), 1000000, 25, new String());

			}
		};

		icons[1] = new HomeScreenItem(RATE_A_DISH, this.getResources().getDrawable(R.drawable.ic_menu_add)) {

			@Override
			public void doAction(Context context) {

				startActivity(new Intent(context, RateDishActivity.class));

			}
		};

		icons[2] = new HomeScreenItem(MAP_DISHES, this.getResources().getDrawable(R.drawable.ic_menu_mapmode)) {

			@Override
			public void doAction(Context context) {
				startActivity(new Intent(context, SearchMapActivity.class));
			}
		};

		icons[3] = new HomeScreenItem(ACCOUNT_INFO, this.getResources().getDrawable(R.drawable.ic_menu_myplaces)) {

			@Override
			public void doAction(Context context) {

				Toast.makeText(context, "Coming soon...", Toast.LENGTH_SHORT).show();

			}
		};

		return icons;
	}

}
