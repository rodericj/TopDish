package com.topdish.api;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.UserConstants;
import com.topdish.jdo.TDUser;
import com.topdish.util.TDUserService;

/**
 * {@link GoogleLoginServlet} handles an API login for Google Auth
 * 
 * @author <a href="mailto:Salil@topdish.com">Salil</a>
 * 
 */
public class GoogleLoginServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -4649871688102792808L;

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = GoogleLoginServlet.class.getSimpleName();

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// Note: POST comes from the Client
		doLogic(req, resp);
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException,
			IOException {

		// Note: GET Comes from Google Auth
		doLogic(req, resp);

	}

	/**
	 * Handles both a POST and a GET <br>
	 * Note: This is required as the POST will come from a Mobile User, where as
	 * the GET will occur on redirect from Google Auth
	 * 
	 * @param req
	 *            - the request
	 * @param resp
	 *            - the response
	 * @throws ServletException
	 * @throws IOException
	 */
	private void doLogic(HttpServletRequest req, HttpServletResponse resp) throws ServletException,
			IOException {

		// Get Writer
		final PrintWriter pw = resp.getWriter();

		try {

			// Get redirection url
			final String redirect = req.getParameter(APIConstants.REDIRECT);

			Logger.getLogger(TAG).info("Final Redirection is: " + redirect);

			// If login was successful (or user is already logged in)
			if (TDUserService.isGoogleUser(req)) {
				Logger.getLogger(TAG).info("User logged in, redirecting to: " + redirect);

				try {
					// Get the user
					final TDUser user = TDUserService.getUser(req.getSession());

					// Redirect to given url with the TDUser Id
					resp.sendRedirect(redirect + (redirect.contains("?") ? "&" : "?")
							+ UserConstants.TDUSER_ID + "=" + user.getKey().getId() + "&"
							+ UserConstants.API_KEY + "="
							+ URLEncoder.encode(user.getApiKey(), "UTF-8"));
				} catch (Exception e) {
					// Ensure some kind of redirect
					resp.sendRedirect(redirect);
				}
			} else {
				// Create a url
				final String url = TDUserService.getGoogleLoginURL("/api/googleAuth?redirect="
						+ redirect);
				Logger.getLogger(TAG).info(
						"User not logged in. Sending to Google Auth, URL: " + url);

				// Redirect to that url
				resp.sendRedirect(url);
			}
		} catch (Exception e) {
			e.printStackTrace();
			Logger.getLogger(TAG).error(e.getMessage());
			// Notify of error
			pw.write(APIUtils.generateJSONFailureMessage(e));
		} finally {
			pw.flush();
			pw.close();
		}
	}

}
