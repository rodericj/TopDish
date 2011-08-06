package com.topdish.comparator;

import java.util.Comparator;

import com.topdish.jdo.Tag;

public class TagManualOrderComparator implements Comparator<Tag>{

	@Override
	public int compare(Tag t0, Tag t1) {
		if(null != t0 && null != t1){
			int order0 = 0;
			int order1 = 0;
			
			if(t0.getManualOrder() != null){
				order0 = t0.getManualOrder();
			}
			if(t1.getManualOrder() != null){
				order1 = t1.getManualOrder();
			}
			
			if(order0 < order1){
				return 1;
			}else if(order1 > order0){
				return -1;
			}else{
				return 0;
			}
		}
		return 0;
	}

}
