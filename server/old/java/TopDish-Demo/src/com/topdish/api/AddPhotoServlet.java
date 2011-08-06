package com.topdish.api;

import java.io.IOException;
import java.util.Map;

import javax.jdo.PersistenceManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.DishConstants;
import com.topdish.api.util.PhotoConstants;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;

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
	private BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		if (DEBUG)
			System.out.println("Start Photo Upload API");

		try {
			final Map<String, BlobKey> blobs = blobstoreService
					.getUploadedBlobs(req);
			BlobKey blobKey = blobs.get(PhotoConstants.PHOTO);
			PersistenceManager pm = PMF.get().getPersistenceManager();

			if (DEBUG)
				System.out.println("Photo submitted");
			final String desc = req.getParameter(PhotoConstants.DESCRIPTION) == null ? new String()
					: req.getParameter(PhotoConstants.DESCRIPTION);
			final String apiKey = req.getParameter(APIConstants.API_KEY);
			final String dishIds = req.getParameter(DishConstants.DISH_ID);

			if (DEBUG)
				System.out.println(DishConstants.DISH_ID + "\t:\t" + dishIds
						+ "\n" + APIConstants.API_KEY + "\t:\t" + apiKey + "\n"
						+ APIConstants.DESCRIPTION + desc + "\n"
						+ PhotoConstants.BLOB_KEY + "\t:\t"
						+ blobKey.getKeyString());

			TDUser creator = APIUtils.getUserAssociatedWithApiKey(pm, apiKey);
			Photo photo = new Photo(blobKey, desc, creator.getKey());

			Dish dish = pm.getObjectById(Dish.class, Long.parseLong(dishIds));
			pm.makePersistent(photo);

			if (DEBUG)
				System.out.println("photo added: " + photo.getKey()
						+ " to dish: " + dish.getKey());

			dish.addPhoto(photo.getKey());
			pm.makePersistent(dish);

			if (DEBUG) {
				System.out
						.println("dish photos:" + dish.getPhotos().toString());
				System.out.println("Adding Photo Done!");
			}

			pm.close();

			resp.getWriter().write(APIUtils.generateJSONSuccessMessage());

		} catch (IllegalStateException e) {
			// not the blob upload request
			// no photo submitted, send back upload URL
			if (DEBUG)
				System.out
						.println("Emtpy request sent, sending back photo upload URL");

			// Get the URL
			final String uploadURL = blobstoreService
					.createUploadUrl("/api/addPhoto");

			// Create the success return message
			try {
				String json = APIUtils
						.generateJSONSuccessMessage(new JSONObject().put(
								APIConstants.URL, uploadURL));
				if (DEBUG)
					System.out.println("upload url: " + json);

				resp.getWriter().write(json);
			} catch (Exception e1) {
				resp
						.getWriter()
						.write(
								APIUtils
										.generateJSONFailureMessage("Failed to form JSON"));
			}

		}
	}
}
