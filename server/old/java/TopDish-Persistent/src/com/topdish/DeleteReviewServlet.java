package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.topdish.adminconsole.TopDishConstants;
import com.topdish.dao.ReviewDAO;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Review;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;

public class DeleteReviewServlet extends HttpServlet {

		private static final long serialVersionUID = 97288601828117355L;

		@SuppressWarnings("unchecked")
		public void doPost(HttpServletRequest req, HttpServletResponse resp) 
	    	throws IOException {
			
			long reviewID = Long.valueOf(req.getParameter("reviewID"));
			String callType=req.getParameter("callType");
			PersistenceManager pm = PMF.get().getPersistenceManager();
			Review rev = TDQueryUtils.getEntity(pm, reviewID, new Review());
			Dish dish = null;
			
			try{
				dish=pm.getObjectById(Dish.class, rev.getDish().getId());
			}
			catch(Exception e)
			{
				System.err.println("Dish does not exists!!!");
			}
			
			try {
				// deleting review should delete the review from the dish
				if(null!=dish && null!=rev)
				{
					dish=dish.removeReview(rev);
					pm.makePersistent(dish);
				}
				
				
				List<Review> reviewList=(List<Review>)req.getSession(true).getAttribute("reviewList");
				if(null!=reviewList && reviewList.size()>0)
				{
					List<Review> reviewL=new ArrayList<Review>();
					for(Review review:reviewList)
					{
						if(null!=rev && review.getKey().getId()!=rev.getKey().getId())
						{
							reviewL.add(review);
						}
					}
					req.getSession(true).setAttribute("reviewList", reviewL);
				}
				//pm.deletePersistent(rev);
				if(null!=rev )
				{
					List<Key> revKeys=new ArrayList<Key>();
					revKeys.add(rev.getKey());
					ReviewDAO revDAO=new ReviewDAO();
					revDAO.deleteEntities(pm, revKeys);
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
