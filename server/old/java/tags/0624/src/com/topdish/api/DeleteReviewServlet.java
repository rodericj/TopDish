package com.topdish.api;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.api.util.APIUtils;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.util.Datastore;

/**
 * Servlet to delete a {@link Review} from a {@link Dish} and a {@link TDUser}
 * 
 * @author Salil
 * 
 */
public class DeleteReviewServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 6920673857814068301L;

	/**
	 * DEBUG
	 */
	private final boolean DEBUG = false;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// Get writer
		PrintWriter writer = resp.getWriter();

		try {

			// Check that Dish ID and Review ID were entered
			if (null != req.getParameter("dishId")
					&& null != req.getParameter("reviewId")) {

				if (DEBUG)
					System.out.println("Dish and Review Ids Found.");

				// Pull out Dish Id
				final Long dishId = Long.parseLong(req.getParameter("dishId"));

				// Pull out Review Id
				final Long reviewId = Long.parseLong(req
						.getParameter("reviewId"));

				if (DEBUG)
					System.out.println("Dish Id : " + dishId + "\nReview Id : "
							+ reviewId);

				// Get Dish
				final Dish dish = Datastore.get(KeyFactory.createKey(
						Dish.class.getSimpleName(), dishId));

				// Get Review
				final Review review = Datastore.get(KeyFactory.createKey(
						Review.class.getSimpleName(), reviewId));

				final TDUser revCreator = Datastore.get(review
						.getCreator());

				if (DEBUG)
					System.out.println("Dish owns Review, removing.");

				dish.removeReview(review);

				if (DEBUG)
					System.out.println("User " + revCreator.getKey().getId()
							+ " owns Review " + reviewId + ", removing.");

				revCreator.removeReview(review);

				// Send Success to User
				writer.write(APIUtils
						.generateJSONSuccessMessage("Removed Review "
								+ reviewId + " from Dish " + dishId));
				writer.flush();
				writer.close();

				// Save the Dish
				Datastore.put(dish);

				// Delete the Review
				Datastore.delete(review.getKey());

				// Save the user
				Datastore.put(revCreator);

				if (DEBUG)
					System.out.println("Removal of Review " + reviewId
							+ " complete.");

			} else {

				if (DEBUG)
					System.out.println("Review not found.");

				writer.write(APIUtils
						.generateJSONFailureMessage("Review not found."));
				writer.flush();
				writer.close();
			}

		} catch (Exception e) {
			e.printStackTrace();
			writer.write(APIUtils.generateJSONFailureMessage(e));
			writer.flush();
			writer.close();
		}
	}
}
