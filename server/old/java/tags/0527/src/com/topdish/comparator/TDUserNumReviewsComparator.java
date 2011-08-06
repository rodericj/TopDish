package com.topdish.comparator;

import java.util.Comparator;

import com.topdish.jdo.TDUser;

public class TDUserNumReviewsComparator implements Comparator<TDUser> {
	public int compare(TDUser u1, TDUser u2) {
		//will return users with most to least reviews
		int u1Num = 0;
		int u2Num = 0;
		
		if(null != u1.getNumReviews())
			u1Num = u1.getNumReviews();
		if(null != u2.getNumReviews())
			u2Num = u2.getNumReviews();
		
		if(u1Num < u2Num){
			return 1;
		}else if(u1Num > u2Num){
			return -1;
		}else{
			return 0;
		}
	}
}
