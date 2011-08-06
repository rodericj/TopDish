package com.topdish;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.jdo.Dish;
import com.topdish.util.PMF;

public class DeleteDishServlet extends HttpServlet {
	private static final long serialVersionUID = 97288601828117355L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		
		long dishID = Long.valueOf(req.getParameter("dishID"));
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Dish d = (Dish)pm.getObjectById(Dish.class, dishID);

		try {
			pm.deletePersistent(d);
		} finally {
			pm.close();
		}
		resp.sendRedirect("index.jsp");
	}
}