package com.topdish;

import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.util.Datastore;
import com.topdish.util.PMF;

public class DataMigrationServlet extends HttpServlet {
	private static final long serialVersionUID = -7365929129043334354L;
	private static final String TAG = DataMigrationServlet.class.getSimpleName();

	@SuppressWarnings({ "unchecked" })
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		int photoKeysFound = 0;
		int photosFound = 0;
		int photosUpdated = 0;

		// Fix all Restaurant photos
		final String rQueryString = "SELECT key FROM " + Restaurant.class.getName();
		final Query rQuery = PMF.get().getPersistenceManager().newQuery(rQueryString);
		final Set<Key> restKeys = new HashSet<Key>((Collection<Key>) rQuery.execute());
		final Set<Restaurant> restaurants = Datastore.get(restKeys);

		for (final Restaurant rest : restaurants) {
			if (null != rest.getPhotos() && !rest.getPhotos().isEmpty()) {
				Logger.getLogger(TAG).info(
						"Fixing photos for restaurant " + rest.getKey().getId() + " - "
								+ rest.getName());
				for (final Key k : rest.getPhotos()) {
					photoKeysFound++;
					try {
						final Photo photo = Datastore.get(k);
						Logger.getLogger(TAG).info(
								"\tPhoto " + photo.getKey().getId() + " updated!");
						photosFound++;
						// photo.addOwner(rest.getKey());
						// Logger.getLogger(TAG).info("Added owner to photo " +
						// photo.getKey().getId());
						// Datastore.put(photo);
						photosUpdated++;
					} catch (Exception e) {
						Logger.getLogger(TAG)
								.info("\tPhoto " + k.getId() + " not found, skipping.");
						Logger.getLogger(TAG).info(e);
					}
				}
			} else {
				// Logger.getLogger(TAG)
				// .info("Restaurant " + rest.getKey().getId() +
				// " has no photos");
			}
		}

		// Fix all Dish photos
		final String dQueryString = "SELECT key FROM " + Dish.class.getName();
		final Query dQuery = PMF.get().getPersistenceManager().newQuery(dQueryString);
		final Set<Key> dishKeys = new HashSet<Key>((Collection<Key>) dQuery.execute());
		final Set<Dish> dishes = Datastore.get(dishKeys);

		for (final Dish dish : dishes) {
			if (null != dish.getPhotos() && !dish.getPhotos().isEmpty()) {
				Logger.getLogger(TAG).info(
						"Fixing photos for dish " + dish.getKey().getId() + " - " + dish.getName());

				for (final Key k : dish.getPhotos()) {
					photoKeysFound++;
					try {
						final Photo photo = Datastore.get(k);
						photosFound++;
						Logger.getLogger(TAG).info(
								"\tPhoto " + photo.getKey().getId() + " updated!");
						// photo.addOwner(dish.getKey());
						// Logger.getLogger(TAG).info("Added owner to photo " +
						// photo.getKey());
						// Datastore.put(photo);
						photosUpdated++;
					} catch (Exception e) {
						Logger.getLogger(TAG)
								.info("\tPhoto " + k.getId() + " not found, skipping.");
						Logger.getLogger(TAG).info(e);
					}
				}
			} else {
				// Logger.getLogger(TAG).info("Dish " + dish.getKey().getId() +
				// " has no photos");
			}
		}

		// Fix all Review photos
		final String vQueryString = "SELECT key FROM " + Review.class.getName();
		final Query vQuery = PMF.get().getPersistenceManager().newQuery(vQueryString);
		final Set<Key> reviewKeys = new HashSet<Key>((Collection<Key>) vQuery.execute());
		final Set<Review> reviews = Datastore.get(reviewKeys);

		for (final Review review : reviews) {
			if (null != review.getPhoto()) {
				photoKeysFound++;
				Logger.getLogger(TAG).info("Fixing photos for review " + review.getKey().getId());

				try {
					final Photo photo = Datastore.get(review.getPhoto());
					photosFound++;
					Logger.getLogger(TAG).info("\tPhoto " + photo.getKey().getId() + " updated!");
					// photo.addOwner(review.getKey());
					// Logger.getLogger(TAG).info("Added owner to photo " +
					// photo.getKey());
					// Datastore.put(photo);
					photosUpdated++;
				} catch (Exception e) {
					Logger.getLogger(TAG).info(
							"\tPhoto " + review.getPhoto().getId() + " not found, skipping.");
					Logger.getLogger(TAG).info(e);
				}
			} else {
				// Logger.getLogger(TAG).info("Dish " + dish.getKey().getId() +
				// " has no photos");
			}
		}

		Logger.getLogger(TAG).info("Summary:");
		Logger.getLogger(TAG).info("Photo keys found: " + photoKeysFound);
		Logger.getLogger(TAG).info("Photos found " + photosFound);
		Logger.getLogger(TAG).info("Photos updated: " + photosUpdated);
	}
}