package com.topdish.activity;

import java.util.List;

import org.json.JSONObject;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.os.Bundle;
import android.os.Message;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.MyLocationOverlay;
import com.google.android.maps.Overlay;
import com.topdish.R;
import com.topdish.TDApp;
import com.topdish.activity.header.HeaderView;
import com.topdish.activity.overlays.DishOverlay;
import com.topdish.activity.overlays.impl.DishOverlayItem;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.DishConstants;
import com.topdish.comms.HTTPComms;
import com.topdish.comms.ResponseHandler;
import com.topdish.data.Dish;
import com.topdish.data.SearchAction;
import com.topdish.utils.DishUtils;

/**
 * Search Map for Dishes
 * 
 * @author Salil
 * 
 */
public class SearchMapActivity extends MapActivity {

	/**
	 * DEBUG Tag
	 */
	private static String TAG = "SearchMapActivity";

	/**
	 * Application State
	 */
	private TDApp mAppState;

	/**
	 * Map View
	 */
	private MapView mapView;

	/**
	 * Map Controller
	 */
	private MapController mapController;

	/**
	 * Overlays attached to the Map View
	 */
	private List<Overlay> mapOverlays;

	/**
	 * Current Location Overlay
	 */
	private MyLocationOverlay myLocOverlay;

	/**
	 * Dish Overlay
	 */
	private DishOverlay dishOverlay;

	/**
	 * HTTP Communication with Server
	 */
	private HTTPComms comms;

	/**
	 * Progress Dialog for blocking during searches
	 */
	private ProgressBar progressBar;

	/**
	 * Asynchronous response handler
	 */
	private ResponseHandler response = new ResponseHandler() {

		@Override
		public void doSuccess(Message msg) {
			Log.d(TAG, "Search Successful");
			try {
				final JSONObject resultObject = new JSONObject(String.valueOf(msg.obj));
				if (HTTPComms.checkError(resultObject.getInt(APIConstants.RETURN_CODE))) {
					mAppState.dishes.putAll(DishUtils.convertJSONArrayToDishArray(resultObject
							.getJSONArray(DishConstants.DISHES)));
					Log.d(TAG, "Added " + mAppState.dishes.size() + " dishes.");

					placeDishes();

				} else
					Toast.makeText(SearchMapActivity.this, "No Dishes Found", Toast.LENGTH_LONG).show();
			} catch (Exception e) {
				e.printStackTrace();
			}

			placeDishes();

			// progressBar.setVisibility(ProgressBar.INVISIBLE);
			changeProgressVisibility(ProgressBar.INVISIBLE);

		}

		@Override
		public void doStart(Message msg) {
			Log.d(TAG, "Started Search");

			// progressBar.setVisibility(ProgressBar.VISIBLE);
			changeProgressVisibility(ProgressBar.VISIBLE);

		}

		@Override
		public void doError(Message msg) {
			Log.d(TAG, "ERROR: " + ((Exception) msg.obj).getMessage());

			try {
				// progressBar.setVisibility(ProgressBar.INVISIBLE);
				changeProgressVisibility(ProgressBar.INVISIBLE);
			} catch (Exception e) {
			}

		}
	};

