package com.topdish.activity.overlays;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;
import android.gesture.Gesture;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.GestureDetector.SimpleOnGestureListener;

import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.topdish.activity.DishDetail;
import com.topdish.activity.overlays.impl.DishOverlayItem;
import com.topdish.api.util.DishConstants;
import com.topdish.data.Dish;

public class DishOverlay extends BalloonItemizedOverlay<OverlayItem> {

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = DishOverlay.class.getSimpleName();

	// private Context mContext;

	/**
	 * Overlays
	 */
	private ArrayList<OverlayItem> mOverlays = new ArrayList<OverlayItem>();

	/**
	 * Handles {@link Gesture}s given a {@link DoubleTapGesture}
	 */
	final GestureDetector gestures = new GestureDetector(new DoubleTapGesture());

	/**
	 * Constructor to create an {@link Overlay} of {@link Dish}es
	 * 
	 * @param defaultMarker
	 *            - the default marker {@link Drawable} to show
	 * @param mv
	 *            - current {@link MapView}
	 * @param context
	 *            -current {@link Context}
	 */
	public DishOverlay(Drawable defaultMarker, MapView mv, Context context) {
		super(boundCenterBottom(defaultMarker), mv, context);
		// this.mContext = context;
		populate();
	}

	/**
	 * Add an Overlay
	 * 
	 * @param overlay
	 *            - overlay to add
	 */
	public void addOverlay(OverlayItem overlay) {
		mOverlays.add(overlay);
		populate();
	}
	
	public void populateDishes() {
		populate();
	}
	
	public void clear() {
		mOverlays.clear();
	}

	@Override
	protected OverlayItem createItem(int i) {
		return mOverlays.get(i);
	}

	@Override
	public int size() {
		return mOverlays.size();
	}

	@Override
	public boolean onTouchEvent(MotionEvent event, MapView mapView) {

		Log.d(TAG, "In DISHOVERLAY ON TOUCH EVEN");

		return (this.gestures.onTouchEvent(event) ? true : super.onTouchEvent(event, mapView));

		// return super.onTouchEvent(event, mapView);
	}

	/**
	 * Handles {@link Gesture}s that occur <br>
	 * Note: Specifically built for
	 * {@link SimpleOnGestureListener#onDoubleTap(MotionEvent)} to handle
	 * {@link MapController#zoomInFixing(int, int)} the location the user double
	 * taps
	 * 
	 * @author Salil
	 * 
	 */
	class DoubleTapGesture extends GestureDetector.SimpleOnGestureListener {

		/**
		 * Default constructor
		 */
		public DoubleTapGesture() {
			super();
		}

		@Override
		public boolean onDoubleTap(MotionEvent e) {
			// Zoom on a double tap
			mc.zoomInFixing((int) e.getX(), (int) e.getY());
			Log.d(TAG, "Zooming to " + (int) e.getX() + (int) e.getY());
			return true;
		}

		@Override
		public boolean onSingleTapConfirmed(MotionEvent e) {
			// Do nothing on single click so BalloonOverlay does the work
			return false;
		}

		@Override
		public boolean onSingleTapUp(MotionEvent e) {
			// Do nothing on single click so BalloonOverlay does the work
			return false;
		}

	}

	@Override
	protected boolean onBalloonTap(int index) {
		final long id = ((DishOverlayItem) getItem(index)).mDish.id;
		Log.d(TAG, "Getting Balloon at index " + index + " with id " + id);

		this.mapView.getContext().startActivity(
				new Intent(super.mapView.getContext(), DishDetail.class).putExtra(DishConstants.DISH_ID, id));

		return true;
	}

}
