package com.topdish.activity.adapter.view;

import android.R;
import android.app.Application;
import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.Gravity;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.topdish.TDApp;
import com.topdish.data.Review;

public class ReviewListView extends LinearLayout {

	private static final String TAG = ReviewListView.class.getSimpleName();

	/**
	 * Current {@link Review}
	 */
	Review mReview;

	/**
	 * Current {@link Context}
	 */
	Context mContext;

	/**
	 * Current {@link Application} state of {@link TDApp}
	 */
	TDApp mAppState;

	/**
	 * Constructor to take current {@link Context} and current {@link Review}
	 * 
	 * @param context
	 *            - the current {@link Context}
	 * @param review
	 *            - the current {@link Review}
	 */
	public ReviewListView(Context context, Review review) {
		super(context);

		this.mContext = context;
		this.mAppState = (TDApp) mContext.getApplicationContext();

		this.mReview = review;

		Log.d(TAG, "Adding Review by " + mReview.creator + " in the " + mReview.direction
				+ " direction with the comment " + mReview.comment + " on "
				+ mReview.dateCreated.toLocaleString());

		final LinearLayout ll = new LinearLayout(mContext);
		ll.setOrientation(LinearLayout.VERTICAL);

		final LinearLayout userImg = new LinearLayout(mContext);
		userImg.setOrientation(LinearLayout.HORIZONTAL);

		final TextView userName = new TextView(mContext);
		userName.setText(mReview.creator);
		userName.setTextColor(Color.parseColor("#AFDCEC"));
		userName.setTextSize(16);

		userImg.addView(userName, new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT, 1));

		final ImageView iv = new ImageView(mContext);
		if (mReview.direction > 0)
			iv.setImageDrawable(getResources().getDrawable(R.drawable.ic_input_add));
		else
			iv.setImageDrawable(getResources().getDrawable(com.topdish.R.drawable.redx));

		// userImg.addView(iv, new LinearLayout.LayoutParams(
		// LinearLayout.LayoutParams.WRAP_CONTENT,
		// LinearLayout.LayoutParams.WRAP_CONTENT, 1));
		userImg.addView(iv);

		ll.addView(userImg, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,
				LinearLayout.LayoutParams.WRAP_CONTENT));

		final TextView comment = new TextView(mContext);
		comment.setText(mReview.comment);
		comment.setTextColor(Color.WHITE);
		comment.setTextSize(new Float(14));

		ll.addView(comment, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,
				LinearLayout.LayoutParams.WRAP_CONTENT));

		final TextView date = new TextView(mContext);
		date.setText(mReview.dateCreated.toLocaleString());
		date.setTextSize(8);
		date.setGravity(Gravity.RIGHT);

		ll.addView(date);

		addView(ll, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,
				LinearLayout.LayoutParams.FILL_PARENT));

		// addView(date);

	}

}
