package com.topdish.api.jdo;

import java.util.HashSet;
import java.util.Set;

import com.google.appengine.api.images.ImagesServiceFactory;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.ConvertToLite;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;

@SuppressWarnings("unused")
public class RestaurantLite {
	private Long id;
	private String name;
	private String addressLine1;
	private String addressLine2;
	private String city;
	private String state;
	private String neighborhood;
	private Double latitude;
	private Double longitude;
	private String phone;
	private Integer numDishes;
	private Set<String> photoURL;
	private Set<DishLite> dishes;

	public RestaurantLite(Restaurant rest) {

		this.id = rest.getKey().getId();
		this.name = APIUtils.encode(rest.getName());
		this.addressLine1 = rest.getAddressLine1();
		this.addressLine2 = rest.getAddressLine2();
		this.city = rest.getCity();
		this.state = rest.getState();
		this.neighborhood = rest.getNeighborhood();
		this.latitude = rest.getLatitude();
		this.longitude = rest.getLongitude();
		this.phone = rest.getPhone().getNumber();
		this.numDishes = rest.getNumDishes();
		Set<Dish> dishesToAdd = TDQueryUtils.getDishesByRestaurant(rest
				.getKey());
		this.dishes = ConvertToLite.convertDishes(dishesToAdd);
		this.photoURL = new HashSet<String>();

		// Pull the photos
		if (null != rest.getPhotos() && !rest.getPhotos().isEmpty()) {
			Set<Photo> photos = Datastore.get(rest.getPhotos());

			// Store them to an array
			for (final Photo photo : photos) {
				try {
					this.photoURL.add(ImagesServiceFactory.getImagesService()
							.getServingUrl(photo.getBlobKey()));
				} catch (Exception e) {
					e.printStackTrace();
					// Ignore bad photo
				}
			}
		}
	}
}
