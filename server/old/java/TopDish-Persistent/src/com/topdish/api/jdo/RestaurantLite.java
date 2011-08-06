package com.topdish.api.jdo;

import java.util.List;

import com.topdish.api.util.ConvertToLite;
import com.topdish.jdo.Restaurant;
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
	private String photoURL;
	private List<DishLite> dishes;
	
	public RestaurantLite(Restaurant rest){
		this.id = rest.getKey().getId();
		this.name = rest.getName();
		this.addressLine1 = rest.getAddressLine1();
		this.addressLine2 = rest.getAddressLine2();
		this.city = rest.getCity();
		this.state = rest.getState();
		this.neighborhood = rest.getNeighborhood();
		this.latitude = rest.getLatitude();
		this.longitude = rest.getLongitude();
		this.phone = rest.getPhone().getNumber();
		this.numDishes = rest.getNumDishes();
		this.dishes = ConvertToLite.convertDishes(TDQueryUtils.getDishesByRestaurant(rest.getKey()));
		this.photoURL = "";		//TODO: get URL for "lead" photo
	}
}
