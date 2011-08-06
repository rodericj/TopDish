package com.topdish.activity;

import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Gravity;
import android.view.Window;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.google.gson.Gson;
import com.topdish.R;
import com.topdish.TDApp;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.TagConstants;
import com.topdish.comms.HTTPComms;
import com.topdish.comms.ResponseHandler;
import com.topdish.data.Tag;

/**
 * Splash Activity
 * 
 * @author Salil
 * 
 */
public class Splash extends Activity {

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = Splash.class.getSimpleName();

	/**
	 * Total time to show splash page
	 */
	private final int SPLASH_DISPLAY_LENGTH = 1000;

	/**
	 * Comms to get initial data
	 */
	private HTTPComms comms;

	/**
	 * Current Application State
	 */
	private TDApp mAppState;

	@Override
	public void onCreate(Bundle icicle) {
		super.onCreate(icicle);
		requestWindowFeature(Window.FEATURE_NO_TITLE);

		// Get the application
		mAppState = (TDApp) getApplication();
		
		// Default Case
		final Intent intent = new Intent(Splash.this, LandingActivity.class);

		// Handle incoming intent
		Intent incoming = null;
		if (null != (incoming = getIntent()) && incoming.getAction().equals(Intent.ACTION_SEND)) {

			intent.setClass(Splash.this, RateDishActivity.class);
			intent.setData(incoming.getData());

		}

		// Linear Layout to organize splash screen
		final LinearLayout ll = new LinearLayout(this);
		ll.setOrientation(LinearLayout.VERTICAL);

		// Create progress bar for downloading initial data
		final ProgressBar bar = new ProgressBar(this);
		bar.setVisibility(ProgressBar.INVISIBLE);

		// Construct Image View
		final ImageView iv = new ImageView(this);

		// Get the drawable
		final Drawable drawable = getResources().getDrawable(R.drawable.logobig);

		// Set the Drawable
		iv.setImageDrawable(drawable);
		
		// Define height / width
		iv.setMaxHeight(drawable.getMinimumHeight());
		iv.setMaxWidth(drawable.getMinimumWidth());

		// Add Image View
		ll.addView(iv);

		// Add Bar View
		ll.addView(bar, 30, 30);

		// Center both
		ll.setHorizontalGravity(Gravity.CENTER_HORIZONTAL);

		// Set the content view
		setContentView(ll);

		// Get init data
		comms = new HTTPComms(new ResponseHandler() {

			@Override
			public void doSuccess(Message msg) {
				try {
					// Get JSON
					final String jsonStr = (String) msg.obj;

					// Get the Wrapper
					final JSONObject jsonObj = new JSONObject(jsonStr);

					if (HTTPComms.checkError(jsonObj.getInt(APIConstants.RETURN_CODE))) {

						// Convert to Array
						final JSONArray jsonArry = jsonObj.getJSONArray(TagConstants.TAGS);

						// Traverse Array
						for (int i = 0; i < jsonArry.length(); i++) {

							// Conver to Tag Object
							final Tag curTag = new Gson().fromJson(jsonArry.getJSONObject(i).toString(), Tag.class);

							// Store in map of all tags
							mAppState.tags.put(curTag.name, curTag);

							// Store in 3D Map
							mAppState.zTags.get(curTag.type.trim()).put(curTag.name, curTag);

						}

						Log.d(TAG, "Total Tags: " + mAppState.tags.size());
						Log.d(TAG, "Tags: " + mAppState.tags.keySet());
					} else
						doError(Message.obtain(this, HTTPComms.ERROR, new Exception(jsonObj
								.getString(APIConstants.RETURN_MESSAGE))));

				} catch (Exception e) {
					e.printStackTrace();
				}

				moveOn(intent);
			}

			@Override
			public void doStart(Message msg) {

			}

			@Override
			public void doError(Message msg) {
				Toast.makeText(Splash.this, "Error: " + ((Exception) msg.obj).getMessage(), Toast.LENGTH_SHORT).show();

				moveOn(intent);

			}
		});

		// Handler to post delay the move action
		new Handler().postDelayed(new Runnable() {
			@Override
			public void run() {

				bar.setVisibility(ProgressBar.VISIBLE);
				comms.mobileInit();

			}
		}, SPLASH_DISPLAY_LENGTH);
	}

	private void moveOn(Intent intent) {

		// Get the latest location
		mAppState.getCurrentLocation();

		// Start the activity
		Splash.this.startActivity(intent);

		// Finish the splash activity

		Splash.this.finish();

	}

	/**
	 * Moves on in case of a crash, etc
	 */
	// private void moveOn() {
	// // Get the latest location
	// mAppState.getCurrentLocation();
	//
	// // Intent to be run
	// final Intent mainIntent = new Intent(Splash.this, LandingActivity.class);
	//
	// // Start the activity
	// Splash.this.startActivity(mainIntent);
	//
	// // Finish the splash activity
	//
	// Splash.this.finish();
	// }
}