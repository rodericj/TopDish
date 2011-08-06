package com.topdish.api;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.topdish.api.jdo.DishLite;
import com.topdish.api.util.ConvertToLite;
import com.topdish.jdo.Dish;
import com.topdish.util.PMF;

//returns all information about a dish including reviews
//parameters: dishID (id # of dish in question)

public class DishDetailServlet extends HttpServlet{
	private static final long serialVersionUID = 507151447822835258L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		//topdish1.appspot.com/api/dishDetail?id[]=1&id[]=2&id[]=5...

		String[] ids = req.getParameterValues("id[]");
		ArrayList<Dish> dishes = new ArrayList<Dish>();
		PersistenceManager pm = PMF.get().getPersistenceManager();

		for(int i = 0; i < ids.length; i++){
			try{
				Long id = Long.parseLong(ids[i]);
				dishes.add(pm.getObjectById(Dish.class, id));
			}catch(NumberFormatException e){
				//malformed input
			}catch(JDOObjectNotFoundException e){
				//object not found, skipping
			}
		}
		
		final List<DishLite> dishLites = ConvertToLite.convertDishes(dishes);
			
		if(dishLites.size() > 0){
			int cur = 1;
			resp.getWriter().print("[\n");
			for(DishLite d : dishLites){
				Gson gson = new Gson();
				String json = gson.toJson(d);
				resp.getWriter().print(json);
				if(cur < dishLites.size()){
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
