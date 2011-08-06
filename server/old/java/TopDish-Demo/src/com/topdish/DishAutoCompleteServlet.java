package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.search.AbstractSearch;
import com.topdish.util.PMF;

public class DishAutoCompleteServlet extends HttpServlet {
	private static final long serialVersionUID = 7270956707603091302L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String name = req.getParameter("q");
		int limit = 10;
		long restID = 0;
		String restIDs = "";
		String limitS = "";
		PersistenceManager pm = PMF.get().getPersistenceManager();
		List<Dish> searchResults;
		
		if(req.getParameter("restID") != null){
			restIDs = req.getParameter("restID");
		}
		
		if(req.getParameter("limit") != null){
			limitS = req.getParameter("limit");
		}
		
		StringTokenizer st = new StringTokenizer(name, " ");
		ArrayList<String> queryWords = new ArrayList<String>();
		
		while(st.hasMoreTokens()){
			String token = st.nextToken();
			
			if(!token.equals(" ") && !token.equals(""))
				queryWords.add(token.trim());
		}

		try{
			
			limit = Integer.parseInt(limitS);
			restID = Long.parseLong(restIDs);
			
			if(restID <= 0)
				throw new IllegalArgumentException("Restaurant ID must be greater than zero.");
		
			Restaurant rest = pm.getObjectById(Restaurant.class, restID);
			searchResults = AbstractSearch.searchDishesByRestaurant(queryWords, pm, limit, rest.getKey());
			
			if(searchResults != null && searchResults.size() > 0){
				
					resp.getWriter().print("[\n");
					for(int i = 0; i < searchResults.size(); i++){
						Dish d = searchResults.get(i);
						Gson gson = new Gson();
						String json = gson.toJson(d);
						resp.getWriter().print(json);
						if(i < searchResults.size() - 1){
							resp.getWriter().print(",\n");
						}else{
							resp.getWriter().print("\n");
						}
					}
					resp.getWriter().print("]");
			}
		}catch(NumberFormatException e){
			throw new IllegalArgumentException("Restaurant ID must be greater than zero.");
		}finally{
			pm.close();
		}
	}
}