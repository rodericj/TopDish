package com.topdish.batch;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import com.csvreader.CsvReader;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.google.appengine.repackaged.com.google.common.base.Pair;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;
import com.topdish.util.TagUtils;

public class UploadDishRestaurantCSVServlet extends HttpServlet {

	/**
	 * Print or Hide DEBUG Statements
	 */
	private static final boolean DEBUG = true;

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 1675645634L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException, ServletException {

		Key creator;
		ByteArrayInputStream csvIS = null;

		try {
			// Get Creator (NOTE: You should login using info@topdish.com)
			creator = TDUserService.getUser(PMF.get().getPersistenceManager())
					.getKey();
		} catch (UserNotFoundException e) {
			throw new ServletException(e);
		} catch (UserNotLoggedInException e) {
			throw new ServletException(e);
		}

		// Process multipart/form-data
		// Check that we have a file upload request
		boolean isMultipart = ServletFileUpload.isMultipartContent(req);
		if (!isMultipart) {
			throw new ServletException("Only multipart/form-data POST allowed!");
		}

		// Handle file upload
		try {
			ServletFileUpload upload = new ServletFileUpload();
			FileItemIterator iter = upload.getItemIterator(req);

			while (iter.hasNext()) {
				FileItemStream item = iter.next();
				InputStream stream = item.openStream();

				// Process file data - store for later use
				if (!item.isFormField()) {
					byte[] fileCon = new byte[100 * 1024];
					int len = stream.read(fileCon);
					csvIS = new ByteArrayInputStream(fileCon, 0, len);
				}
			}
		} catch (Exception ex) {
			throw new ServletException(ex);
		}

		if (csvIS == null) {
			throw new ServletException("CSV file missing from upload");
		}

		/*
		 * Read the uploaded CSV file and construct Dish object
		 */
		CsvReader csvRdr = new CsvReader(csvIS, Charset.forName("US-ASCII"));

		// Read an populate the Headers
		csvRdr.readHeaders();

		// Get the current Record
		while (csvRdr.readRecord()) {

			// Build Restaurant
			final String restName = csvRdr.get("Restaurant Name");
			final String street = csvRdr.get("Street");
			final String city = csvRdr.get("City");
			final String state = csvRdr.get("State");
			final String neighborhood = csvRdr.get("Neighborhood");
			final String phoneAsString = csvRdr.get("Phone Number");
			final PhoneNumber phone = new PhoneNumber(phoneAsString);
			final String website = csvRdr.get("Website");

			// DO LAT / LON Lookup
			final Pair<Double, Double> latLon = lookUpLatLon(street, city,
					state);

			// Skip if Lat Lon Lookup Failed
			if (null != latLon) {

				// Create the Restaurant Object
				final Restaurant rest = new Restaurant(restName, street, "",
						city, state, neighborhood, latLon.first, latLon.second,
						phone, "", new Link(website), new Date(), creator);

				// Make Restaurant Persistent
				PMF.get().getPersistenceManager().makePersistent(rest);

				if (DEBUG) {
					System.out.println("restaurant to add: ");
					System.out.println(rest.getKey() + "\t" + rest.getName()
							+ "\t" + rest.getAddressLine1() + "\t"
							+ rest.getCity() + "\t" + rest.getState());
					System.out.println(rest.getLatitude() + "\t"
							+ rest.getLongitude() + "\t"
							+ rest.getPhone().getNumber() + "\t"
							+ rest.getUrl());
					System.out.println(rest.getDateCreated() + "\t"
							+ rest.getCreator());
				}
				
				// Build Dish
				final String dishName = csvRdr.get("Dish Name");
				final String category = csvRdr.get("Dish Category");
				final String price = csvRdr.get("Price");
				final String description = csvRdr.get("Description");

				// Get Tags
				final List<String> tagList = new ArrayList<String>();
				tagList.addAll(Arrays.asList(csvRdr.get("Tags").split(",")));

				// Add category and price as tags
				tagList.add(category);
				tagList.add(price);

				// Pull out the tags
				final List<Key> tags = TagUtils.getTagKeysByName(tagList
						.toArray(new String[tagList.size()]));

				// WARNING : Does not handle Duplicates

				// Create Dish Object
				final Dish dish = new Dish(dishName, description, rest,
						new Date(), creator, tags);

				if (DEBUG) {
					System.out.println(dish.getName() + "\t"
							+ dish.getDescription() + "\t"
							+ dish.getRestaurantName() + "\t"
							+ dish.getDateCreated());
					System.out.println(dish.getCreator() + "\t"
							+ dish.getTags().toString());
				}

				// Make Dish Persistent
				PMF.get().getPersistenceManager().makePersistent(dish);
			}

		}

		// close the reader
		csvRdr.close();

		resp.sendRedirect("/uploadBulk.jsp");
	}

	/**
	 * Geocodes the Lat Long for a Restaurant
	 * 
	 * @param street
	 *            - street address (fully qualified)
	 * @param city
	 *            - city the restaurant is located in
	 * @param state
	 *            - state the restaurant is located in
	 * @return a Pair where first is Latitude and second is Longitude
	 */
	private Pair<Double, Double> lookUpLatLon(final String street,
			final String city, final String state) {

		// Base URL
		String urlAsString = "http://local.yahooapis.com/MapsService/V1/geocode?";

		// App ID Supplied by Yahoo
		final String appId = "dj0yJmk9UlBQOU5WYXdRYWFIJmQ9WVdrOU5ESnplVmhITjJVbWNHbzlOemMyTXpJek5qSS0mcz1jb25zdW1lcnNlY3JldCZ4PTM5";

		// Add Fields
		urlAsString += "appid=" + appId;
		urlAsString += "&street=" + street;
		urlAsString += "&city=" + city;
		urlAsString += "&state=" + state;

		try {

			if (DEBUG)
				System.out.println("URL : " + urlAsString);

			// Create Document from InputStream
			final Document doc = DocumentBuilderFactory.newInstance()
					.newDocumentBuilder().parse(urlAsString);
			// Get Latitude Node
			final NodeList latitudes = doc.getElementsByTagName("Latitude");

			// Get Longitude Node
			final NodeList longitudes = doc.getElementsByTagName("Longitude");

			// Check that atleast one of each was returned
			if (latitudes.getLength() > 0 && longitudes.getLength() > 0) {

				// Pull Lat
				final Double lat = Double.parseDouble(latitudes.item(0)
						.getTextContent());

				// Pull Lon
				final Double lon = Double.parseDouble(longitudes.item(0)
						.getTextContent());

				// Return the Pair
				return new Pair<Double, Double>(lat, lon);
			}

		} catch (Exception e) {
			e.printStackTrace();

		}

		return null;
	}
}
