package com.topdish;

import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Tag;
import com.topdish.util.Datastore;
import com.topdish.util.PMF;

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

	/**
	 * DEBUG
	 */
	private static final boolean DEBUG = false;

	@SuppressWarnings("unchecked")
	@Override
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		// Get the Tag ID
		final long tagID = Long.parseLong(req.getParameter("tagID"));

		if (DEBUG)
			System.out.println("Finding Tag with ID: " + tagID);

		// Pull get object from Datastore
		Tag t = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), tagID));

		// Find all dishes with this Tag
		final String queryString = "SELECT key FROM "
				+ Dish.class.getName();
		final Query q = PMF.get().getPersistenceManager().newQuery(queryString);
		q.setFilter("tags.contains(:tagParam)");
		final Set<Key> dishKeys = new HashSet<Key>(
				(Collection<Key>) q.execute(t.getKey()));
		final Set<Dish> dishes = Datastore.get(dishKeys);

		if (DEBUG)
			System.out.println("Total number of dishes found: "
					+ dishKeys.size());

		try {

			// Traverse Dishes found
			for (Dish d : dishes) {
				if (DEBUG)
					System.out.println("Removing " + t.getName() + " from "
							+ d.getName());

				// Remove tag from each dish
				d.removeTag(t.getKey());
			}

			// Put the dishes back in the Datastore
			Datastore.put(dishes);

			// Delete the Tag from the Datastore
			Datastore.delete(t.getKey());

		} catch (Exception e) {
			e.printStackTrace();
		}

		// Send user back to the allTags page
		resp.sendRedirect("allTags.jsp");
	}
}