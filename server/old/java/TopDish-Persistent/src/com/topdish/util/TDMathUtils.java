package com.topdish.util;

import java.text.DecimalFormat;

import com.beoui.geocell.GeocellUtils;
import com.beoui.geocell.model.Point;

public class TDMathUtils {
	public static double geoPtDistanceMiles(double lat1, double lng1, double lat2, double lng2) {
	    return GeocellUtils.distance(new Point(lat1, lng1), new Point(lat2,lng2)) / 1609.344;
	 }
	
	public static double geoPtDistanceMeters(double lat1, double lng1, double lat2, double lng2){
		return GeocellUtils.distance(new Point(lat1, lng1), new Point(lat2,lng2));
	}
	
	public static String formattedGeoPtDistanceMiles(double lat1, double lng1, double lat2, double lng2){
		double dist = geoPtDistanceMiles(lat1,lng1,lat2,lng2);
		DecimalFormat f = new DecimalFormat("#,##0.0");
		
		return f.format(dist);
	}
	
	public static String formattedGeoPtDistanceMiles(Point p1, Point p2){
		double dist = geoPtDistanceMiles(p1.getLat(),p1.getLon(), p2.getLat(), p2.getLon());
		DecimalFormat f = new DecimalFormat("#,##0.0");
		
		return f.format(dist);
	}
}
