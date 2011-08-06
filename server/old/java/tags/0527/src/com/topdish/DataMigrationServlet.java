package com.topdish;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class DataMigrationServlet extends HttpServlet {
	private static final long serialVersionUID = -7365929129043334354L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {

		resp.getWriter().print("<html>");

//		PersistenceManager pm = PMF.get().getPersistenceManager();

//		Query q = pm.newQuery(Restaurant.class);
//		q.setFilter("url == :p");
//		List<Restaurant> allRestaurants = (List<Restaurant>) q.execute("http://www.");
//		
//		for(Restaurant r : allRestaurants){
//			resp.getWriter().print(r.getName() + " has a stupid URL: " + r.getUrl().getValue() + "<br />");
//			r.setUrl(new Link(""));
//			resp.getWriter().print("...it is now '" + r.getUrl().getValue() + "'<br />");
//		}
		
		//pm.close();
		resp.getWriter().print("migration complete");
		resp.getWriter().print("</html>");
	}
}