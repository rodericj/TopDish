package com.topdish.data.comparator;

import java.util.Comparator;

import com.topdish.data.Tag;

public class TagRelevanceComparator implements Comparator<Tag> {

	/**
	 * Current instance of {@link TagRelevanceComparator}
	 */
	private static TagRelevanceComparator curInstance;

	/**
	 * Get {@link #curInstance} {@link TagRelevanceComparator}
	 * 
	 * @return the {@link #curInstance}
	 */
	public static TagRelevanceComparator getInstace() {
		return (null == curInstance ? curInstance = new TagRelevanceComparator() : curInstance);
	}

	@Override
	public int compare(Tag a, Tag b) {

		if (a.type.equals(Tag.MEALTYPE_NAME))
			return -1;
		else if (b.type.equals(Tag.MEALTYPE_NAME))
			return 1;
		else if(a.type.equals(Tag.CUISINE_NAME))
			return -1;
		else if(a.type.equals(Tag.PRICE_NAME))
			return 1;
		else
			return 0;
	}

}
