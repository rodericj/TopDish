package com.topdish;

import java.io.IOException;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;

public class DataMigrationServlet extends HttpServlet {
	private static final long serialVersionUID = -7365929129043334354L;

	@SuppressWarnings("unchecked")
	public void doGet(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {

		PersistenceManager pm = PMF.get().getPersistenceManager();

		//Set all email addresses to lowercase
		List<TDUser> users;
		resp.getWriter().print("<html>");
		
		Query q = pm.newQuery(TDUser.class);
		users = (List<TDUser>)q.execute();
		
		for(TDUser u: users){
			resp.getWriter().print("updating user: " + u.getKey().getId() + " ...");
			u.setEmail(u.getEmail().toLowerCase());
			resp.getWriter().print("complete<br />");
		}
		
		pm.makePersistentAll(users);
		
		resp.getWriter().print("migration complete");
		pm.close();
		resp.getWriter().print("</html>");
	}
}