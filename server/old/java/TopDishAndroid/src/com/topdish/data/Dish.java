package com.topdish.data;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.location.Location;

import com.google.android.maps.GeoPoint;
import com.google.gson.Gson;
import com.topdish.activity.adapter.view.DishListView;
import com.topdish.comms.HTTPComms;
import com.topdish.data.comparator.TagRelevanceComparator;
import com.topdish.utils.TDUtils;

/**
 * Dish Object
 * 
 * @author Salil
 * 
 */
public class Dish {

	/**
	 * Dish ID
	 */
	public long id;

	/**
	 * Name
	 */
	public String name;

	/**
	 * Description
	 */
	public String description;

	/**
	 * Restaurant ID
	 */
	public long restaurantID;

	/**
	 * Latitude
	 */
	public Double latitude;

	/**
	 * Longitude
	 */
	public Double longitude;

	/**
	 * Restaurant Name
	 */
	public String restaurantName;

	/**
	 * Number of positive reviews
	 */
	public Integer posReviews;

	/**
	 * Number of negative reviews
	 */
	public Integer negReviews;

	/**
	 * URL of Photo
	 */
	public List<String> photoURL;

	/**
	 * Map of Photos
	 */
	public Map<String, Drawable> photos = new HashMap<String, Drawable>();

	/**
	 * Photo as {@link Bitmap}
	 */
	public Bitmap photo;

	/**
	 * Thumbnail of Photo as {@link Bitmap}
	 */
	public Bitmap thumbnail;

	/**
	 * List of {@link Review}s
	 */
	public List<Review> reviews;

	/**
	 * List of {@link Tag}s
	 */
	public List<Tag> tags;

	/**
	 * Default Constructor <br>
	 * Note: Required to use {@link Gson}
	 */
	public Dish() {
	}

	/**
	 * @param id
	 * @param name
	 * @param description
	 * @param restaurantID
	 * @param latitude
	 * @param longitude
	 * @param restaurantName
	 * @param posReviews
	 * @param negReviews
	 * @param photoURL
	 * @param reviews
	 * @param tags
	 */
	public Dish(long id, String name, String description, long restaurantID, Double latitude, Double longitude,
			String restaurantName, Integer posReviews, Integer negReviews, List<String> photoURL, List<Review> reviews,
			List<Tag> tags) {
		super();
		this.id = id;
		this.name = TDUtils.stringDecode(name);
		this.description = description;
		this.restaurantID = restaurantID;
		this.latitude = latitude;
		this.longitude = longitude;
		this.restaurantName = TDUtils.stringDecode(restaurantName);
		this.posReviews = posReviews;
		this.negReviews = negReviews;
		this.photoURL = photoURL;
		this.reviews = reviews;
		this.tags = tags;
		Collections.sort(this.tags, TagRelevanceComparator.getInstace());
	}

	/**
	 * Get the {@link GeoPoint} of Dish's Lat and Lon
	 * 
	 * @return Well formed {@link GeoPoint}
	 */
	public GeoPoint getGeoPoint() {
		return new GeoPoint((int) (latitude * 1E6), (int) (longitude * 1E6));
	}

	/**
	 * Get the distance to this dish from a given lat and lon in meters <br>
	 * Note: divide by 1609.344 for miles
	 * 
	 * @param lat
	 *            - from lat
	 * @param lon
	 *            - from lon
	 * @return distance
	 */
	public float distanceToDish(double lat, double lon) {

		final float[] distance = new float[1];

		// Get distance to Dish
		Location.distanceBetween(lat, lon, this.latitude, this.longitude, distance);

		return distance[0];
	}

	/**
	 * Get the URL for the Thumbnail
	 * 
	 * @return the formatted url or null if dish has no photos
	 */
	public String getThumbnailURL() {
		return (!this.photoURL.isEmpty() ? (this.photoURL.get(0).startsWith("http") ? this.photoURL.get(0)
				: HTTPComms.BASE_URL + this.photoURL.get(0) + "=s" + DishListView.IMAGE_SIZE) : null);
	}

	@Override
	public String toString() {
		return "Dish [description=" + description + ", id=" + id + ", latitude=" + latitude + ", longitude="
				+ longitude + ", name=" + name + ", negReviews=" + negReviews + ", photo=" + photo + ", photoURL="
				+ photoURL + ", photos=" + photos + ", posReviews=" + posReviews + ", restaurantID=" + restaurantID
				+ ", restaurantName=" + restaurantName + ", reviews=" + reviews + ", tags=" + tags + ", thumbnail="
				+ thumbnail + "]";
	}

}