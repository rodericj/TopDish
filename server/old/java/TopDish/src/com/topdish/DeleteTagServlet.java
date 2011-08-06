package com.topdish;

import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.api.util.APIUtils;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

/**
 * Deletes a {@link Tag}. <br>
 * Checks if the Tag is currently attached to any {@link Dish}es and removes it
 * from there. <br>
 * TODO: Remove from {@link Restaurant}s
 * 
 * @author Randy (edited by Jen/Salil)
 * 
 */
public class DeleteTagServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 118008074043339407L;

	private static final String TAG = DeleteTagServlet.class.getSimpleName();
	
	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

		try {
			TDUserService.getUser(req.getSession(true));
			final long tagID = Long.parseLong(req.getParameter("tagID"));
			final String ajax = req.getParameter("ajax");

			Logger.getLogger(TAG).info("Finding Tag with ID: " + tagID);

			// Pull get object from Datastore
			final Tag t = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), tagID));

			// Find all dishes with this Tag
			final String queryString = "SELECT key FROM " + Dish.class.getName();
			final Query q = PMF.get().getPersistenceManager().newQuery(queryString);
			q.setFilter("tags.contains(:tagParam)");
			final Set<Key> dishKeys = new HashSet<Key>((Collection<Key>) q.execute(t.getKey()));
			final Set<Dish> dishes = Datastore.get(dishKeys);

			Logger.getLogger(TAG).info("Total number of dishes found: " + dishKeys.size());

			// Traverse Dishes found
			for (final Dish d : dishes) {
				Logger.getLogger(TAG).info("Removing " + t.getName() + " from " + d.getName());

				// Remove tag from each dish
				d.removeTag(t.getKey());
			}

			// Put the dishes back in the Datastore
			Datastore.put(dishes);

			// Delete the Tag from the Datastore
			Datastore.delete(t.getKey());

			// Send JSON response if ajax call.
			if (null != ajax && ajax.equals("true")) {
				final String json = APIUtils.generateJSONSuccessMessage(Alerts.TAG_DELETED);
				resp.getWriter().write(json);
				return;
			}
			
			// Send user back to the allTags page
			resp.sendRedirect("allTags.jsp");
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
			Logger.getLogger(TAG).error(e.getMessage());
			
			final String ajax = req.getParameter("ajax");
			if (null != ajax && ajax.equals("true")) {
				final String json = APIUtils.generateJSONFailureMessage(Alerts.TAG_NOT_DELETED);
				resp.getWriter().write(json);
				return;
			}
			// Send user back to the allTags page
			resp.sendRedirect("allTags.jsp");
			return;
		}
	}
}