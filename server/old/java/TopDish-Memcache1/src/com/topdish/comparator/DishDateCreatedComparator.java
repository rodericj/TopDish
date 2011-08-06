package com.topdish.comparator;

import java.util.Comparator;

import com.topdish.jdo.Dish;

public class DishDateCreatedComparator implements Comparator<Dish>{
	public int compare(Dish d1, Dish d2) {
		//will return dishes ordered newest to oldest
		if(d1.getDateCreated().before(d2.getDateCreated())){
			return 1;
		}else if(d1.getDateCreated().after(d2.getDateCreated())){
			return -1;
		}else{
			return 0;
		}
	}
}
