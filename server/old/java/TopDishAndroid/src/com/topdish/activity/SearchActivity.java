package com.topdish.activity;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONObject;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.location.Address;
import android.os.Bundle;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.topdish.R;
import com.topdish.TDApp;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.DishConstants;
import com.topdish.comms.HTTPComms;
import com.topdish.comms.ResponseHandler;
import com.topdish.data.Tag;
import com.topdish.utils.DishUtils;

/**
 * Search Activity for typing in a search and location
 * 
 * @author Salil
 * 
 */
public class SearchActivity extends Activity {

	/**
	 * Debug Tag
	 */
	private static final String TAG = SearchActivity.class.getName();

	/**
	 * Search Edit Text Box
	 */
	private AutoCompleteTextView searchEdit;

	/**
	 * Location Edit Text Box
	 */
	private EditText locationEdit;

	/**
	 * Submit Button
	 */
	private Button submitButton;

	/**
	 * Current App State
	 */
	private TDApp mAppState;

	/**
	 * Default text for Search Edit Text Box
	 */
	private static final String DEFAULT_SEARCH_TEXT = "Search Terms";

	/**
	 * Default text for Location Edit Text Box
	 */
	private static final String DEFAULT_LOCATION_TEXT = "San Francisco, CA";

	/**
	 * Current Address
	 */
	private String addressText = null;

	// /**
	// * Current Location
	// */
	// private Location currentLocation = null;

