package com.topdish;

import java.io.IOException;
import java.util.Date;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.exception.CuisineCannotHaveParentException;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.Alerts;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;

public class AddTagServlet extends HttpServlet {
	private static final long serialVersionUID = -3679213866889096509L;
	private static final String TAG = AddTagServlet.class.getSimpleName();

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		if(!TDUserService.isUserLoggedIn(req.getSession(true))){
			Alerts.setError(req, Alerts.PLEASE_LOGIN);
			resp.sendRedirect("login.jsp");
			return;
		}
		
		String name = "";
		if (req.getParameter("name") != null) {
			name = req.getParameter("name");
		}

		String description = "";
		if (req.getParameter("description") != null) {
			description = req.getParameter("description");
		}

		String parentKeyString = "";
		Key parentKey = null;
		if (req.getParameter("parentID") != null) {
			if (!req.getParameter("parentID").equals("")) {
				long parentID = Long.parseLong(req.getParameter("parentID"));
				Tag parent = Datastore.get(KeyFactory.createKey(
						Tag.class.getSimpleName(), parentID));
				parentKey = parent.getKey();
			}
		}

		String parentName = "";
		if (req.getParameter("parent") != null) {
			parentName = req.getParameter("parent");
		}

		int type = 0;
		if (req.getParameter("type") != null) {
			type = Integer.parseInt(req.getParameter("type"));
		}

		Date created = new Date();

		try {
			TDUser creator = TDUserService.getUser(req.getSession());
			Tag tag = new Tag(parentKey, name, description, type, created,
					creator.getKey());
			Datastore.put(tag);
			
			Alerts.setInfo(req, Alerts.TAG_ADDED);
			resp.sendRedirect("index.jsp");
			return;
		} catch (CuisineCannotHaveParentException e) {
			Alerts.setError(req, Alerts.TAG_CUISINE_NO_PARENT);
			resp.sendRedirect("addTag.jsp?name=" + name + "&description="
					+ description + "" + "&parentName=" + parentName
					+ "&parentID=" + parentKeyString + "&type=" + type);
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
		} catch(Exception e){
			Logger.getLogger(TAG).error(e.getMessage());
			Alerts.setError(req, Alerts.TAG_NOT_ADDED);
			resp.sendRedirect("index.jsp");
			return;
		}
	}
}