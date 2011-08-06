package com.topdish.activity.adapter;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Gallery;
import android.widget.ImageView;

import com.topdish.R;
import com.topdish.comms.HTTPComms;
import com.topdish.comms.ResponseHandler;
import com.topdish.data.Dish;

public class DishPhotoAdapter extends BaseAdapter {

	private static final String TAG = DishPhotoAdapter.class.getSimpleName();

	private static int IMAGE_SIZE = 256;

	private final Dish mDish;

	private final Context mContext;

	int mGalleryItemBackground = 0;

	public DishPhotoAdapter(Context context, Dish dish) {
		this.mContext = context;
		this.mDish = dish;

		TypedArray a = context.obtainStyledAttributes(R.styleable.HelloGallery);
		this.mGalleryItemBackground = a.getResourceId(R.styleable.HelloGallery_android_galleryItemBackground, 0);
		a.recycle();
	}

	@Override
	public int getCount() {
		return this.mDish.photoURL.size();
	}

	@Override
	public String getItem(int position) {
		return this.mDish.photoURL.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	private static class ViewHolder {
		public ImageView iv;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		final ViewHolder holder = (null == convertView ? new ViewHolder() : ((ViewHolder) convertView.getTag()));

		final String curPhotoURL = getItem(position);

		// Create new Image View layout
		if (null == convertView) {

			holder.iv = new ImageView(this.mContext);
			holder.iv.setLayoutParams(new Gallery.LayoutParams(IMAGE_SIZE + 25, IMAGE_SIZE + 25));
			holder.iv.setScaleType(ImageView.ScaleType.FIT_CENTER);
			holder.iv.setBackgroundResource(this.mGalleryItemBackground);

			convertView = holder.iv;
			convertView.setTag(holder);

		} else
			convertView = holder.iv;

		if (mDish.photos.containsKey(curPhotoURL)) {
			holder.iv.setImageDrawable(mDish.photos.get(curPhotoURL));
		} else {
			holder.iv.setImageResource(com.topdish.R.drawable.nodishimg);

			// Get the current image
			new HTTPComms(new ResponseHandler() {

				@Override
				public void doSuccess(Message msg) {
					final Bitmap photo = (Bitmap) msg.obj;
					mDish.photos.put(curPhotoURL, new BitmapDrawable(photo));
					mDish.photo = photo;
					Log.d(TAG, "Adding image for : " + mDish.name);
					// Set the IV to the current Dish's Photo
					holder.iv.setImageDrawable(new BitmapDrawable(mDish.photo));
					holder.iv.refreshDrawableState();
				}

				@Override
				public void doStart(Message msg) {
				}

				@Override
				public void doError(Message msg) {
				}
			}).getImage(curPhotoURL.startsWith("http") ? curPhotoURL : HTTPComms.BASE_URL + curPhotoURL + "=s"
					+ IMAGE_SIZE);
		}
		return convertView;
	}
}
