package com.topdish;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.KeyFactory;
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

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		if(!TDUserService.isUserLoggedIn(req.getSession(true))){
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}
		
		long tagID = Integer.parseInt(req.getParameter("id"));
		String name = req.getParameter("name");
		String description = req.getParameter("description");
		int type = 0;
		int manualOrder = 0;

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
				parent = Datastore.get(KeyFactory.createKey(
						Tag.class.getSimpleName(), parentID));
			}
		}

		try {
			final TDUser editor = TDUserService.getUser(req.getSession());

			Tag t = Datastore.get(KeyFactory.createKey(
					Tag.class.getSimpleName(), tagID));
			t.setName(name);
			t.setDescription(description);
			t.setLastEditor(editor.getKey());
			t.setDateModified(new Date());
			t.setType(type);
			t.setManualOrder(manualOrder);

			if (parent != null)
				t.setParentTag(parent.getKey());

			Datastore.put(t);

			Alerts.setInfo(req, Alerts.TAG_UPDATED);
			resp.sendRedirect("index.jsp");
			return;
		} catch (ParentIsSelfException e) {
			Alerts.setError(req, Alerts.TAG_PARENT_NOT_SELF);
			resp.sendRedirect("editTag.jsp?tagID=" + tagID);
			return;
		} catch (CuisineCannotHaveParentException e) {
			Alerts.setError(req, Alerts.TAG_CUISINE_NO_PARENT);
			resp.sendRedirect("editTag.jsp?tagID=" + tagID);
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
		}
	}
}