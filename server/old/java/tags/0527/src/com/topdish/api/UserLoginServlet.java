package com.topdish.api;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.topdish.api.util.APIUtils;
import com.topdish.api.util.UserConstants;
import com.topdish.jdo.TDUser;
import com.topdish.util.Datastore;
import com.topdish.util.PMF;

public class UserLoginServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -635420597647785547L;

	@SuppressWarnings("unchecked")
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		try {
			// TODO: Update this servlet to properly authenticate with
			// OpenID/Facebook; issue real API keys stored in an APIKey table to
			// keep track of usage.
			final String email = req.getParameter(UserConstants.EMAIL)
					.toLowerCase();

			// Query for the email address
			final Query q = PMF.get().getPersistenceManager()
					.newQuery(TDUser.class);
			q.setFilter("email == :email");
			final List<TDUser> results = (List<TDUser>) q.execute(email);

			// If results are found
			if (!results.isEmpty()) {

				// email found
				final TDUser curUser = results.get(0);
				if (null == curUser.getApiKey()) {
					final String apiKey = UUID.randomUUID().toString().trim();
					curUser.setApiKey(apiKey);
					Datastore.put(curUser);
				}

				// Send back the data
				try {
					resp.getWriter()
							.write(APIUtils
									.generateJSONSuccessMessage(new JSONObject()
											.put(UserConstants.API_KEY,
													curUser.getApiKey()).put(
													UserConstants.TDUSER_ID,
													curUser.getKey().getId())));
				} catch (Exception e) {
					// Print the generic success
					resp.getWriter().write(
							APIUtils.generateJSONSuccessMessage());
				}

			} else
				// Send custom error
				resp.getWriter().write(
						APIUtils.generateJSONFailureMessage("No User Found."));
		} catch (Exception e) {
			// Send error
			resp.getWriter().write(APIUtils.generateJSONFailureMessage(e));
		}
	}
}
