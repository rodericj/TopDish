package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.adminconsole.TopDishConstants;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;

public class DeleteTagServlet extends HttpServlet {
	private static final long serialVersionUID = 118008074043339407L;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		
		long tagID = Long.valueOf(req.getParameter("tagID"));
		String callType=req.getParameter("callType");
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Tag t = TDQueryUtils.getEntity(pm, tagID, new Tag());
		List<Dish> dishes=null;
		if(t!=null)
		{
			Query q = pm.newQuery(Dish.class);
			q.setFilter("tags.contains(:tagParam)");
			dishes = (List<Dish>) q.execute(t.getKey());
		}
		try {
			//firstly remove tag from all dishes found
			if(null!=t && null!=dishes && dishes.size()>0)
			{
				for(Dish d : dishes){
					d.removeTag(t.getKey());
				}
			}
			//then remote tag
			List<Tag> tagList=(List<Tag>)req.getSession(true).getAttribute("tagList");
			if(null!=tagList && tagList.size()>0)
			{
				List<Tag> tagL=new ArrayList<Tag>();
				for(Tag tag:tagList)
				{
					if(null!=t && tag.getKey().getId()!=t.getKey().getId())
					{
						tagL.add(tag);
					}
				}
				req.getSession().setAttribute("tagList", tagL);
			}
			if(null!=t)
				pm.deletePersistent(t);
		} finally {
			pm.close();
		}
		if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
		{
			resp.setContentType("text/xml");
		    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>S</mesg>");
		}
		else
			resp.sendRedirect("allTags.jsp");
	}
}