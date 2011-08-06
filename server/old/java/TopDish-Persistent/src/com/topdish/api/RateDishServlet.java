package com.topdish.api;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.api.util.APIUtils;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;

/**
 * Class to handle rating a dish for the API
 * 
 * @author Salil
 * 
 */
public class RateDishServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -3589030030821612441L;

	/**
	 * Print DEBUG
	 */
	private static final boolean DEBUG = true;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		PersistenceManager pm = PMF.get().getPersistenceManager();
		final String apiKey = req.getParameter(APIUtils.API_KEY).trim();
		// Grab User Associated with API Key
		final TDUser creator = APIUtils.getUserAssociatedWithApiKey(pm, apiKey);

		if (null != creator) {

			if (DEBUG) {
				System.out.println("Starting Rate Dish");
				System.out.println("User with api key " + apiKey + " found.");
			}

			try {
				// Get Posted Data
				final Long dishId = Long.parseLong(req.getParameter("dishId"));
				final Integer direction = Integer.parseInt(req
						.getParameter("direction"));
				final String comment = req.getParameter("comment");

				if (DEBUG)
					System.out.println("Adding : " + dishId + " with a "
							+ direction + " review and comment " + comment);

				Dish dish = pm.getObjectById(Dish.class, dishId);

				// Create Review
				Review review = new Review(dish.getKey(), direction, comment,
						creator.getKey());
				pm.makePersistent(review);

				// Add Review to Dish
				dish.addReview(review);
				pm.makePersistent(dish);

				// Add Review to Creator
				creator.addReview(review);
				pm.makePersistent(creator);

				if (DEBUG)
					System.out
							.println("Dish successfully updated with review.");

				resp.getWriter().write("{\"rc\":0}");
				
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				pm.close();
			}

		} else if (DEBUG) {
			System.err.println("No user found for api key: "
					+ req.getParameter(APIUtils.API_KEY).trim());
			
			String json = "{\"rc\":1, \"message\":\"User not found.\"}";
			resp.getWriter().write(json);
		}
	}
}