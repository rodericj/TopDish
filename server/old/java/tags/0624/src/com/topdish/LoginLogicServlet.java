package com.topdish;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.api.util.FacebookConstants;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.TDUser;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

/**
 * Logic behind choosing where to forward current user <br>
 * Figures out if this is an existing user, pairing user, or user in pergatory
 * 
 * @author <a href="mailto:Salil@topdish.com">Salil</a>
 * @author <a href="mailto:Randy@topdish.com">Randy</a>
 * 
 */
public class LoginLogicServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 8174504444947903566L;

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = LoginLogicServlet.class.getSimpleName();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException,
			IOException {

		TDUser tdUserObj = null;
		final User gUserObj = UserServiceFactory.getUserService().getCurrentUser();
		final String facebookId = String.valueOf(req.getSession().getAttribute(
				FacebookConstants.FACEBOOK_ID));

		// Whether or not facebook is logged in
		final boolean hasFacebook = TDUserService.isFacebookUser(req);
		// Whether or not facebook user is tied to TDUser
		final boolean isTDFBUser = (null != facebookId && null != TDQueryUtils
				.getUserForFacebookId(facebookId));
		// Whether or not google is logged in
		final boolean hasGoogle = null != gUserObj; //TDUserService.isGoogleUser(req);
		// Whether or not google user is a TDUser
		final boolean isTDGUser = (null != gUserObj && null != TDQueryUtils
				.getUserKeyByUserId(gUserObj.getUserId()));

		Logger.getLogger(TAG).info(
				"hasFacebook = " + hasFacebook + "\tisTDFBUser = " + isTDFBUser + "\thasGoogle = "
						+ hasGoogle + "\tisTDGUser = " + isTDGUser);

		try {
			tdUserObj = TDUserService.getUser(req.getSession(true));
		} catch (UserNotFoundException e) {
			// This is fine, user could be new
			Logger.getLogger(TAG).error(e.getMessage());
		} catch (UserNotLoggedInException e) {
			// This is also fine if user is authenticated with Facebook
			Logger.getLogger(TAG).error(e.getMessage());
		}

		// User is logged in on Facebook but is not tied to a Google or TDUser
		// Account
		if ((hasFacebook && !isTDFBUser) && (!hasGoogle && !isTDGUser)) {
			resp.sendRedirect("welcome.jsp");
		}
		// User is logged in on Google but is not tied to Facebook or TDUser
		// Account
		else if ((!hasFacebook && !isTDFBUser) && (hasGoogle && !isTDGUser)) {
			resp.sendRedirect("welcome.jsp");
		}
		// User is logged in on Facebook and has a TDUser Account but not Google
		// Account
		else if ((hasFacebook && isTDFBUser) && (!hasGoogle && !isTDGUser)) {
			resp.sendRedirect("index.jsp");
		}
		// User is logged in on Google and has a TDUser Account but not Facebook
		// Account
		else if ((!hasFacebook && !isTDFBUser) && (hasGoogle && isTDGUser)) {
			resp.sendRedirect("index.jsp");
		}
		// User is logged in on Facebook and Google and has a TDUser Account
		// tied to thier Facebook Account but not their Google Account
		else if ((hasFacebook && isTDFBUser) && (hasGoogle && !isTDGUser)) {
			if (null != tdUserObj) {
				TDUserService.pairGoogleFacebookUser(tdUserObj, gUserObj, facebookId);
				// TODO: status message that pair completed successfully
			}
			resp.sendRedirect("index.jsp");
		}
		// User is logged in on Facebook and Google and has TDUser Account tied
		// to their Google Account but not their Facebook Account
		else if ((hasFacebook && !isTDFBUser) && (hasGoogle && isTDGUser)) {
			if (null != tdUserObj) {
				TDUserService.pairGoogleFacebookUser(tdUserObj, gUserObj, facebookId);
				// TODO: status message that pair completed successfully
			}
			resp.sendRedirect("index.jsp");
		}

	}
}