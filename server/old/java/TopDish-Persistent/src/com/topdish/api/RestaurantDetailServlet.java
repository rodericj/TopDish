package com.topdish.api;

import java.io.IOException;
import java.util.ArrayList;

import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.topdish.api.jdo.RestaurantLite;
import com.topdish.jdo.Restaurant;
import com.topdish.util.PMF;

//returns all information about a restaurant including dishes

public class RestaurantDetailServlet extends HttpServlet{
	private static final long serialVersionUID = -4026395514197779694L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		//topdish1.appspot.com/api/restaurantDetail?id[]=1&id[]=2&id[]=5...
		
		String[] ids = req.getParameterValues("id[]");
		ArrayList<Restaurant> restaurants = new ArrayList<Restaurant>();
		PersistenceManager pm = PMF.get().getPersistenceManager();
		ArrayList<RestaurantLite> restLites = new ArrayList<RestaurantLite>();
		for(int i = 0; i < ids.length; i++){
			try{
				Long id = Long.parseLong(ids[i]);
				restaurants.add(pm.getObjectById(Restaurant.class, id));
			}catch(NumberFormatException e){
				//malformed input
			}catch(JDOObjectNotFoundException e){
				//object not found, skipping
			}
		}
		
		for(Restaurant r : restaurants){
			restLites.add(new RestaurantLite(r));
		}
			
		if(restLites.size() > 0){
			int cur = 1;
			resp.getWriter().print("[\n");
			for(RestaurantLite r : restLites){
				Gson gson = new Gson();
				String json = gson.toJson(r);
				resp.getWriter().print(json);
				if(cur < restLites.size()){
					resp.getWriter().print(",\n");
				}else{
					resp.getWriter().print("\n");
				}
				cur++;
			}
			resp.getWriter().print("]");
		}
		
	}
}
