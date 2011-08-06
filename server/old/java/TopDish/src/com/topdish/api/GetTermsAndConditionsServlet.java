package com.topdish.api;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet to get the current Terms and Conditions of using TopDish
 * 
 * @author Salil
 * 
 */
public class GetTermsAndConditionsServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -6303572071588808222L;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// Redirect to HTML file with plain text
		resp.sendRedirect("/TermsAndConditions.html");
	}
}
