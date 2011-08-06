package com.topdish.activity.overlays;

import android.content.Context;

import com.google.android.maps.MapView;
import com.google.android.maps.MyLocationOverlay;

public class CurrentLocationOverlay extends MyLocationOverlay {

	private Context context;

	private MapView mapView;

	public CurrentLocationOverlay(Context context, MapView mapView) {
		super(context, mapView);
		this.mapView = mapView;
		this.context = context;
	}

}
