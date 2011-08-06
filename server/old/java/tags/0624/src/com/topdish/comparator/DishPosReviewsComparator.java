package com.topdish.comparator;

import java.util.Comparator;

import com.topdish.jdo.Dish;

/**
 * Class to compare dishes. <br>
 * Note: using Collections.sort() you will get a reverse order (highest reviewed
 * to lowest)
 * 
 */
public class DishPosReviewsComparator implements Comparator<Dish> {
	
	@Override
	public int compare(Dish d1, Dish d2) {
		// TODO: perhaps more than just the positive rating count should be
		// considered in establishing an absolute raking of dishes
		// will return dishes ordered most to least positive reviews
		if (d1 != null && d2 != null) {
			// some old objects will have null values for numNeg and numPos
			int d1Pos = 0;
			int d2Pos = 0;

			if (d1.getNumPosReviews() != null)
				d1Pos = d1.getNumPosReviews();
			if (d2.getNumPosReviews() != null)
				d2Pos = d2.getNumPosReviews();

			if (d1Pos < d2Pos) {
				return 1;
			} else if (d1Pos > d2Pos) {
				return -1;
			} else {
				return 0;
			}
		}
		return 0;
	}
}
