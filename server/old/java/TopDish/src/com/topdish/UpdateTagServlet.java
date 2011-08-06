package com.topdish;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.appengine.api.datastore.KeyFactory;
import com.google.gson.Gson;
import com.topdish.api.jdo.TagLite;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.TagConstants;
import com.topdish.exception.CuisineCannotHaveParentException;
import com.topdish.exception.ParentIsSelfException;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class UpdateTagServlet extends HttpServlet {

	private static final long serialVersionUID = -6416366011223346230L;
	private static final String TAG = UpdateTagServlet.class.getSimpleName();

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		try {
			final TDUser editor = TDUserService.getUser(req.getSession());

			long tagID = Integer.parseInt(req.getParameter("id"));
			final String name = req.getParameter("name");
			final String description = req.getParameter("description");
			int type = 0;
			int manualOrder = 0;
			final String ajax = req.getParameter("ajax");

			try {
				type = Integer.parseInt(req.getParameter("type"));
			} catch (NumberFormatException e) {
				// not an int
			}
			try {
				manualOrder = Integer.parseInt(req.getParameter("manual_order"));
			} catch (NumberFormatException e) {
				// not an int
			}

			Tag parent = null;
			if (req.getParameter("parentID") != null) {
				if (!req.getParameter("parentID").equals("")) {
					long parentID = Long.parseLong(req.getParameter("parentID"));
					parent = Datastore
							.get(KeyFactory.createKey(Tag.class.getSimpleName(), parentID));
				}
			}

			final Tag t = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), tagID));
			t.setName(name);
			t.setDescription(description);
			t.setLastEditor(editor.getKey());
			t.setDateModified(new Date());
			t.setType(type);
			t.setManualOrder(manualOrder);

			if (parent != null) {
				t.setParentTag(parent.getKey());
			}

			Datastore.put(t);

			// Send JSON response if ajax call.
			if (null != ajax && ajax.equals("true")) {
				try {
					final String tagStr = new Gson().toJson(new TagLite(t));
					final String json = APIUtils.generateJSONSuccessMessage(
							new JSONObject().put(TagConstants.TAG, tagStr), Alerts.TAG_UPDATED);
					resp.getWriter().write(json);
					return;
				} catch (JSONException e) {
					APIUtils.generateJSONFailureMessage(e);
				}
			}

			Alerts.setInfo(req, Alerts.TAG_UPDATED);
			resp.sendRedirect("index.jsp");
			return;
		} catch (ParentIsSelfException e) {
			final String ajax = req.getParameter("ajax");
			if(null != ajax && ajax.equals("true")){
				final String json = APIUtils.generateJSONFailureMessage(Alerts.TAG_PARENT_NOT_SELF);
				resp.getWriter().write(json);
				return;
			}
			
			Alerts.setError(req, Alerts.TAG_PARENT_NOT_SELF);
			resp.sendRedirect("index.jsp");
			return;
		} catch (CuisineCannotHaveParentException e) {
			final String ajax = req.getParameter("ajax");
			if(null != ajax && ajax.equals("true")){
				final String json = APIUtils.generateJSONFailureMessage(Alerts.TAG_CUISINE_NO_PARENT);
				resp.getWriter().write(json);
				return;
			}
			
			Alerts.setError(req, Alerts.TAG_CUISINE_NO_PARENT);
			resp.sendRedirect("index.jsp");
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
				final String json = APIUtils.generateJSONFailureMessage(Alerts.TAG_NOT_UPDATED);
				resp.getWriter().write(json);
				return;
			}
			
			Logger.getLogger(TAG).error(e.getMessage());
			Alerts.setError(req, Alerts.TAG_NOT_UPDATED);
			resp.sendRedirect("index.jsp");
			return;
		}
	}
}