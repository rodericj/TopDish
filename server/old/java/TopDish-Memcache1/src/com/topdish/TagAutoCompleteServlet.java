package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TagUtils;

public class TagAutoCompleteServlet extends HttpServlet {
	private static final long serialVersionUID = 8728092297138840468L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String name = req.getParameter("q");
		int limit = 10;
		
		if(req.getParameter("limit") != null)
			limit = Integer.parseInt(req.getParameter("limit"));
		
		PersistenceManager pm = PMF.get().getPersistenceManager();
		List<Integer> tagTypes = new ArrayList<Integer>();
		tagTypes.add(Tag.TYPE_ALLERGEN);
		tagTypes.add(Tag.TYPE_CUISINE);
		tagTypes.add(Tag.TYPE_GENERAL);
		tagTypes.add(Tag.TYPE_LIFESTYLE);
		List<Tag> searchResults = TagUtils.searchTagsByNameType(pm, name, tagTypes, limit);
				
		resp.getWriter().print("[\n");
		if(searchResults != null && searchResults.size() > 0)
		{
			try
			{
				for(int i = 0; i < searchResults.size(); i++)
				{
					Tag t = searchResults.get(i);
					String json = String.format("[\"%s\", \"%s\", null]" + (i < searchResults.size()-1 ? ", " : ""), t.getKey().getId(), t.getName());
					resp.getWriter().print(json);
				}

			} finally
			{
				pm.close();
			}
		}
		resp.getWriter().print("\n]");
	}
}