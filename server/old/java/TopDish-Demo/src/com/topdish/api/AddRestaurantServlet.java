package com.topdish.api;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;

import javax.jdo.PersistenceManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.google.appengine.repackaged.org.json.JSONObject;
import com.google.code.geocoder.GeocodeResponse;
import com.google.code.geocoder.Geocoder;
import com.google.code.geocoder.GeocoderRequest;
import com.google.code.geocoder.GeocoderResult;
import com.google.code.geocoder.LatLng;
import com.topdish.jdo.Restaurant;
import com.topdish.util.PMF;

/**
 * Servlet to Upload new Restaurants
 * 
 * @author Salil
 * 
 */
public class AddRestaurantServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -4945276014841647846L;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		PersistenceManager pm = PMF.get().getPersistenceManager();

		String json = req.getParameter("json");

		if (null != json) {

			try {
				final JSONObject rest = new JSONObject(json);
				String name = rest.getString("name");
				String addressLine1 = rest.getString("addressLine1");
				String addressLine2 = rest.getString("addressLine2");
				String city = rest.getString("city");
				String state = rest.getString("state");
				String neighborhood = rest.getString("neighborhood");
				String phoneS = rest.getString("phone");
				PhoneNumber phone = new PhoneNumber(phoneS);
				String urlS = rest.getString("url");
				Link url = new Link(urlS);
				Key creator = null;
				String gid = "";
				
				double latitude = 0.0;
				double longitude = 0.0;
				
				// Instaitate the GeoCoder
				final Geocoder geocoder = new Geocoder();

				// Do a look up for the given address
				final GeocodeResponse result = geocoder.geocode(new GeocoderRequest(
						addressLine1 + " " + addressLine2));

				// Check Emtpy Results
				if (null != result && !result.getResults().isEmpty()) {

					// Get the current result
					final GeocoderResult curResult = result.getResults().get(0);
					// Pull out lat and long
					final LatLng geo = curResult.getGeometry().getLocation();

					latitude = geo.getLat().doubleValue();
					longitude = geo.getLng().doubleValue();
				}
				
				Restaurant toUpload = new Restaurant(name, addressLine1,
						addressLine2, city, state, neighborhood, latitude,
						longitude, phone, gid, url, new Date(), creator);
				PrintWriter pw = new PrintWriter(resp.getOutputStream());
				pw.write(String.valueOf(pm.makePersistent(toUpload).getKey()));
				pw.close();

			} catch (Exception e) {
				e.printStackTrace();
			}

		}

	}
}
