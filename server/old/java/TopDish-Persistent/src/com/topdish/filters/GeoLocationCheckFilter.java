/**
 * 
 */
package com.topdish.filters;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.geo.GeoUtils;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDPoint;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

/**
 * This class acts as a request filter and performs checks for setting default(IP based) or user preferred geo locations in the user session
 * @author nikhil_malleri
 *
 */
public class GeoLocationCheckFilter implements Filter{
	
	@Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain) throws IOException, ServletException {
		HttpServletRequest req = (HttpServletRequest)request;
		HttpServletResponse resp = (HttpServletResponse)response;
		TDPoint locationPoint = null;
		
		String ipAddress = req.getRemoteAddr();
		
//		System.out.println("ipaddress = "+ipAddress);
//		System.out.println("userLatitude="+req.getSession().getAttribute("userLatitude"));
//		System.out.println("userLongitude="+req.getSession().getAttribute("userLongitude"));
//		System.out.println("userAddress="+req.getSession().getAttribute("userAddress"));
//		System.out.println("userLocationPoint="+req.getSession().getAttribute("userLocationPoint"));
		
		try{
			String locationStr = req.getParameter("loc")==null?null:req.getParameter("loc").trim();
			
			if(req.getSession().getAttribute("userAddress") != null && locationStr!=null && !locationStr.equalsIgnoreCase(req.getSession().getAttribute("userAddress").toString().trim()  )){
				//if user has changed the address string in search box, get the lat/long corresponding to the new address string
				GeoUtils geoUtils = new GeoUtils();
				locationPoint = geoUtils.reverseAddress(locationStr);
			}
			else if(req.getSession().getAttribute("userLatitude") == null || req.getSession().getAttribute("userLongitude") == null){
				// else if no lat/long values has been set in session, get the default based on user's IP address. This would be the case when the user initially comes to the site before browsing any pages 
				GeoUtils geoUtils = new GeoUtils();
				locationPoint = geoUtils.reverseIP(ipAddress);
			}
			
			if(locationPoint!=null){
				req.getSession().setAttribute("userLatitude", locationPoint.getLat());
				req.getSession().setAttribute("userLongitude", locationPoint.getLon());
				req.getSession().setAttribute("userAddress", locationPoint.getAddress());
				req.getSession().setAttribute("userLocationPoint", locationPoint);
				
				//set lat/long values in cookie
				Cookie latCookie = new Cookie("lat", locationPoint.getLat()+"");
				Cookie lonCookie = new Cookie("lng", locationPoint.getLon()+"");
				latCookie.setPath("/");
				lonCookie.setPath("/");
				resp.addCookie(latCookie);
				resp.addCookie(lonCookie);
			}
		}
		catch(Exception e){e.printStackTrace();}
		
		
		
        filterChain.doFilter(request, response);
    }
	
	@Override
    public void destroy() {}

	@Override
	public void init(FilterConfig arg0) throws ServletException {}
}
