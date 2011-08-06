package com.topdish.api;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;

public class UserLoginServlet extends HttpServlet {

	private static final long serialVersionUID = -635420597647785547L;

	@SuppressWarnings("unchecked")
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		// TODO: Update this servlet to properly authenticate with
		// OpenID/Facebook; issue real API keys stored in an APIKey table to
		// keep track of usage.
		final String email = req.getParameter("email").toLowerCase();
		final String apiKey = UUID.randomUUID().toString().trim();

		// Query for the email address
		final PersistenceManager pm = PMF.get().getPersistenceManager();
		final Query q = pm.newQuery(TDUser.class);
		q.setFilter("email == :email");
		final List<TDUser> results = (List<TDUser>) q.execute(email);

		if (!results.isEmpty()) {

			// email found
			final TDUser curUser = results.get(0);
			if(null == curUser.getApiKey()){
				curUser.setApiKey(apiKey);
				pm.makePersistent(curUser);
			}

			resp.getWriter().write(String.valueOf(curUser.getApiKey()));
		} else {
			resp.getWriter().write("Nothing to see here.");
		}
		
		pm.close();
	}
}
