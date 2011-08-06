package com.topdish;

import java.io.IOException;
import java.util.Iterator;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TagUtils;

public class IngredientAutoCompleteServlet extends HttpServlet {
	private static final long serialVersionUID = 8074639974082018589L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException 
	{
		String name = req.getParameter("q");
		int limit = 20;
		
		if(req.getParameter("limit") != null)
			limit = Integer.parseInt(req.getParameter("limit"));
		
		List<Tag> searchResults = null;
		PersistenceManager pm = PMF.get().getPersistenceManager();
		
		searchResults = TagUtils.searchTagsByName(pm, name, Tag.TYPE_INGREDIENT, limit);
		resp.getWriter().print("[\n");
		if(searchResults != null && searchResults.size() > 0)
		{
			try
			{
				Iterator<Tag> i = searchResults.iterator();
				while(i.hasNext())
				{
					Tag t = i.next();
					String json = String.format("[%s, \"%s\", null]" + (i.hasNext() ? ", " : ""), t.getKey().getId(), t.getName());
					resp.getWriter().print(json);
				}

			} finally
			{
				pm.close();
			}
		}
		resp.getWriter().print("]");
	}
	
}