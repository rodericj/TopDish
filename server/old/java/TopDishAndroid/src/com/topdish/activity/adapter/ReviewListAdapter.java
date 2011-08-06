package com.topdish.activity.adapter;

import java.util.List;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import com.topdish.TDApp;
import com.topdish.activity.adapter.view.ReviewListView;
import com.topdish.data.Dish;
import com.topdish.data.Review;

public class ReviewListAdapter extends BaseAdapter {

	/**
	 * Current Context
	 */
	Context mContext;

	/**
	 * Current App State
	 */
	TDApp mAppState;

	/**
	 * List of Reviews
	 */
	List<Review> reviews;

	/**
	 * Constructor takes the {@link Dish} ID
	 * 
	 * @param context
	 *            - current {@link Context}
	 * @param dishId
	 *            - current {@link Dish} id
	 */
	public ReviewListAdapter(Context context, long dishId) {
		this(context, ((TDApp) context.getApplicationContext()).dishes
				.get(dishId).reviews);
	}

	/**
	 * Constructor takes the {@link Context} and the {@link Review}
	 * 
	 * @param context
	 *            - current {@link Context}
	 * @param reviews
	 *            - {@link List} of {@link Review}s
	 */
	public ReviewListAdapter(Context context, List<Review> reviews) {

		this.mContext = context;
		this.mAppState = (TDApp) context.getApplicationContext();
		this.reviews = reviews;

	}

	@Override
	public int getCount() {
		return reviews.size();
	}

	@Override
	public Review getItem(int arg0) {
		return this.reviews.get(arg0);
	}

	@Override
	public long getItemId(int arg0) {
		return arg0;
	}

	@Override
	public View getView(int arg0, View arg1, ViewGroup arg2) {
		return new ReviewListView(mContext, getItem(arg0));
	}

}
