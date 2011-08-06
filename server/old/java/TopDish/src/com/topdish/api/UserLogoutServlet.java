package com.topdish.api;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.topdish.util.TDUserService;

public class UserLogoutServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -6313294685796292281L;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		final String redirect = (null != req.getParameter("redirect") ? req
				.getParameter("redirect") : "../index.jsp");

		HttpSession session = req.getSession();

		// Check if the user is a facebook user
		if (null != session && TDUserService.isFacebookUser(session))
			// invalidate the current session
			session.invalidate();

		if (TDUserService.isGoogleUser(req))
			// redirect to logout url
			resp.sendRedirect(TDUserService.getGoogleLogoutURL(redirect));

		resp.sendRedirect(redirect);

	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException,
			IOException {

		final String redirect = (null != req.getParameter("redirect") ? req
				.getParameter("redirect") : "../index.jsp");

		HttpSession session = req.getSession();

		// Check if the user is a facebook user
		if (null != session && TDUserService.isFacebookUser(session))
			// invalidate the current session
			session.invalidate();

		if (TDUserService.isGoogleUser(req)){
			// redirect to logout url
			resp.sendRedirect(TDUserService.getGoogleLogoutURL(redirect));
			return;
		}

		resp.sendRedirect(redirect);
	}
}
