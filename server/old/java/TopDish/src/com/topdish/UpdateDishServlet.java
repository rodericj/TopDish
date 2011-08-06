package com.topdish;

import java.io.IOException;
import java.util.Arrays;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.appengine.api.datastore.KeyFactory;
import com.google.gson.Gson;
import com.topdish.api.jdo.DishLite;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.DishConstants;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class UpdateDishServlet extends HttpServlet {
	private static final long serialVersionUID = 3426591936548809459L;
	private static final String TAG = UpdateDishServlet.class.getSimpleName();

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		try {
			final TDUser editor = TDUserService.getUser(req.getSession());

			final String ajax = req.getParameter("ajax");
			final String dishIDs = req.getParameter("dishID");
			final String name = req.getParameter("name");
			final String description = req.getParameter("description");
			final String categoryIDs = req.getParameter("categoryID");
			final String priceIDs = req.getParameter("priceID");
			final String tagList = req.getParameter("tagList");
			long categoryID = 0;
			long priceID = 0;
			long dishID = 0;

			try {
				dishID = Long.parseLong(dishIDs);
			} catch (NumberFormatException e) {
				// not a long
				Logger.getLogger(TAG).error("Failed to parse Dish Id " + dishIDs + " as a Long");
			}
			try {
				priceID = Long.parseLong(priceIDs);
			} catch (NumberFormatException e) {
				// not a long
				Logger.getLogger(TAG).error("Failed to parse Price Id " + priceIDs + " as a Long");
			}

			try {
				categoryID = Long.parseLong(categoryIDs);
			} catch (NumberFormatException e) {
				// not a long
				Logger.getLogger(TAG).error(
						"Failed to parse Category Id " + priceIDs + " as a Long");
			}

			final Dish d = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), dishID));
			d.setName(name);
			d.setDescription(description);
			d.setLastEditor(editor.getKey());
			d.setDateModified(new Date());
			d.removeAllTags();
			d.setCategory(Datastore
					.get(KeyFactory.createKey(Tag.class.getSimpleName(), categoryID)).getKey());
			d.setPrice(Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), priceID))
					.getKey());

			// Traverse Tags
			if (!tagList.isEmpty())
				for (final String id : Arrays.asList(tagList.split("[,;]+")))
					d.addTag(Datastore.get(
							KeyFactory.createKey(Tag.class.getSimpleName(), Long.parseLong(id)))
							.getKey());

			Datastore.put(d);

			// Send JSON response if ajax call.
			if (null != ajax && ajax.equals("true")) {
				try {
					final String dishStr = new Gson().toJson(new DishLite(d));
					final String json = APIUtils.generateJSONSuccessMessage(
							new JSONObject().put(DishConstants.DISH, dishStr), Alerts.DISH_UPDATED);
					resp.getWriter().write(json);
					return;
				} catch (JSONException e) {
					APIUtils.generateJSONFailureMessage(e);
				}
			}

			Alerts.setInfo(req, Alerts.DISH_ADDED);
			resp.sendRedirect("dishDetail.jsp?dishID=" + dishIDs);
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
				final String json = APIUtils.generateJSONFailureMessage(Alerts.DISH_NOT_UPDATED);
				resp.getWriter().write(json);
				return;
			}

			Alerts.setError(req, Alerts.DISH_NOT_UPDATED);
			resp.sendRedirect("index.jsp");
			return;
		}
	}
}