package com.topdish.comparator;

import java.util.Comparator;

import com.topdish.jdo.Tag;

public class TagNameComparator implements Comparator<Tag>{

	@Override
	public int compare(Tag t0, Tag t1) {
		if(null != t0 && null != t1){
			return t0.getName().compareTo(t1.getName());
		}
		return 0;
	}
}
