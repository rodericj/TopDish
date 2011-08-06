package com.topdish.api.jdo;

import java.util.List;

import com.google.appengine.api.images.ImagesServiceFactory;
import com.topdish.api.util.ConvertToLite;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;

@SuppressWarnings("unused")
public class DishLite{
	private long id;
	private String name;
	private String description;
	private long restaurantID;
	private Double latitude;
	private Double longitude;
	private String restaurantName;
	private Integer posReviews;
	private Integer negReviews;
	private String photoURL;
	private List<ReviewLite> reviews;
	private List<TagLite> tags;

	public DishLite(Dish d) {
		this.id = d.getKey().getId();
		this.name = d.getName();
		this.description = d.getDescription();
		this.restaurantID = d.getRestaurant().getId();
		this.latitude = d.getLocation().getLat();
		this.longitude = d.getLocation().getLon();
		this.restaurantName = d.getRestaurantName();
		this.posReviews = d.getNumPosReviews();
		this.negReviews = d.getNumNegReviews();
		this.photoURL = "";
		this.tags = ConvertToLite.convertTags(TDQueryUtils.getAll(d.getTags(), new Tag()));
		this.reviews = ConvertToLite.convertReviews(TDQueryUtils.getReviewsByDish(d.getKey()));
		
		if (null != d.getPhotos() && !d.getPhotos().isEmpty()) {
			Photo dishPhoto = PMF.get().getPersistenceManager().getObjectById(
					Photo.class, d.getPhotos().get(0));
			this.photoURL = ImagesServiceFactory.getImagesService()
					.getServingUrl(dishPhoto.getBlobKey());
		}
		
		if(this.restaurantName == null)
			this.restaurantName = "";
		if(this.posReviews == null)
			this.posReviews = 0;
		if(this.negReviews == null)
			this.negReviews = 0;
	}
}