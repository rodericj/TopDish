package com.topdish.comparator;

import java.util.Comparator;

import com.topdish.jdo.Restaurant;

public class RestaurantPosReviewsComparator implements Comparator<Restaurant>{
	public int compare(Restaurant r1, Restaurant r2) {
		if(r1 != null && r2 != null){
			int r1Pos = 0;
			int r2Pos = 0;
			
			if(r1.getNumPosReviews() != null)
				r1Pos = r1.getNumPosReviews();
			if(r2.getNumPosReviews() != null)
				r2Pos = r2.getNumPosReviews();
			
			if(r1Pos < r2Pos){
				return 1;
			}else if(r1Pos > r2Pos){
				return -1;
			}else{
				return 0;
			}
		}
		return 0;
	}
}
