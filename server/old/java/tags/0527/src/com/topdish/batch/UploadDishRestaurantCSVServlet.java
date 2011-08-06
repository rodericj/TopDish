package com.topdish.batch;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.jdo.Query;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import uk.ac.shef.wit.simmetrics.similaritymetrics.Levenshtein;

import com.csvreader.CsvReader;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.Link;
import com.google.appengine.api.datastore.PhoneNumber;
import com.topdish.geo.GeoUtils;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDPoint;
import com.topdish.jdo.Tag;
import com.topdish.util.Datastore;
import com.topdish.util.DuplicateChecker;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;

public class UploadDishRestaurantCSVServlet extends HttpServlet {

	/**
	 * DEBUG
	 */
	private static final boolean DEBUG = true;

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 1675645634L;

	/**
	 * Last Cached Time
	 */
	private Long cacheTime;

	/**
	 * Map of Tags
	 */
	private Map<String, Key> tagMap = new HashMap<String, Key>();

	/**
	 * Info at TopDish Account
	 */
	private Key creator = null;

	/**
	 * Update the Cached version of the Tag Map
	 * 
	 */
	@SuppressWarnings("unchecked")
	private void updateCache() {
		// Null means its never been done and check if it is more than one
		// minute
		if (null == cacheTime || ((System.currentTimeMillis() - cacheTime) > 60000)) {

			System.out.println("Updating Cache");

			// Cached Time
			this.cacheTime = System.currentTimeMillis();

			// New Map
			this.tagMap = new HashMap<String, Key>();

			// Get the latests tags
			Query q = PMF.get().getPersistenceManager().newQuery(Tag.class);
			q.setOrdering("type desc");
			List<Tag> existingTags = (List<Tag>) q.execute();

			// Traverse Tags
			for (final Tag curTag : existingTags)
				this.tagMap.put(curTag.getName().toLowerCase().trim(), curTag.getKey());
		}
	}

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException,
			ServletException {

		// Get the latest tags
		updateCache();

		// Get the info account
		if (null == this.creator)
			// this.creator = getTDUserForEmail(pm,
			// "info@topdish.com").getKey();
			this.creator = TDQueryUtils.getDefaultUser();

		final PrintWriter pw = resp.getWriter();

		// List of dishes added
		final Set<String> dishesAdded = new HashSet<String>();

		// List of restaurants added
		final Set<String> restaurantsAdded = new HashSet<String>();

		// List of duplicate dishes
		final Set<String> duplicateDish = new HashSet<String>();

		// List of duplicate restaurants
		final Set<String> duplicateRest = new HashSet<String>();

		String summary = "";

		// Process multipart/form-data
		// Check that we have a file upload request
		boolean isMultipart = ServletFileUpload.isMultipartContent(req);
		if (!isMultipart) {
			throw new ServletException("Only multipart/form-data POST allowed!");
		}
		try {

			// Handle file upload
			final ServletFileUpload upload = new ServletFileUpload();
			final FileItemIterator iter = upload.getItemIterator(req);

			while (iter.hasNext()) {
				final FileItemStream item = iter.next();

				final CsvReader csvRdr = new CsvReader(item.openStream(), Charset.forName("UTF-8"));
				csvRdr.readHeaders();

				int counter = 0;

				// Traverse Records
				while (csvRdr.readRecord()) {

					// Send a keep alive back to the server
					if (counter % 10 == 0)
						pw.write(" ");

					// Build Restaurant
					final String restName = csvRdr.get("Restaurant Name").trim();
					final String line1 = csvRdr.get("Address Line 1").trim();
					final String line2 = csvRdr.get("Address Line 2").trim();
					final String city = csvRdr.get("City").trim();
					final String state = csvRdr.get("State").trim();
					final String neighborhood = csvRdr.get("Neighborhood");
					final String phoneAsString = csvRdr.get("Phone Number");
					final PhoneNumber phone = new PhoneNumber(phoneAsString);
					final String website = csvRdr.get("Website");
					final String cuisineType = csvRdr.get("Cuisine Type").trim();

					TDPoint latLng = GeoUtils.reverseAddress(line1 + " " + line2, city, state);

					Restaurant rest = new Restaurant(restName, line1, line2, city, state,
							neighborhood, latLng.getLat(), latLng.getLon(), phone, new String(),
							new Link(website), new Date(), creator);

					// Check if restaurant exists
					Query restQ = PMF.get().getPersistenceManager().newQuery(Restaurant.class);
					restQ.setFilter("name == :p");
					Set<Restaurant> restResults = new HashSet<Restaurant>(
							(List<Restaurant>) restQ.execute(restName));

					Restaurant potentialDup = null;
					if (null != (potentialDup = DuplicateChecker.getDuplicate(rest, restResults))) {
						System.out.println("Restaurant found, not re-adding: " + restName);
						rest = potentialDup;
						duplicateRest.add(rest.getName());
					} else {
						System.out.println("Adding new restaurant: " + restName);

						if ((null != cuisineType) && this.tagMap.containsKey(cuisineType))
							rest.setCuisine(this.tagMap.get(cuisineType));

						// Make Restaurant Persistent
						Datastore.put(rest);
						restaurantsAdded.add(rest.getName());

						if (DEBUG) {
							System.out.println("restaurant to add: ");
							System.out.println(rest.getKey() + "\t" + rest.getName() + "\t"
									+ rest.getAddressLine1() + "\t" + rest.getCity() + "\t"
									+ rest.getState());
							System.out.println(rest.getLatitude() + "\t" + rest.getLongitude()
									+ "\t" + rest.getPhone().getNumber() + "\t" + rest.getUrl());
							System.out.println(rest.getDateCreated() + "\t" + rest.getCreator());
						}
					}

					// Build Dish
					final String dishName = csvRdr.get("Dish Name").trim();
					final String category = csvRdr.get("Dish Category").trim();
					final String price = csvRdr.get("Price");
					final String description = csvRdr.get("Description").trim();

					// Get Tags
					final List<String> tagList = new ArrayList<String>();

					// tagList.addAll(Arrays.asList(cuisineType.split(",")));
					tagList.addAll(Arrays.asList(csvRdr.get("Tags").split(",")));

					// Add category and price as tags
					tagList.add(category);
					tagList.add(price);
					tagList.add(cuisineType);

					System.out.println("TAGS BEFORE (" + tagList.size() + "): " + tagList);

					// Map of keys as set
					final String[] mapKeys = this.tagMap.keySet().toArray(
							new String[this.tagMap.size()]);

					// List of tags to add
					final Set<Key> tags = new HashSet<Key>();

					// Levenshtein check of misspelling
					final Levenshtein leve = new Levenshtein();

					for (final String curTag : tagList) {

						// Skip if empty
						if (curTag.isEmpty())
							continue;

						// Key to Add
						Key keyToAdd = this.tagMap.get(curTag.toLowerCase().trim());

						// If the get failed, check if it was misspelled
						if (null == keyToAdd) {

							// Traverse Tag keys
							for (final String curMapKey : mapKeys) {

								// Current Leventhian value
								final float value = leve.getSimilarity(curTag, curMapKey);

								// if (DEBUG)
								// System.out.println("Comparing "
								// + curTag + " to " + curMapKey
								// + " has levenshtein value of "
								// + value);

								// Check that overall value was > .5
								if (value > .8) {
									// tags.add(tagMap.get(curMapKey));

									// Get the key
									keyToAdd = this.tagMap.get(curMapKey);

									// Cut from loop
									break;
								}
							}

							// If no key was found in the search
							if (null == keyToAdd) {

								// Create a new Tag
								final Tag newTag = new Tag(null, curTag, new String(),
										Tag.TYPE_GENERAL, new Date(), this.creator);

								// Store to the datastore
								Datastore.put(newTag);

								// Add to the cache
								this.tagMap.put(newTag.getName().toLowerCase().trim(),
										newTag.getKey());

								// Set as key to add
								keyToAdd = newTag.getKey();
							}
						}

						// Add to the list
						tags.add(keyToAdd);

					}

					System.out.println("TAGS AFTER: (" + tags.size() + "): " + tags);

					Query dishQ = PMF.get().getPersistenceManager().newQuery(Dish.class);
					dishQ.setFilter("name == :p");
					List<Dish> dishResults = (List<Dish>) dishQ.execute(dishName);

					Dish dish = null;

					boolean doNewDish = true;

					// If dish names came back
					if (!dishResults.isEmpty()) {

						System.out.println("Dish " + dishName + " name found, checking Restaurant");

						for (final Dish curPotDupDish : dishResults) {
							Restaurant dupDishRest = Datastore.get(curPotDupDish.getRestaurant());

							// Compare restaurants
							if (DuplicateChecker.checkDuplicate(rest, dupDishRest)) {
								System.out.println("Restaurant and Dish match, not re-adding: "
										+ dishName + " at " + rest.getName());

								dish = dishResults.get(0);
								duplicateDish.add(dish.getName());
								doNewDish = false;
								break;
							} else
								doNewDish = true;
						}
					}

					// If not a duplicate add the new one
					if (doNewDish) {
						System.out.println("Adding new dish: " + dishName);

						// Create Dish Object
						dish = new Dish(dishName, description, rest, this.creator, tags);

						if (DEBUG) {
							System.out.println("dish to add:");
							System.out.println(dish.getName() + "\t" + dish.getDescription() + "\t"
									+ dish.getRestaurantName() + "\t" + dish.getDateCreated()
									+ "\t");
							System.out
									.println(dish.getCreator() + "\t" + dish.getTags().toString());
						}

						// Make Dish Persistent
						Datastore.put(dish);
						dishesAdded.add(dish.getName());

					}
				}
				// close the reader
				csvRdr.close();
			}

			summary = "Summary:" + " \n\tNew Dishes: " + dishesAdded.size()
					+ " \n\tDuplicate Dishes: " + duplicateDish.size() + " \n\tNew Restaurants: "
					+ restaurantsAdded.size() + " \n\tDuplicate Restaurants: "
					+ duplicateRest.size();

			// resp.getOutputStream().write(summary.getBytes());

			System.out.println(summary);

		} catch (final Exception e2) {
			e2.printStackTrace();
		}

		// resp.sendRedirect("/admin/uploadBulk.jsp?summary=" + summary);
		pw.write(summary);
		pw.flush();
		pw.close();
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
	// private Pair<Double, Double> lookUpLatLon(final String line1,
	// final String line2, final String city, final String state) {
	//
	// // Base URL
	// String urlAsString =
	// "http://local.yahooapis.com/MapsService/V1/geocode?";
	//
	// // App ID Supplied by Yahoo
	// final String appId =
	// "dj0yJmk9UlBQOU5WYXdRYWFIJmQ9WVdrOU5ESnplVmhITjJVbWNHbzlOemMyTXpJek5qSS0mcz1jb25zdW1lcnNlY3JldCZ4PTM5";
	//
	// // Add Fields
	// urlAsString += "appid=" + appId;
	// urlAsString += "&street=" + line1 + " " + line2;
	// urlAsString += "&city=" + city;
	// urlAsString += "&state=" + state;
	//
	// try {
	//
	// if (DEBUG)
	// System.out.println("URL : " + urlAsString);
	//
	// // Create Document from InputStream
	// final Document doc = DocumentBuilderFactory.newInstance()
	// .newDocumentBuilder().parse(urlAsString);
	// // Get Latitude Node
	// final NodeList latitudes = doc.getElementsByTagName("Latitude");
	//
	// // Get Longitude Node
	// final NodeList longitudes = doc.getElementsByTagName("Longitude");
	//
	// // Check that atleast one of each was returned
	// if (latitudes.getLength() > 0 && longitudes.getLength() > 0) {
	//
	// // Pull Lat
	// final Double lat = Double.parseDouble(latitudes.item(0)
	// .getTextContent());
	//
	// // Pull Lon
	// final Double lon = Double.parseDouble(longitudes.item(0)
	// .getTextContent());
	//
	// // Return the Pair
	// return new Pair<Double, Double>(lat, lon);
	// }
	//
	// } catch (Exception e) {
	// e.printStackTrace();
	//
	// }
	//
	// return null;
	// }
}
