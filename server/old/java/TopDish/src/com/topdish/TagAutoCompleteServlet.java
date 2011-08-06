package com.topdish;

import java.io.IOException;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.jdo.TDUserRole;
import com.topdish.jdo.Tag;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

public class TagAutoCompleteServlet extends HttpServlet {
	private static final long serialVersionUID = 8728092297138840468L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		String name = req.getParameter("q");
		int limit = 10;

		if (req.getParameter("limit") != null)
			limit = Integer.parseInt(req.getParameter("limit"));

		final Set<Integer> tagTypes = new HashSet<Integer>();
		tagTypes.add(Tag.TYPE_ALLERGEN);
		tagTypes.add(Tag.TYPE_CUISINE);
		tagTypes.add(Tag.TYPE_GENERAL);
		tagTypes.add(Tag.TYPE_LIFESTYLE);
		
		// Only allow Admins to add Ingredient tags
		try {
			if(TDUserService.getUser(req.getSession()).getRole() == TDUserRole.ROLE_ADMIN)
				tagTypes.add(Tag.TYPE_INGREDIENT);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		final Set<Tag> searchResults = new HashSet<Tag>(TDQueryUtils.searchTagsByNameType(name,
				tagTypes, limit));

		resp.getWriter().print("[\n");
		if (searchResults != null && searchResults.size() > 0) {
			Iterator<Tag> tagI = searchResults.iterator();
			while (tagI.hasNext()) {
				final Tag t = tagI.next();
				if (tagI.hasNext()) {
					final String json = String.format(
							"[\"%s\", \"%s\", null], ", t.getKey().getId(),
							t.getName());
					resp.getWriter().print(json);
				} else {
					final String json = String.format("[\"%s\", \"%s\", null]",
							t.getKey().getId(), t.getName());
					resp.getWriter().print(json);
				}
			}
		}
		resp.getWriter().print("\n]");
	}
}