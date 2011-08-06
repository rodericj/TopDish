package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.topdish.adminconsole.TopDishConstants;
import com.topdish.dao.RestaurantDAO;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;

public class DeleteRestaurantServlet extends HttpServlet {
	private static final long serialVersionUID = 9155168219151480031L;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		long restID = Long.valueOf(req.getParameter("restID"));
		String callType=req.getParameter("callType");
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Restaurant r = TDQueryUtils.getEntity(pm, restID, new Restaurant());

			try {
				List<Restaurant> restList=(List<Restaurant>)req.getSession(true).getAttribute("restList");
				if(null!=restList && restList.size()>0)
				{
					List<Restaurant> restL=new ArrayList<Restaurant>();
					for(Restaurant rest:restList)
					{
						if(null!=r && rest.getKey().getId()!=r.getKey().getId())
						{
							restL.add(rest);
						}
					}
					req.getSession(true).setAttribute("restList", restL);
				}
				//pm.deletePersistent(r);
				if(null!=r)
				{
					List<Key> restKey=new ArrayList<Key>();
					restKey.add(r.getKey());
					RestaurantDAO rDAO=new RestaurantDAO();
					rDAO.deleteEntities(pm, restKey);
				}
			} finally {
				pm.close();
			}


		if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
		{
			resp.setContentType("text/xml");
		    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>S</mesg>");
		}
		else
			resp.sendRedirect("index.jsp");
	}
}