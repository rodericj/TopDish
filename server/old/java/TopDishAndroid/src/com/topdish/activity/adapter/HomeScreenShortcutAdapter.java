package com.topdish.activity.adapter;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.topdish.TDApp;
import com.topdish.data.HomeScreenItem;

public class HomeScreenShortcutAdapter extends BaseAdapter {

	private static final String TAG = HomeScreenShortcutAdapter.class.getSimpleName();

	private Context mContext;

	@SuppressWarnings("unused")
	private TDApp mAppState;

	// private Pair<String, Drawable>[] icons;

	private HomeScreenItem[] icons;

	public HomeScreenShortcutAdapter(Context context, HomeScreenItem[] icons) {
		this.mContext = context;
		this.mAppState = (TDApp) context.getApplicationContext();

		this.icons = icons;

	}

	@Override
	public int getCount() {
		return icons.length;
	}

	@Override
	public HomeScreenItem getItem(int position) {
		Log.d(TAG, "Position: " + position);
		return icons[position];
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		TextView tv;
		final HomeScreenItem data = getItem(position);

		if (convertView == null) {

			tv = new TextView(this.mContext);
			tv.setGravity(Gravity.CENTER);

		} else {
			tv = (TextView) convertView;
		}

		CharSequence title = data.title;
		Drawable icon = data.icon;

		tv.setCompoundDrawablesWithIntrinsicBounds(null, icon, null, null);
		tv.setText(title);
		tv.setTag(data);

		return tv;
	}

}