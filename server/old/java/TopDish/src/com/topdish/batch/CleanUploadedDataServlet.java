package com.topdish.batch;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.beoui.geocell.model.Point;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDPoint;
import com.topdish.util.Datastore;
import com.topdish.util.GeoUtils;
import com.topdish.util.TDQueryUtils;

public class CleanUploadedDataServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -4772390438363914687L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		PrintWriter pw = resp.getWriter();

		// Default Point
		final Point defaultPt = GeoUtils.defaultTDPoint();

		pw.write("Defualt: ");
		pw.write("\tLat: " + defaultPt.getLat());
		pw.write("\tLon: " + defaultPt.getLon());

		// List of dishes within 1000m of the default location
		final List<Dish> dishes = TDQueryUtils.searchGeoItems(defaultPt, 1000,
				1000, new Dish());

		if (null != dishes) {

			pw
					.write("\nTotal Size of Dishes Returned: " + dishes.size()
							+ "\n");

			// Traverse dishes
			for (final Dish dish : dishes) {

				pw.write("Working on dish " + dish.getKeyString() + " "
						+ dish.getName() + "\n");

				// Get the Restaurant
				final Restaurant rest = Datastore.get(dish.getRestaurant());

				pw.write("\tLat Before: " + rest.getLatitude());
				pw.write("\n\tLon Before: " + rest.getLongitude() + "\n");

				if (rest.getLatitude() == defaultPt.getLat()
						&& rest.getLongitude() == defaultPt.getLon()) {

					// Retry the reverse geo coding
					TDPoint reverseGeo = GeoUtils.reverseAddress(rest
							.getAddressLine1()
							+ " " + rest.getAddressLine2(), rest.getCity(),
							rest.getState());

					// Check that it found a new address
					if (defaultPt.getLat() == reverseGeo.getLat()
							&& defaultPt.getLon() == reverseGeo.getLon()) {
						pw.write("\tFailed to regeocoded: "
								+ dish.getKeyString() + " " + dish.getName()
								+ " at " + rest.getName() + "\t"
								+ rest.getAddressLine1() + " "
								+ rest.getAddressLine2() + " " + rest.getCity()
								+ " " + rest.getState() + "\n");
					} else {
						pw.write("\tLat After: " + reverseGeo.getLat() + "\n");
						pw.write("\tLon After: " + reverseGeo.getLon() + "\n");
						pw.write("\tSuccessfully regeocoded: "
								+ dish.getKeyString() + " " + dish.getName()
								+ "\n");

						rest.setLocation(reverseGeo.getLat(), reverseGeo
								.getLon());
						Datastore.put(rest);
						dish.setLocation(reverseGeo.getLat(), reverseGeo.getLon());
						Datastore.put(dish);
					}

				}

			}
		}

		pw.flush();
		pw.close();

	}
}