	/**
	 * A <code>synchronized</code> method to change the visibility of the
	 * {@link #progressBar}
	 * 
	 * @param visibility
	 *            - either {@link ProgressBar}.INVISIBLE or {@link ProgressBar}
	 *            .VISIBLE
	 */
	public synchronized void changeProgressVisibility(int visibility) {
		if (visibility == ProgressBar.INVISIBLE || visibility == ProgressBar.VISIBLE)
			this.progressBar.setVisibility(visibility);
	}

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.map_view);

		LinearLayout ll = (LinearLayout) findViewById(R.id.mainlayout);

		this.mAppState = (TDApp) getApplication();
		this.progressBar = (ProgressBar) findViewById(R.id.lazyLoadBar);

		final SearchAction action = new SearchAction(this) {

			@Override
			public boolean doAction() {

				runOnUiThread(new Runnable() {

					@Override
					public void run() {
						placeDishes();
					}
				});

				return true;
			}
		};

		ll.addView(new HeaderView(this, action), 0);

		comms = new HTTPComms(response);

		mapView = (MapView) findViewById(R.id.mapview);
		mapView.setBuiltInZoomControls(true);

		mapController = mapView.getController();

		mapOverlays = mapView.getOverlays();

		// myLocOverlay = new MyLocationOverlay(this, mapView);
		myLocOverlay = new UserLocation(this, mapView);
		myLocOverlay.enableMyLocation();

		final Drawable drawable = this.getResources().getDrawable(R.drawable.marker);
		dishOverlay = new DishOverlay(drawable, mapView, this.getApplicationContext());
		dishOverlay.setBalloonBottomOffset(drawable.getMinimumHeight() / 2);

		mapOverlays.add(myLocOverlay);
		placeDishes();

	}

	@Override
	protected boolean isRouteDisplayed() {
		return false;
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.map_menu, menu);
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {

		switch (item.getItemId()) {
		case R.id.myloc:
			final GeoPoint localGeo = ((UserLocation) myLocOverlay).geo;
			if (null != localGeo)
				centerMap(localGeo);
			break;
		case R.id.aslist:
			final Intent intent = new Intent(SearchMapActivity.this, ResultListActivity.class);
			startActivity(intent);
			// finish();
			break;

		default:
			break;
		}

		return super.onOptionsItemSelected(item);
	}

	/**
	 * Run a search
	 * 
	 *TODO: Combine with handleChange
	 * 
	 * @param lat
	 * @param lon
	 */
	private void doSearch(double lat, double lon) {
		Log.d(TAG, "Running Search...");
		final int distance = (int) ((Double.valueOf(mapView.getLongitudeSpan()) / Double.valueOf(1E6)) * 111319);
		comms = new HTTPComms(response);
		comms.searchDishes(lat, lon, distance, 25, this.mAppState.currentSearch);

	}

	/**
	 * Place Dishes on Map
	 */
	private void placeDishes() {

		mapOverlays.remove(dishOverlay);
		dishOverlay.clear();

		for (Dish curDish : mAppState.dishes.values()) {
			dishOverlay.addOverlay(new DishOverlayItem(curDish));
		}

		mapOverlays.add(dishOverlay);

		// Forces a redraw
		mapController.animateTo(this.mapView.getMapCenter());
		// mapView.setO

		dishOverlay.populateDishes();
	}

	/**
	 * Inner Class to handle Special Case of Location Changed
	 * 
	 * @author Salil
	 * 
	 */
	public class UserLocation extends MyLocationOverlay {

		/**
		 * Previous Location
		 */
		// Location prevLocation;

		public GeoPoint geo = null;

		/**
		 * Default Constructor
		 * 
		 * @param context
		 * @param mapView
		 */
		public UserLocation(Context context, MapView mapView) {
			super(context, mapView);
		}

		@Override
		public synchronized void onLocationChanged(Location location) {

			if (null == geo) {
				centerMap(geo = new GeoPoint((int) (location.getLatitude() * 1E6),
						(int) (location.getLongitude() * 1E6)));
				doSearch(location.getLatitude(), location.getLongitude());

			}

			super.onLocationChanged(location);
		}

	}

	/**
	 * Center Map on a {@link Location}
	 * 
	 * @param location
	 */
	public void centerMap(Location location) {

		centerMap(new GeoPoint((int) (location.getLatitude() * 1E6), (int) (location.getLongitude() * 1E6)));
	}

	/**
	 * Center map on a {@link GeoPoint}
	 * 
	 * @param geo
	 */
	public void centerMap(GeoPoint geo) {
		mapController.animateTo(geo);
	}

	@Override
	protected void onStart() {
		super.onStart();
		myLocOverlay.enableMyLocation();
	}

	@Override
	protected void onPause() {
		super.onPause();
		myLocOverlay.disableMyLocation();
	}

	@Override
	protected void onResume() {
		super.onResume();
		myLocOverlay.enableMyLocation();
	}

	@Override
	protected void onStop() {
		super.onStop();
		myLocOverlay.disableMyLocation();
	}

}