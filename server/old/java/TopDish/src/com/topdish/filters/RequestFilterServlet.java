/**
 * 
 */
package com.topdish.filters;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

/**
 * @author nikhil_malleri
 *
 */
public class RequestFilterServlet implements Filter{
	
	@Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain) throws IOException, ServletException {
		HttpServletRequest req = (HttpServletRequest)request;
		HttpServletResponse resp = (HttpServletResponse)response;
		if(!TDUserService.isAdmin())
		{
			try{
				if(req.getRequestURI().contains("editDish.jsp") || req.getRequestURI().contains("updateDish")){
					String dishId = req.getParameter("dishID");
					if(dishId!=null){
						if(!TDQueryUtils.isAccessible(req, Long.valueOf(dishId), new Dish())){
							resp.sendRedirect("error.jsp?e=dishedit");
							return;
						}
					}
				}
				else if(req.getRequestURI().contains("editRestaurant.jsp") || req.getRequestURI().contains("updateRestaurant")){
					String restId = req.getParameter("restID");
					if(restId!=null){
						if(!TDQueryUtils.isAccessible(req, Long.valueOf(restId), new Restaurant())){
							resp.sendRedirect("error.jsp?e=restedit");
							return;
						}
					}
				}
				else if(req.getRequestURI().contains("/rotatePhoto") ){
					String dishID = req.getParameter("dishID");
					if(dishID!=null){
						if(!TDQueryUtils.isAccessible(req, Long.valueOf(dishID), new Dish())){
							resp.sendRedirect("error.jsp?e=photorotat");
							return;
						}
					}
				}
				else if(req.getRequestURI().contains("deleteDish")){
					resp.sendRedirect("error.jsp?e=dishdel");
					return;
				}
				else  if(req.getRequestURI().contains("editTag.jsp")){
					String tagID = req.getParameter("tagID");
					if(tagID!=null){
						if(!TDQueryUtils.isAccessible(req, Long.valueOf(tagID), new Restaurant())){
							resp.sendRedirect("error.jsp?e=tagedit");
							return;
						}
					}
				}
									
			}
			catch(Exception e){}
		}
		
		filterChain.doFilter(request, response);
        
    }
	
	@Override
    public void destroy() {}

	@Override
	public void init(FilterConfig arg0) throws ServletException {}
	  
}
