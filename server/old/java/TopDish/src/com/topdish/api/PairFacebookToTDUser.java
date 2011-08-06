package com.topdish.api;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.FacebookConstants;
import com.topdish.api.util.UserConstants;
import com.topdish.jdo.TDUser;
import com.topdish.util.Datastore;

/**
 * Serlvet to pair TDUsers to Facebook Users given their Id
 * 
 * @author Salil
 * 
 */
public class PairFacebookToTDUser extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 7485718391366011497L;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		final PrintWriter pw = resp.getWriter();

		try {

			// Get the Facebook Id
			final String facebookId = req
					.getParameter(FacebookConstants.FACEBOOK_ID);

			// Get the TDUserId
			final String tdUserIdasStr = req
					.getParameter(UserConstants.TDUSER_ID);

			// Check td user id is not null
			if (null != tdUserIdasStr) {

				// Check facebook id is not null
				if (null != facebookId) {

					// Get the user
					TDUser user = Datastore.get(KeyFactory.createKey(
							TDUser.class.getSimpleName(), Long
									.parseLong(tdUserIdasStr)));

					// Check that user exists
					if (null != user) {
						user.setFacebookId(facebookId);
						Datastore.put(user);
						pw.write(APIUtils
								.generateJSONSuccessMessage("Success! User "
										+ user.getKey().getId()
										+ " now has Facebook Id " + facebookId
										+ " attached to it."));
					} else
						// Notify user does not exist
						pw.write(APIUtils.generateJSONFailureMessage(3,
								"No Such TDUser."));

				} else
					// Notify no facebook id provided
					pw.write(APIUtils.generateJSONFailureMessage(4,
							"No FacebookId Provided."));
			} else
				// Notify not TDUserId provided
				pw.write(APIUtils.generateJSONFailureMessage(2,
						"TDUserId was not provided."));

		} catch (Exception e) {
			e.printStackTrace();
			
			// Notify of generic error
			pw.write(APIUtils.generateJSONFailureMessage(e));
		} finally {
			pw.flush();
			pw.close();
		}

	}
}
