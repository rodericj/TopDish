package com.topdish.api.jdo;

import java.util.HashSet;
import java.util.Set;

import com.google.appengine.api.images.ImagesServiceFactory;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.ConvertToLite;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Tag;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;

/**
 * {@link DishLite} is a utility function to scale down the data in {@link Dish}
 * to make it more managable for the API. Eventually this will be replaced by
 * just {@link Dish}.
 * 
 * @author <a href="mailto:randy@topdish.com">Randy</a> / <a
 *         href="mailto:salil@topdish.com">Salil</a>
 * 
 */
@SuppressWarnings("unused")
public class DishLite {
	private long id;
	private String name;
	private String description;
	private long restaurantID;
	private Double latitude;
	private Double longitude;
	private String restaurantName;
	private String restaurantAddress;
	private String restaurantPhone;
	private Integer posReviews;
	private Integer negReviews;
	private Set<String> photoURL;
	private Set<ReviewLite> reviews;
	private Set<TagLite> tags;

	public DishLite(Dish d) {
		this.id = d.getKey().getId();
		this.name = APIUtils.encode(d.getName());
		this.description = d.getDescription();

		Restaurant restaurant;

		try {
			// Get the restaurant
			restaurant = Datastore.get(d.getRestaurant());
		} catch (Exception e) {
			e.printStackTrace();
			restaurant = null;
		}

		// If not null, populate fields with it
		if (null != restaurant) {
			this.restaurantID = restaurant.getKey().getId();
			this.restaurantName = APIUtils.encode(restaurant.getName());
			this.restaurantPhone = restaurant.getPhone().getNumber();
			this.restaurantAddress = restaurant.getAddressLine1() + " "
					+ restaurant.getAddressLine2() + restaurant.getCity()
					+ ", " + restaurant.getState();
			this.latitude = restaurant.getLatitude();
			this.longitude = restaurant.getLongitude();
		} else {
			// Otherwise use data already in the Dish
			this.restaurantID = d.getRestaurant().getId();
			this.restaurantName = d.getRestaurantName();
			this.latitude = d.getLocation().getLat();
			this.longitude = d.getLocation().getLon();
		}

		this.posReviews = d.getNumPosReviews();
		this.negReviews = d.getNumNegReviews();
		this.photoURL = new HashSet<String>();

		Set<Tag> tagsToAdd = Datastore.get(d.getTags());
		this.tags = ConvertToLite.convertTags(tagsToAdd);
		this.reviews = ConvertToLite.convertReviews(TDQueryUtils
				.getReviewsByDish(d.getKey()));

		// Pull the photos
		if (null != d.getPhotos() && !d.getPhotos().isEmpty()) {
			Set<Photo> photos = Datastore.get(d.getPhotos());

			// Store them to an array
			for (final Photo photo : photos) {
				try {
					this.photoURL.add(ImagesServiceFactory.getImagesService()
							.getServingUrl(photo.getBlobKey()));
				} catch (Exception e) {
					e.printStackTrace();
					// Skip this photo if it is bad
				}
			}
		}

		if (this.restaurantName == null)
			this.restaurantName = new String();
		if (this.posReviews == null)
			this.posReviews = 0;
		if (this.negReviews == null)
			this.negReviews = 0;
	}
}