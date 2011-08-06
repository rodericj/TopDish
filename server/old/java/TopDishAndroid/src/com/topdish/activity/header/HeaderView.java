package com.topdish.activity.header;

import java.util.Random;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Color;
import android.location.Location;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.widget.AutoCompleteTextView;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.topdish.R;
import com.topdish.TDApp;
import com.topdish.activity.RateDishActivity;
import com.topdish.activity.ResultListActivity;
import com.topdish.comms.HTTPComms;
import com.topdish.comms.ResponseHandler;
import com.topdish.data.SearchAction;
import com.topdish.utils.TDUtils;

/**
 * Header that shows on every page
 * 
 * @author Salil
 * 
 */
public class HeaderView extends LinearLayout {

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = HeaderView.class.getSimpleName();

	/**
	 * Application State
	 */
	final TDApp mAppState;

	/**
	 * The {@link AutoCompleteTextView} for search
	 */
	final public AutoCompleteTextView searchText;

	/**
	 * Screen Width
	 */
	final int screenWidth;

	/**
	 * Screen Height
	 */
	final int screenHeight;

	/**
	 * Offset
	 */
	final int offset = 144;

	/**
	 * Constructor that takes the current {@link Activity}
	 * 
	 * @param context
	 *            - the Activity
	 */
	public HeaderView(final Activity context, final SearchAction action) {
		super(context);

		this.mAppState = (TDApp) context.getApplication();

		setGravity(Gravity.CENTER_VERTICAL);
		setBackgroundDrawable(getResources().getDrawable(R.drawable.topbar));
		setMinimumHeight(80);

		// Constructor the Logo
		final ImageView logo = new ImageView(context);
		logo.setImageDrawable(getResources().getDrawable(R.drawable.stackeddishes));
		logo.setClickable(true);

		// Add the Logo
		addView(logo, 48, 48);

		Display display = ((Activity) context).getWindowManager().getDefaultDisplay();
		screenWidth = display.getWidth();
		screenHeight = display.getHeight();

		searchText = new AutoCompleteTextView(context);

		searchText.setId(new Random().nextInt());
		final String defualtText = "Search for a dish";

		if (this.mAppState.currentSearch.length() > 0)
			this.searchText.setText(this.mAppState.currentSearch);
		else
			this.searchText.setText(defualtText);

		searchText.setTextColor(Color.GRAY);
		searchText.setWidth(screenWidth - offset);
		searchText.setHeight(48);
		searchText.setLines(1);
		searchText.setMaxLines(1);
		searchText.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {

				final String text = searchText.getText().toString();
				if (hasFocus && text.equalsIgnoreCase(defualtText))
					searchText.setText(new String());
				else if (!hasFocus && text.length() == 0)
					searchText.setText(defualtText);

			}
		});

		searchText.setOnKeyListener(new OnKeyListener() {
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				// If the event is a key-down event on the "enter" button
				if ((event.getAction() == KeyEvent.ACTION_DOWN) && (keyCode == KeyEvent.KEYCODE_ENTER)) {
					doSearch(context, action);
					return true;
				}
				return false;
			}
		});

		// TODO: Add ArrayAdapter to the list

		addView(searchText, new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.FILL_PARENT, 1));

		final ImageView searchIcon = new ImageView(context);
		searchIcon.setImageDrawable(getResources().getDrawable(android.R.drawable.ic_menu_search));

		searchIcon.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				doSearch(context, action);
			}
		});

		addView(searchIcon, 48, 48);

		final ImageView addDish = new ImageView(context);
		addDish.setImageDrawable(getResources().getDrawable(android.R.drawable.ic_menu_add));
		addDish.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				context.startActivity(new Intent(context, RateDishActivity.class));
			}
		});

		addView(addDish, 48, 48);

		this.setId(new Random(System.currentTimeMillis()).nextInt());

		Log.d(TAG, "onCreate completed");

	}

	private void doSearch(final Activity context, final SearchAction action) {

		this.mAppState.currentSearch = this.searchText.getText().toString();

		final HTTPComms comms = TDUtils.generateDishSearchComms(context, ResultListActivity.class, this.mAppState, action);

		final Location curLoc = this.mAppState.getCurrentLocation();
		Log.d(HeaderView.class.getSimpleName(), "TEXT: " + searchText.getText().toString());
		if (this.searchText.getText().toString().length() > 0) {
			final ResponseHandler handler = ((ResponseHandler) comms.getHandler());
			handler.progressDiag = new ProgressDialog(context);
			handler.progressDiag.setTitle("Searching for Dishes");
			handler.progressDiag.setMessage("Searching for " + searchText.getText().toString() + "...");
		}

		comms.searchDishes(curLoc.getLatitude(), curLoc.getLongitude(), 1000000, 25, searchText.getText().toString());
		
	}

}
