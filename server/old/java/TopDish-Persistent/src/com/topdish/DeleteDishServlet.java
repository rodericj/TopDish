package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.topdish.adminconsole.TopDishConstants;
import com.topdish.dao.DishDAO;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;

public class DeleteDishServlet extends HttpServlet {
	private static final long serialVersionUID = 97288601828117355L;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		
		long dishID = Long.valueOf(req.getParameter("dishID"));
		String callType=req.getParameter("callType");
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Dish d = TDQueryUtils.getEntity(pm, dishID, new Dish());
		Restaurant rest = TDQueryUtils.getEntity(pm, d.getRestaurant().getId(), new Restaurant());
		
		try {
			// deleting dish should delete the dish from the restaurant
			if(null!=rest && null!=d)
			{
				rest.removeDish(d.getKey());
				pm.makePersistent(rest);
			}
			

			
			List<Dish> dishList=(List<Dish>)req.getSession(true).getAttribute("dishList");
			if(null!=dishList && dishList.size()>0)
			{
				List<Dish> dishL=new ArrayList<Dish>();
				for(Dish dish:dishList)
				{
					if(null!=d && dish.getKey().getId()!=d.getKey().getId())
					{
						dishL.add(dish);
					}
				}
				req.getSession().setAttribute("dishList", dishL);
			}
			//pm.deletePersistent(d);
			if(null!=d)
			{
				List<Key> dishKey=new ArrayList<Key>();
				dishKey.add(d.getKey());
				DishDAO dDAO=new DishDAO();
				dDAO.deleteEntities(pm, dishKey);
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