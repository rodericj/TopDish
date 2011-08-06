package com.topdish.api;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONException;
import org.json.JSONObject;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.DishConstants;
import com.topdish.api.util.PhotoConstants;
import com.topdish.api.util.RestaurantConstants;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;

/**
 * API Photo Servlet to allow upload of photo to Dish or Restaurant <br>
 * 
 * @author Salil
 * 
 */
public class AddPhotoServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -1578767130153683532L;

	/**
	 * DEBUG
	 */
	private static final boolean DEBUG = true;

	/**
	 * BlobStore Service
	 */
	private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		PrintWriter writer = resp.getWriter();

		if (DEBUG)
			System.out.println("Start Photo Upload API");

		try {
			// Pull Blob, will throw an error
			final Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
			BlobKey blobKey = blobs.get(PhotoConstants.PHOTO);

			if (DEBUG)
				System.out.println("Photo submitted");

			// Pull pieces
			final String desc = (null != req.getParameter(PhotoConstants.DESCRIPTION) ? req
					.getParameter(PhotoConstants.DESCRIPTION) : new String());
			final String apiKey = req.getParameter(APIConstants.API_KEY);
			final String dishIds = req.getParameter(DishConstants.DISH_ID);
			final String restaurantIds = req.getParameter(RestaurantConstants.RESTAURANT_ID);

			if (DEBUG)
				System.out.println(DishConstants.DISH_ID + "\t:\t" + dishIds + "\n"
						+ RestaurantConstants.RESTAURANT_ID + "\t:\t" + restaurantIds + "\n"
						+ APIConstants.API_KEY + "\t:\t" + apiKey + "\n" + APIConstants.DESCRIPTION
						+ desc + "\n" + PhotoConstants.BLOB_KEY + "\t:\t" + blobKey.getKeyString());

			// Get the creator
			Key creator = TDQueryUtils.getUserKeyByAPIKey(apiKey);

			// Create the photo
			Photo photo = new Photo(blobKey, desc, creator);
			Datastore.put(photo);

			// Check if it is attached to a Dish
			if (null != dishIds) {

				// Get the Dish
				Dish dish = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), Long
						.parseLong(dishIds)));
				dish.addPhoto(photo.getKey());
				Datastore.put(dish);

				if (DEBUG)
					System.out.println("Photo " + photo.getKey().getId() + " being added to Dish "
							+ dishIds);

				// Send success and Dish Id and Photo Id back to user
				writer
						.write(APIUtils.generateJSONSuccessMessage(new JSONObject().put(
								DishConstants.DISH_ID, dish.getKey().getId()).put(
								PhotoConstants.PHOTO_ID, photo.getKey().getId()).put(
								PhotoConstants.PHOTO,
								ImagesServiceFactory.getImagesService().getServingUrl(
										photo.getBlobKey()))));

			}
			// Check if it is attached to a Restaurant
			else if (null != restaurantIds) {

				// Get the Restaurant
				Restaurant restaurant = Datastore.get(KeyFactory.createKey(Restaurant.class
						.getSimpleName(), Long.parseLong(restaurantIds)));
				restaurant.addPhoto(photo.getKey());
				Datastore.put(restaurant);

				if (DEBUG)
					System.out.println("Photo " + photo.getKey().getId()
							+ " being added to Restaurant " + restaurantIds);

				// Send success and Restaurant Id and Photo Id back to user
				writer
						.write(APIUtils.generateJSONSuccessMessage(new JSONObject().put(
								RestaurantConstants.RESTAURANT_ID, restaurant.getKey().getId())
								.put(PhotoConstants.PHOTO_ID, photo.getKey().getId()).put(
										PhotoConstants.PHOTO,
										ImagesServiceFactory.getImagesService().getServingUrl(
												photo.getBlobKey()))));

			}
			// Otherwise assume nothing added, send upload URL
			else
				// Send the URL
				writer.write(APIUtils.generateJSONSuccessMessage(new JSONObject().put(
						APIConstants.URL, blobstoreService.createUploadUrl("/api/addPhoto"))));

		} catch (Exception e) {
			e.printStackTrace();

			if (DEBUG)
				System.out.println("No Photo Submitted. Returning URL.");

			try {
				// Send the URL
				writer.write(APIUtils.generateJSONSuccessMessage(new JSONObject().put(
						APIConstants.URL, blobstoreService.createUploadUrl("/api/addPhoto"))));
			} catch (JSONException e1) {
				e1.printStackTrace();

				// Send failures
				writer.write(APIUtils
						.generateJSONFailureMessage("Failed to Generate Photo Upload URL"));
			}

		} finally {

			writer.flush();
			writer.close();
		}
	}
}
