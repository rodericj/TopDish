package com.topdish;

import java.io.IOException;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.jdo.Dish;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;

public class DeleteTagServlet extends HttpServlet {
	private static final long serialVersionUID = 118008074043339407L;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		
		long tagID = Long.valueOf(req.getParameter("tagID"));
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Tag t = (Tag)pm.getObjectById(Tag.class, tagID);
		
		Query q = pm.newQuery(Dish.class);
		q.setFilter("tags.contains(:tagParam)");
		List<Dish> dishes = (List<Dish>) q.execute(t.getKey());
		
		try {
			//firstly remove tag from all dishes found
			for(Dish d : dishes){
				d.removeTag(t.getKey());
			}
			//then remote tag
			pm.deletePersistent(t);
		} finally {
			pm.close();
		}
		resp.sendRedirect("allTags.jsp");
	}
}