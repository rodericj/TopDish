package com.topdish;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.api.util.APIUtils;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Review;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class DeleteReviewServlet extends HttpServlet {

	private static final long serialVersionUID = 97288601828117355L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		try {
			TDUserService.getUser(req.getSession(true));
			final String ajax = req.getParameter("ajax");
			final long reviewID = Long.parseLong(req.getParameter("reviewID"));
			final Key revKey = KeyFactory.createKey(Review.class.getSimpleName(), reviewID);
			final Review review = Datastore.get(revKey);
			final Dish dish = Datastore.get(review.getDish());

			// remove review from dish
			dish.removeReview(review);
			// delete review
			Datastore.delete(revKey);
			// save dish
			Datastore.put(dish);
			
			// Send JSON response if ajax call.
			if (null != ajax && ajax.equals("true")) {
				final String json = APIUtils.generateJSONSuccessMessage(Alerts.REVIEW_DELETED);
				resp.getWriter().write(json);
				return;
			}

			Alerts.setInfo(req, Alerts.REVIEW_DELETED);
			resp.sendRedirect("index.jsp");
			return;
		} catch (UserNotLoggedInException e) {
			// forward to login screen
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		} catch (UserNotFoundException e) {
			// forward to login screen
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		} catch (Exception e) {
			final String ajax = req.getParameter("ajax");
			if(null != ajax && ajax.equals("true")){
				final String json = APIUtils.generateJSONFailureMessage(Alerts.REVIEW_NOT_DELETED);
				resp.getWriter().write(json);
				return;
			}
			
			Alerts.setInfo(req, Alerts.REVIEW_NOT_DELETED);
			resp.sendRedirect("index.jsp");
			return;
		}
	}
}
