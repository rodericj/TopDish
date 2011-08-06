package com.topdish;

import java.io.IOException;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Link;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Source;
import com.topdish.jdo.TDUser;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

public class AddPhotoServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 6510992373222045247L;

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = AddPhotoServlet.class.getSimpleName();

	/**
	 * {@link BlobstoreService} from the {@link BlobstoreServiceFactory}
	 */
	private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException,
			IOException {

		if (!TDUserService.isUserLoggedIn(req.getSession(false))) {
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}

		// TODO: session times out if you use "back" and try again

		Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
		BlobKey blobKey = blobs.get("myFile");

		String userIDs = req.getParameter("userID");
		String dishIDs = req.getParameter("dishID");
		String restIDs = req.getParameter("restID");
		String desc = req.getParameter("description");
		String sourceDrop = req.getParameter("sourceDrop");
		String sourceName = req.getParameter("sourceName");
		String sourceURL = req.getParameter("sourceURL");
		String sourcePhotoURL = req.getParameter("sourcePhotoURL");

		Source source = null;

		Logger.getLogger(TAG).info(
				"Source Info: " + sourceDrop + "\t" + sourceName + "\t" + sourceURL + "\t"
						+ sourcePhotoURL);

		// Pull Source out
		try {
			// Check if a drop down was chose and it is not Other
			if (null != sourceDrop && !sourceDrop.isEmpty()
					&& !sourceDrop.equalsIgnoreCase("Other")) {

				Logger.getLogger(TAG).info("Source chosen from drop down: " + sourceDrop);

				try {
					source = Datastore.get(KeyFactory.createKey(Source.class.getSimpleName(), Long
							.parseLong(sourceDrop)));
					Logger.getLogger(TAG).info("Source Found: " + source.getName());
				} catch (Exception e) {
					Logger.getLogger(TAG).info("Failed to parse Source", e);
					source = null;
				}

			}

			// If Source is still empty,
			if (null == source && null != sourceName && !sourceName.isEmpty()) {

				Logger.getLogger(TAG).info("Checking for duplicate sources against new source");

				// Check for duplicate source
				final Iterator<Source> iterator = TDQueryUtils.searchSourcebyName(sourceDrop, 1)
						.iterator();

				// If it is duplicate
				if (iterator.hasNext()) {
					source = iterator.next();
					Logger.getLogger(TAG)
							.info("Duplicate source found: " + source.getKey().getId());
				} else {
					source = new Source(sourceName, new Link(sourceURL));
					Datastore.put(source);
					Logger.getLogger(TAG).info("New Source created " + source.getKey().getId());
				}
			}
		} catch (Exception e) {
			Logger.getLogger(TAG).info("Failed to parse Source, skipping", e);
		}

		long userID = 0;
		long dishID = 0;
		long restID = 0;

		try {
			// Check that both the blob is null
			if (blobKey == null) {
				// TODO: find a better place to redirect
				Alerts.setError(req, Alerts.PHOTO_NOT_ADDED);
				resp.sendRedirect("index.jsp");
				return;
			} else {
				TDUser creator = TDUserService.getUser(req.getSession());
				Photo photo = null;
				// use blob if provided
				if (null != blobKey) {
					photo = new Photo(blobKey, desc, creator.getKey());
					if (null != source) {
						Logger.getLogger(TAG).info("Adding Source to Photo");
						photo.addSource(source.getKey(), (null != sourcePhotoURL ? sourcePhotoURL
								: new String()));
						Logger.getLogger(TAG).info(
								"Source added to Photo: " + photo.getSources().size());
					} else
						Logger.getLogger(TAG).info("Source was null, not adding to photo");
					Datastore.put(photo);

					if (userIDs != null) {
						userID = Long.parseLong(userIDs);
						if (userID == creator.getKey().getId()) {
							// only allow user to update own photo
							TDUser user = Datastore.get(KeyFactory.createKey(TDUser.class
									.getSimpleName(), userID));
							user.setPhoto(photo.getKey());
							Datastore.put(user);

							Alerts.setInfo(req, Alerts.PHOTO_ADDED);
							resp.sendRedirect("/userProfile.jsp");
							return;
						} else {
							Alerts.setError(req, Alerts.PHOTO_NOT_ADDED);
							resp.sendRedirect("index.jsp");
							return;
						}
					}

					if (dishIDs != null) {
						dishID = Long.parseLong(dishIDs);
						Dish dish = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(),
								dishID));
						dish.addPhoto(photo.getKey());
						Datastore.put(dish);

						Alerts.setInfo(req, Alerts.PHOTO_ADDED);
						resp.sendRedirect("/dishDetail.jsp?dishID=" + dishID);
						return;
					}

					if (restIDs != null) {
						restID = Long.parseLong(restIDs);
						Restaurant rest = Datastore.get(KeyFactory.createKey(Restaurant.class
								.getSimpleName(), restID));
						rest.addPhoto(photo.getKey());
						Datastore.put(rest);

						Alerts.setInfo(req, Alerts.PHOTO_ADDED);
						resp.sendRedirect("/restaurantDetail.jsp?restID=" + restID);
						return;
					}
				}
			}
		} catch (UserNotLoggedInException e) {
			// forward to login screen
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		} catch (UserNotFoundException e) {
			// forward to login screen
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}
	}
}
