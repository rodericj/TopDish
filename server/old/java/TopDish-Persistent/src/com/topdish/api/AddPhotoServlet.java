package com.topdish.api;

import java.io.IOException;
import java.util.Map;

import javax.jdo.PersistenceManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.topdish.api.util.APIUtils;
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
			Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
			BlobKey blobKey = blobs.get("photo");
			PersistenceManager pm = PMF.get().getPersistenceManager();

			System.out.println("Photo submitted");
			String desc = req.getParameter("description") == null ? "" : req
					.getParameter("description");
			String apiKey = req.getParameter("apiKey");
			String dishIds = req.getParameter("dishId");

			if (DEBUG) {
				System.out.println("dishId: " + dishIds + " apiKey: " + apiKey
						+ " desc: " + desc);
				System.out.println("blobkey: " + blobKey.getKeyString());
			}

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
			
			resp.getWriter().write("{\"rc\":0}");
			
		} catch (IllegalStateException e) {
			// not the blob upload request
			// no photo submitted, send back upload URL
			if (DEBUG)
				System.out
						.println("Emtpy request sent, sending back photo upload URL");

			String uploadURL = blobstoreService
					.createUploadUrl("/api/addPhoto");
			String json = "{\"url\": \"" + uploadURL + "\"}";

			if (DEBUG)
				System.out.println("upload url: " + json);

			resp.getWriter().write(json);
		}
	}
}
