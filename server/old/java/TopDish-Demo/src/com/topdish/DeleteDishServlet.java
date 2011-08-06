package com.topdish;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Review;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;

public class DeleteDishServlet extends HttpServlet {
	private static final long serialVersionUID = 97288601828117355L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Dish dishToBeDeleted = (Dish) pm.getObjectById(Dish.class, 
			                                       Long.valueOf(req.getParameter("dishID")));
		try {
    		    for (Key reviewKey : TDQueryUtils.getReviewKeysByDish(dishToBeDeleted.getKey())) {
    			
    		        pm.deletePersistent((Review) pm.getObjectById(Review.class, reviewKey.getId()));
			pm.deletePersistent(dishToBeDeleted);
    		    }
		} finally {
			pm.close();
		}
		
		resp.sendRedirect("index.jsp");
	}
}