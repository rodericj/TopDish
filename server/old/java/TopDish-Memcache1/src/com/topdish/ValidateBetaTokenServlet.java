package com.topdish;

import java.io.IOException;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.jdo.TDBetaInvite;
import com.topdish.util.PMF;

public class ValidateBetaTokenServlet extends HttpServlet {

	/**
	 * TODO: REMOVE WHEN YOU REALIZE THIS IS CRAZY
	 */
	static {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		TDBetaInvite curInvite = TDBetaInvite.getNewInvite();
		curInvite.setHash("HoneyOats");
		pm.makePersistent(curInvite);
		pm.close();
	}

	private static final long serialVersionUID = 7332133006187956670L;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		UserService userService = UserServiceFactory.getUserService();

		String token = req.getParameter("token");

		Query query = pm.newQuery(TDBetaInvite.class);
		query.setFilter("hashKey == hashParam");
		query.declareParameters("String hashParam");

		List<TDBetaInvite> invites = (List<TDBetaInvite>) query.execute(token);

		if (invites.size() > 0) {
			// token found
			if (!invites.get(0).getActive()) {
				// token is not used
				// forward to login page, redirect url has embedded token
				resp.sendRedirect(userService
						.createLoginURL("../index.jsp?token=" + token));
			} else {
				// token is used
				resp.sendRedirect("betaLogin.jsp?status=used");
			}
		} else {
			// check if token
			// redirect back to login page
			resp.sendRedirect("/betaLogin.jsp?status=notfound");
		}
	}
}