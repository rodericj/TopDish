package com.topdish;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.memcache.MemcacheServiceFactory;

public class ClearMemcacheServlet extends HttpServlet{
	private static final long serialVersionUID = 6279010725008897793L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
		throws IOException{
		
		MemcacheServiceFactory.getMemcacheService().clearAll();
		resp.getWriter().print("memcache is cleared!");
	}
}
