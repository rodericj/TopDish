package com.topdish;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.beoui.geocell.model.Point;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import com.topdish.jdo.TDPoint;
import com.topdish.util.TDUserService;

public class YelpRestaurantAutoComplete extends HttpServlet 
{
	private static final long serialVersionUID = -1492815565845836404L;
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException 
	{
		String yelpAPIKey = "uQ-6pLlOtEUcb07XzN-eSw";
		String name = req.getParameter("q");
		String latS = req.getParameter("lat"); // can return ""
		String lngS = req.getParameter("lng");
		String maxResults = req.getParameter("limit");
		double lat = 0;
		double lng = 0;
		int maxDistance = 10; //miles
		Point p = null;
		
		try 
		{
			lat = Double.valueOf(latS);
			lng = Double.valueOf(lngS);
		} 
		catch (Exception e) 
		{
			if(TDUserService.getUserLoggedIn())
				p = ((TDPoint)req.getSession().getAttribute("userLocationPoint")).getPoint();
				//p = TDUserService.getUserLocation(req);
		}

		if(p != null)
		{
			lat = p.getLat();
			lng = p.getLon();
		}
		
		URL url = new URL("http://api.yelp.com/business_review_search?term="+name+"&category=restaurants&lat="+lat+"&long="+lng+"&radius="+maxDistance+"&limit="+maxResults+"&ywsid="+yelpAPIKey);
		
        // Make connection
        URLConnection con = url.openConnection();
        con.setDoOutput(true);
        
        // get result
        BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream()));
        
        Gson gson = new Gson();
        JsonElement jse = null;  
        jse = new JsonParser().parse(br);  
        br.close();
       
        JsonArray jsa = jse.getAsJsonObject().getAsJsonArray("businesses");  
        
        resp.getWriter().print("[\n");;
        for (int i= 0; i<jsa.size(); i++ ) 
        {  
        	JsonElement jobj = jsa.get(i);
        	String json = gson.toJson(jobj);
    		resp.getWriter().print(json);
    		
        	if(i < jsa.size() - 1)
        		resp.getWriter().print(",\n");
			else
				resp.getWriter().print("\n");
        	//resp.getWriter().print(" ");
        	//resp.getWriter().print("<img src='"+yelpImg+"' alt='yelp rating' />");  
        	
        	//resp.getWriter().print("\n\n");
        } 
        resp.getWriter().print("]");
	}
}
