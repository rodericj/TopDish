package com.topdish.activity;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.AdapterView.OnItemClickListener;

import com.topdish.TDApp;
import com.topdish.activity.adapter.DishArrayAdapter;
import com.topdish.activity.adapter.DishArrayAdapter.ViewHolder;
import com.topdish.activity.header.HeaderView;
import com.topdish.api.util.DishConstants;
import com.topdish.data.Dish;
import com.topdish.data.SearchAction;
import com.topdish.data.comparator.DishPosReviewsComparator;

public class ResultListActivity extends Activity {

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = ResultListActivity.class.getSimpleName();

	/**
	 * Current Application States
	 */
	private TDApp mAppState;

	/**
	 * Dish Adapter
	 */
	private DishArrayAdapter dishAdapter;

	/**
	 * {@link SearchAction} to be completed
	 */
	private SearchAction action;

	/**
	 * {@link List} of {@link Dish}es
	 */
	private List<Dish> curDishes;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);

		// Get the application State
		this.mAppState = (TDApp) getApplication();

		// Create the list and sort it by highest rated
		this.curDishes = new ArrayList<Dish>(this.mAppState.dishes.values());
		Collections.sort(this.curDishes, DishPosReviewsComparator.getInstance());

		this.dishAdapter = new DishArrayAdapter(this, this.curDishes);
		this.dishAdapter.setNotifyOnChange(true);

		final LinearLayout overallLayout = new LinearLayout(this);
		overallLayout.setOrientation(LinearLayout.VERTICAL);

		final ListView lv = new ListView(this);
		lv.setAdapter(this.dishAdapter);

		this.action = new SearchAction(this) {

			@Override
			public boolean doAction() {

				// Refresh the data adapter
				runOnUiThread(new Runnable() {

					@Override
					public void run() {
						curDishes.clear();
						curDishes.addAll(mAppState.dishes.values());
						Collections.sort(curDishes, DishPosReviewsComparator.getInstance());
						dishAdapter.notifyDataSetChanged();
					}
				});

				return true;
			}
		};

		overallLayout.addView(new HeaderView(this, this.action), 0, new LayoutParams(LayoutParams.FILL_PARENT,
				LayoutParams.WRAP_CONTENT));

		lv.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				final Intent intent = new Intent(ResultListActivity.this, DishDetail.class);
				intent.putExtra(DishConstants.DISH_ID, ((ViewHolder) arg1.getTag()).id);
				startActivity(intent);
			}

		});
		overallLayout.addView(lv);

		// Set the content view
		setContentView(overallLayout);

		Log.d(TAG, "OnCreate complete");

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(com.topdish.R.menu.list_menu, menu);
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {

		switch (item.getItemId()) {
		case com.topdish.R.id.viewonmap:
			final Intent intent = new Intent(this, SearchMapActivity.class);
			startActivity(intent);
			break;

		default:
			break;
		}

		return super.onOptionsItemSelected(item);
	}

}
