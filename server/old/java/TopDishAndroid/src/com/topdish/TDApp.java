package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import android.app.Application;
import android.content.Context;
import android.content.res.Configuration;
import android.location.Address;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationManager;
import android.util.Log;
import android.widget.Toast;

import com.topdish.data.Dish;
import com.topdish.data.Restaurant;
import com.topdish.data.Tag;
import com.topdish.utils.ImageLoader;

public class TDApp extends Application {

	/**
	 * DEBUG Tag
	 */
	private static String TAG = TDApp.class.getName();

	/**
	 * Dishes
	 */
	public Map<Long, Dish> dishes = new HashMap<Long, Dish>();

	/**
	 * Restaurants
	 */
	public Map<Integer, Restaurant> restaurants = new HashMap<Integer, Restaurant>();

	/**
	 * Tags
	 */
	public Map<String, Tag> tags = new HashMap<String, Tag>();

	/**
	 * Tags in a Third Dimension
	 */
	public Map<String, Map<String, Tag>> zTags = new HashMap<String, Map<String, Tag>>();

	/**
	 * Current Location
	 */
	public Location currentLocation = null;

	private long timeOfCurLoc = -1;

	public ImageLoader imageLoader;

	/**
	 * Current Search Text
	 */
	public String currentSearch = "";

	public void clearAll() {
		dishes.clear();
		restaurants.clear();
	}

	@Override
	public void onCreate() {
		this.imageLoader = new ImageLoader(getApplicationContext());
		
		Runtime.getRuntime().addShutdownHook(new Thread() {
			@Override
			public void run() {
				imageLoader.clearCache();
			}
		});

		// Get the current location just for good measure
		getCurrentLocation();

		if (zTags.isEmpty()) {

			// Put all Tag Types in Map
			zTags.put(Tag.ALLERGEN_NAME, new HashMap<String, Tag>());
			zTags.put(Tag.CUISINE_NAME, new HashMap<String, Tag>());
			zTags.put(Tag.GENERAL_NAME, new HashMap<String, Tag>());
			zTags.put(Tag.INGREDIENT_NAME, new HashMap<String, Tag>());
			zTags.put(Tag.LIFESTYLE_NAME, new HashMap<String, Tag>());
			zTags.put(Tag.MEALTYPE_NAME, new HashMap<String, Tag>());
			zTags.put(Tag.PRICE_NAME, new HashMap<String, Tag>());
		}
		super.onCreate();
	}

	// public HeaderView getHeader() {
	// return header;
	// }
	//
	// public TDApp setHeader(HeaderView header) {
	// this.header = header;
	// return this;
	// }

	/**
	 * Get the current {@link Location} based on best provider
	 * 
	 * @return the current location
	 */
	public Location getCurrentLocation() {

		if (null == this.currentLocation || this.timeOfCurLoc < 0
				|| System.currentTimeMillis() - this.timeOfCurLoc > (10 * 1000)) {

			this.timeOfCurLoc = System.currentTimeMillis();
			// Get the location service
			LocationManager locMan = (LocationManager) getSystemService(Context.LOCATION_SERVICE);

			// Set choosing criteria
			final Criteria criteria = new Criteria();
			criteria.setAccuracy(Criteria.NO_REQUIREMENT);
			criteria.setPowerRequirement(Criteria.NO_REQUIREMENT);
			criteria.setCostAllowed(false);

			try {
				final String provider = locMan.getBestProvider(criteria, true);

				// Get the current location
				return this.currentLocation = locMan.getLastKnownLocation(provider);
			} catch (Exception e) {
				e.printStackTrace();
				Toast.makeText(this, "Your GPS is disabled. Please enable GPS.", Toast.LENGTH_SHORT).show();

				// Return the default location of SF
				final Location defaultLoc = new Location("");

				defaultLoc.setLatitude(37.77825);
				defaultLoc.setLongitude(-122.42555);

				// Reset timer so any attempts to get Geo will work
				this.timeOfCurLoc = -1;
				return this.currentLocation = defaultLoc;
			}
		} else
			return this.currentLocation;

	}

	/**
	 * Reverse {@link Geocoder} a {@link Location} to an {@link Address}
	 * 
	 * @param curLoc
	 *            - the location
	 * @return the location as a string
	 * @throws Exception
	 */
	public Address convertLocationToAddress(Location curLoc) throws Exception {

		// Locate geocoding
		final Geocoder geocode = new Geocoder(this);
		List<Address> addresses = new ArrayList<Address>();

		try {
			// Get all related addresses
			addresses = geocode.getFromLocation(curLoc.getLatitude(), curLoc.getLongitude(), 1);
		} catch (Exception e) {
			e.printStackTrace();
			final Address addr = getDefaultLocation();
			Log.d(TAG, "Failed to get location, using default: " + addr);
			return addr;
		}

		return (!addresses.isEmpty() ? addresses.get(0) : null);

	}

	/**
	 * Get the {@link Address} from a given Location
	 * 
	 * @param location
	 *            - the string location
	 * @return the address
	 * @throws Exception
	 */
	public Address convertLocationToAddress(String location) {
		// Locate geocoding
		final Geocoder geocode = new Geocoder(this);
		final List<Address> addresses = new ArrayList<Address>();

		// Get all related addresses
		try {
			addresses.addAll(geocode.getFromLocationName(location, 1));
		} catch (IOException e) {
			e.printStackTrace();

			final Address defaultAddr = getDefaultLocation();
			// Add to List
			// addresses.add(getDefaultLocation());
			Log.d(TAG, "Failed to get location, using default: " + defaultAddr);

			return defaultAddr;
		}

		return (!addresses.isEmpty() ? addresses.get(0) : null);
	}

	private Address getDefaultLocation() {
		// Current Address
		final Address addr = new Address(Locale.US);

		// Latitude
		double lat = 37.77477;

		// Longitude
		double lon = -122.41930;

		// Check if current location is in fact known
		// if (null != this.currentLocation) {
		// lat = this.currentLocation.getLatitude();
		// lon = this.currentLocation.getLongitude();
		// }

		// Add the Latitude
		addr.setLatitude(lat);

		// Add the Longitude
		addr.setLongitude(lon);

		// Address Line
		addr.setAddressLine(0, "San Francisco, CA");

		return addr;
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);

	}

}