	/**
	 * Current Address
	 */
	private Address address = null;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);

		// Get the current App State
		mAppState = (TDApp) getApplication();

		// Set the content view
		setContentView(R.layout.search_diag);

		// Get the search Edit Text Box
		searchEdit = (AutoCompleteTextView) findViewById(R.id.searchValue);
		setSearchEditAdapter();
		buildSearchEditOnFocusListener();

		addressText = null;

		// Get the location Edit Text Box
		locationEdit = (EditText) findViewById(R.id.locationValue);
		buildLocationEditOnFocusListener();

		// Set up the submit button
		submitButton = (Button) findViewById(R.id.submitSearch);
		setSubmitButtonFocus();
		buildSubmitButtonOnClickListener();

		updateLocation();

	}

	/**
	 * Builds the on click listener to clear the text when clicked
	 */
	private void buildSearchEditOnFocusListener() {
		searchEdit.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {
				if (hasFocus && searchEdit.getText().toString().equals(DEFAULT_SEARCH_TEXT))
					searchEdit.setText(new String());
				else if (!hasFocus && searchEdit.getText().toString().equals(""))
					searchEdit.setText(DEFAULT_SEARCH_TEXT);

			}
		});
	}

	/**
	 * Create and Set the adapter for auto complete
	 */
	private void setSearchEditAdapter() {

		// Create keys for auto complete
		final List<String> keys = new ArrayList<String>();
		keys.addAll(mAppState.zTags.get(Tag.CUISINE_NAME).keySet());
		keys.addAll(mAppState.zTags.get(Tag.GENERAL_NAME).keySet());
		keys.addAll(mAppState.zTags.get(Tag.INGREDIENT_NAME).keySet());
		keys.addAll(mAppState.zTags.get(Tag.LIFESTYLE_NAME).keySet());
		keys.addAll(mAppState.zTags.get(Tag.MEALTYPE_NAME).keySet());

		searchEdit.setAdapter(new ArrayAdapter<String>(this,
				android.R.layout.simple_dropdown_item_1line, keys));
	}

	private void buildLocationEditOnFocusListener() {
		locationEdit.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {
				if (hasFocus && locationEdit.getText().toString().equals(DEFAULT_LOCATION_TEXT))
					locationEdit.setText(new String());
				else if (!hasFocus && locationEdit.getText().toString().equals(""))
					updateLocation();

			}
		});
	}

	/**
	 * Update the Location Edit Text Box
	 */
	private void updateLocation() {
		try {

			// Check if address is already known
			if (null != addressText && addressText.length() > 0)
				locationEdit.setText(addressText);
			else {

				// The current location
				if (null != (mAppState.getCurrentLocation())) {

					// Address
					address = mAppState.convertLocationToAddress(mAppState.currentLocation);
					final StringBuilder strBuilder = new StringBuilder();
					for (int i = 0; i < address.getMaxAddressLineIndex(); i++)
						strBuilder.append(address.getAddressLine(i) + " ");

					Log.d(TAG, "Cur loc: " + locationEdit);

					// Check address length and set to text
					if (strBuilder.length() > 0) {
						addressText = strBuilder.toString();
						locationEdit.setText(addressText);
					}
					// else
					// // Convert to default text
					// locationEdit.setText(DEFAULT_LOCATION_TEXT);
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Handle requesting focus
	 */
	public void setSubmitButtonFocus() {
		submitButton.setFocusableInTouchMode(true);
		submitButton.setFocusable(true);
		submitButton.requestFocus();

		// searchEdit.requestFocus();

	}

	/**
	 * Create the OnClickListener for the Submit Button
	 */
	public void buildSubmitButtonOnClickListener() {

		submitButton.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				HTTPComms comms = new HTTPComms(new ResponseHandler() {

					/**
					 * Diag to display getting search results
					 */
					ProgressDialog diag;

					@Override
					public void doStart(Message msg) {

						// Construct the message to display
						final StringBuilder message = new StringBuilder();
						message.append("Searching for ");
						if (searchEdit.getText().toString().length() == 0
								|| searchEdit.getText().toString().trim().equals(
										DEFAULT_SEARCH_TEXT))
							message.append("all dishes");
						else
							message.append(searchEdit.getText().toString());

						message.append(" near "
								+ ((null != addressText && addressText.length() > 0
										&& !addressText.equalsIgnoreCase("null") ? addressText
										: DEFAULT_LOCATION_TEXT)));

						diag = ProgressDialog.show(SearchActivity.this, "Searching for Dishes",
								message.toString());
					}

					@Override
					public void doSuccess(Message msg) {
						try {
							final JSONObject resultObject = new JSONObject(String.valueOf(msg.obj));
							if (HTTPComms.checkError(resultObject.getInt(APIConstants.RETURN_CODE))) {
								mAppState.dishes.putAll(DishUtils
										.convertJSONArrayToDishArray(resultObject
												.getJSONArray(DishConstants.DISHES)));
								Log.d(TAG, "Added " + mAppState.dishes.size() + " dishes.");

								// Send off to Results
								Intent intent = new Intent(SearchActivity.this,
										ResultListActivity.class);
								startActivity(intent);
								finish();
							} else
								Toast.makeText(SearchActivity.this, "No Dishes Found",
										Toast.LENGTH_LONG).show();

						} catch (Exception e) {
							e.printStackTrace();
						}
						diag.dismiss();

					}

					@Override
					public void doError(Message msg) {
						diag.dismiss();
					}
				});

				// Default Lat and Longitude
				double lat = 37.77501;
				double lon = -122.41922;

				// If we dont have the current location reverse geo the address
				if (null == mAppState.currentLocation) {
					address = mAppState.convertLocationToAddress(locationEdit.getText().toString());
					lat = address.getLatitude();
					lon = address.getLongitude();
				} else {
					lat = mAppState.currentLocation.getLatitude();
					lon = mAppState.currentLocation.getLongitude();
				}

				// if (searchEdit.getText().toString().trim().equals(
				// DEFAULT_SEARCH_TEXT)) {
				// searchEdit.setText(new String());
				// }

				// Do the search
				comms.searchDishes(lat, lon, 1000000, 25, (!searchEdit.getText().toString().trim()
						.equals(DEFAULT_SEARCH_TEXT) ? searchEdit.getText().toString()
						: new String()));

			}
		});
	}
}
