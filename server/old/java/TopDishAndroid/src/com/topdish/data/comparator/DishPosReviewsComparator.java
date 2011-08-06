package com.topdish.data.comparator;

import java.util.Comparator;

import com.topdish.data.Dish;

/**
 * Class to compare dishes. <br>
 * Note: using Collections.sort() you will get a reverse order (highest reviewed
 * to lowest)
 * 
 */
public class DishPosReviewsComparator implements Comparator<Dish> {

	/**
	 * Current Instance of {@link DishPosReviewsComparator}
	 */
	private static DishPosReviewsComparator curInstace;

	/**
	 * Get the current instance
	 * 
	 * @return static instance
	 */
	public static DishPosReviewsComparator getInstance() {
		return (null == curInstace ? (curInstace = new DishPosReviewsComparator()) : curInstace);
	}

	@Override
	public int compare(Dish d1, Dish d2) {
		// TODO: perhaps more than just the positive rating count should be
		// considered in establishing an absolute raking of dishes
		// will return dishes ordered most to least positive reviews
		if (d1 != null && d2 != null) {
			// some old objects will have null values for numNeg and numPos
			int d1Pos = 0;
			int d2Pos = 0;

			if (d1.posReviews != null)
				d1Pos = d1.posReviews;
			if (d2.posReviews != null)
				d2Pos = d2.posReviews;

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
