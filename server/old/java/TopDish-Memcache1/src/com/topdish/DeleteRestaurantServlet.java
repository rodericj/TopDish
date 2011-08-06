package com.topdish;

import java.io.IOException;
import java.util.Collection;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;

public class DeleteRestaurantServlet extends HttpServlet {
	private static final long serialVersionUID = 9155168219151480031L;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		long restID = Long.valueOf(req.getParameter("restID"));
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Restaurant r = (Restaurant)pm.getObjectById(Restaurant.class, restID);
		Collection<Key> dishKeys = TDQueryUtils.getDishKeysByRestaurant(r.getKey());
		List<Dish> dishes;

		try {
			if(dishKeys.size() > 0){
				Query q = pm.newQuery(Dish.class, ":key.contains(key)");
				dishes = (List<Dish>) q.execute(dishKeys);
				pm.deletePersistentAll(dishes);
			}
			
			pm.deletePersistent(r);
		} finally {
			pm.close();
		}
		resp.sendRedirect("index.jsp");
	}
}