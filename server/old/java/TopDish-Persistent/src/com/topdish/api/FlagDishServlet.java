package com.topdish.api;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Flag;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;

/**
 * Servlet to handle flagging a dish <br>
 * Params: <br>
 * -apiKey - current user's api key <br>
 * -dishId - the dish id to be flagged <br>
 * -type - (see {@link Flag} statics <br>
 * 
 * @author Salil
 * 
 */
public class FlagDishServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -7219706700243372246L;

	/**
	 * DEBUG
	 */
	private static final boolean DEBUG = true;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// Get Persistence Manager
		PersistenceManager pm = PMF.get().getPersistenceManager();

		// Get API Key
		final String apiKey = req.getParameter(APIUtils.API_KEY).trim();

		// Grab User Associated with API Key
		final TDUser creator = APIUtils.getUserAssociatedWithApiKey(pm, apiKey);

		// Check for no user
		if (null != creator) {

			if (DEBUG)
				System.out.println("User Found : " + creator.getKey().getId());

			// Get the dish id
			final Long dishId = Long.parseLong(req
					.getParameter(APIConstants.DISH_ID));

			// Get the flag type
			final Integer flagType = Integer.parseInt(req
					.getParameter(APIConstants.FLAG_TYPE));

			// Pull dish from db
			Dish dish = pm.getObjectById(Dish.class, dishId);

			// Check that dish exists
			if (null != dish) {

				if (DEBUG)
					System.out.println("Dish Found : " + dish.getKeyString());

				// Check that Flag Type exists
				if (flagType == Flag.INACCURATE
						|| flagType == Flag.INAPPROPRIATE
						|| flagType == Flag.SPAM) {

					// Create new flag
					Flag flag = new Flag(flagType, dish.getCreator(), creator
							.getKey());

					// Store flag
					pm.makePersistent(flag);

					// Close PM
					pm.close();

					// Write success
					resp.getWriter().write(
							APIUtils.generateJSONSuccessMessage());

					if (DEBUG)
						System.out.println("Flag Created and Stored : "
								+ flag.getKey().getId() + " with direction "
								+ flag.getType());
				} else {
					// Write failure to find flag type
					resp.getWriter().write(
							APIUtils.generateJSONFailureMessage(flagType
									+ " is an invalid type."));

					if (DEBUG)
						System.out.println("Flag Type was invalid : "
								+ flagType);
				}

			} else {
				// Write failure to find dish
				resp.getWriter().write(
						APIUtils.generateJSONFailureMessage("Dish " + dishId
								+ " did not exist."));

				if (DEBUG)
					System.out.println("Dish not found");
			}
		} else {
			// Write failure to find user
			resp.getWriter().write(
					APIUtils.generateJSONFailureMessage("User with API Key "
							+ apiKey + " does not exist."));

			if (DEBUG)
				System.out.println("User not found");
		}

	}
}
