package com.topdish.api;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;

import com.beoui.geocell.model.Point;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.appengine.repackaged.org.json.JSONArray;
import com.google.appengine.repackaged.org.json.JSONException;
import com.google.appengine.repackaged.org.json.JSONObject;
import com.google.gson.Gson;
import com.topdish.api.jdo.DishLite;
import com.topdish.api.util.ConvertToLite;
import com.topdish.comparator.DishPosReviewsComparator;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDPoint;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.search.AbstractSearch;
import com.topdish.util.HumanTime;
import com.topdish.util.PMF;
import com.topdish.util.TDMathUtils;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

/**
 * Add a Top Dish Ajax Servlet for API
 * 
 */
public class TopDishAjaxServlet extends HttpServlet {
	private static final long serialVersionUID = 3305214228504501522L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		
		boolean namesAdded=false;
		StringBuilder sb=new StringBuilder();
		PersistenceManager pm = PMF.get().getPersistenceManager();
		int maxResults = 10;
		double maxDistance = 0.0; //meters // using 0 will return all distances up to max # of results
		
		double lat = 0.0;
		double lng = 0.0;

		
		String callType = req.getParameter("callType");
		String category = req.getParameter("categoryID");
	   	String price = req.getParameter("priceID");
	   	String lifestyle = req.getParameter("lifestyleID");
		String distanceS = req.getParameter("distance");
		String pageNumS = req.getParameter("page");
		
		//lat = Double.parseDouble(req.getParameter("lat"));
		//lng = Double.parseDouble(req.getParameter("lng"));
		String distString=req.getParameter("distance");
		if(null!=distString && distString.length()>0)
			maxDistance = Integer.parseInt(distString);
		maxResults = Integer.parseInt(req.getParameter("maxResults"));
		//Point userLoc = TDUserService.getUserLocation(req);
		Point userLoc = ((TDPoint)req.getSession().getAttribute("userLocationPoint")).getPoint();
		//TDPoint tdpoint=TDUserService.getUserLocation(req);	
		lat = userLoc.getLat();
		lng = userLoc.getLon();
		
	   	long priceID = 0;
	   	long categoryID = 0;
	   	long lifestyleID = 0;
	   	int pageNum = 0;
	   		
	   	try{
	   		priceID = Long.parseLong(price);
	   	}catch(NumberFormatException e){
	   		//not a long
	   	}
	   	try{
	   		categoryID = Long.parseLong(category);
	   	}catch(NumberFormatException e){
	   		//not a long
	   	}
	   	try{
	   		maxDistance = Double.parseDouble(distanceS);
	   	}catch(NumberFormatException e){
	   		//not a long
	   	}
	   	try{
	   		lifestyleID = Long.parseLong(lifestyle);
	   	}catch(NumberFormatException e){
	   		//not a long
	   	}
	   	try{
	   		pageNum = Integer.parseInt(pageNumS);
	   	}catch(NumberFormatException e){
	   		//not a long
	   	}	
		
		//compute distance from miles to meters
		maxDistance *= 1609.334;
		
	   	Tag categoryTag = null;
	   	Tag priceTag = null;
	   	Tag lifestyleTag = null;
		ArrayList<Key> tagKeysToFilter = new ArrayList<Key>();

		if(category != null && !category.equals(""))
		{
			categoryTag = (Tag)pm.getObjectById(Tag.class, categoryID);
			tagKeysToFilter.add(categoryTag.getKey());
		}
		
		if(price != null && !price.equals(""))
		{
			priceTag = (Tag)pm.getObjectById(Tag.class, priceID);
			tagKeysToFilter.add(priceTag.getKey());
		}
		
		
		if(lifestyle != null && !lifestyle.equals(""))
		{
			lifestyleTag = (Tag)pm.getObjectById(Tag.class, lifestyleID);
			tagKeysToFilter.add(lifestyleTag.getKey());
		}
		
	try{
		TDUser tdUser = TDUserService.getUser(pm);
		
		List<Dish> dishResults=null;
			
			if(null!=callType && callType.equals("search"))
			{
				String query = req.getParameter("searchWord");
				if(query.isEmpty())
					query = " ";
				
				query = query.toLowerCase();
				String[] qWords = query.split(" ");

				dishResults = TDQueryUtils.searchGeoItemsWithFilter(qWords, userLoc, maxResults, maxDistance, new Dish(), pm, pageNum * maxResults, tagKeysToFilter, new DishPosReviewsComparator());
			}
			else
			{
				dishResults = AbstractSearch.filterDishes(pm, maxResults, tagKeysToFilter, maxDistance,
						lat, lng, pageNum * maxResults, new DishPosReviewsComparator());
			}
			
	        
	        if(null!=dishResults && dishResults.size()>0)
	        {
	        	sb.append("<DishSearch>");
	        	sb.append("<count>"+pageNum+"</count>");
	        	sb.append("<Dishes>"); 
	        	namesAdded=true;
	        	for(Dish dish:dishResults)
	        	{
	        		 Restaurant r = PMF.get().getPersistenceManager().getObjectById(Restaurant.class, dish.getRestaurant());
	        		 List<Tag> tags = TDQueryUtils.getAll(dish.getTags(), new Tag());
	        		 Photo dishPhoto = null;

	        		if(dish.getPhotos() != null && dish.getPhotos().size() > 0){
	        			dishPhoto = PMF.get().getPersistenceManager().getObjectById(Photo.class, dish.getPhotos().get(0));
	        		}
	        		
	        		int vote = 0;
	        		PersistenceManager dishpm = PMF.get().getPersistenceManager();
	        		try
	        		{
	        			if(TDUserService.getUserLoggedIn())
	        				vote = TDUserService.getUserVote(TDUserService.getUser(dishpm).getKey(), dish.getKey());
	        		} catch (UserNotLoggedInException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (UserNotFoundException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} 
	        		finally 
	        		{
	        			dishpm.close();
	        		}
	        		
	        		BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	        		String blobUploadURL = blobstoreService.createUploadUrl("/addReview");
	        		
	        		
			        sb.append("<Dish>"); 
		            sb.append("<blobUploadURL>" +blobUploadURL + "</blobUploadURL>"); 
		            sb.append("<keyId>" + dish.getKey().getId() + "</keyId>"); 
		            sb.append("<name>" + StringEscapeUtils.escapeHtml(dish.getName()) + "</name>"); 
		            sb.append("<description>" + StringEscapeUtils.escapeHtml(dish.getDescription()) + "</description>");
		            sb.append("<distance>" + TDMathUtils.formattedGeoPtDistanceMiles(userLoc, dish.getLocation()) + "</distance>");
		            boolean isEditable=false;
		            if(UserServiceFactory.getUserService().isUserAdmin()){
		            	isEditable=true;
		            }
		            else
		            	isEditable=TDQueryUtils.isAccessible(Long.valueOf(dish.getKey().getId()), new Dish(), pm, tdUser);
		            if(isEditable)
		            	sb.append("<allowEdit>T</allowEdit>"); 
		            else
		            	sb.append("<allowEdit>F</allowEdit>");
		            if(TDUserService.getUserLoggedIn())
		            {
		            	sb.append("<userLoggedIn>L</userLoggedIn>");
		            }
		            else
		            {
		            	sb.append("<userLoggedIn>O</userLoggedIn>");
		            }
		            if(null!=dishPhoto)
		            {
		            	
		            	sb.append("<blobKey>" + ImagesServiceFactory.getImagesService().getServingUrl(dishPhoto.getBlobKey(), 98, true) + "</blobKey>");
		            	//sb.append("<blobKey>" + StringEscapeUtils.escapeHtml(dishPhoto.getBlobKey()+"") + "</blobKey>"); 
		            	sb.append("<photoExist>E</photoExist>");
		            }
		            else
		            {
		            	sb.append("<blobKey></blobKey>"); 
		            	sb.append("<photoExist>NE</photoExist>");
		            }
		            sb.append("<restAddrLine1>" + StringEscapeUtils.escapeHtml(r.getAddressLine1()) + "</restAddrLine1>");
		            sb.append("<restCity>" + StringEscapeUtils.escapeHtml(r.getCity()) + "</restCity>");
		            sb.append("<restState>" + StringEscapeUtils.escapeHtml(r.getState()) + "</restState>");
		            sb.append("<restId>" + r.getKey().getId() + "</restId>");
		            sb.append("<restName>" + StringEscapeUtils.escapeHtml(r.getName())+ "</restName>");
		            sb.append("<restNeighbourhood>" + StringEscapeUtils.escapeHtml(r.getNeighborhood()) + "</restNeighbourhood>");
		           // sb.append("<location>" + dish.getLocation() + "</location>");
		            sb.append("<latitude>" + dish.getLocation().getLat() + "</latitude>");
		            sb.append("<longitude>" + dish.getLocation().getLon() + "</longitude>");
		            sb.append("<posReviews>" + dish.getNumPosReviews() + "</posReviews>");
		            sb.append("<negReviews>" + dish.getNumNegReviews() + "</negReviews>");
		            String voteString="LTE0";
		            if(vote > 0)
		            	voteString="GT0";
		            else if(vote < 0)
		            	voteString="LT0";
		            sb.append("<voteString>" + voteString + "</voteString>");
		            if(tags != null && !tags.isEmpty())
		            {
		            	sb.append("<tagsEmpty>NE</tagsEmpty>");
		            }
		            else
		            	sb.append("<tagsEmpty>E</tagsEmpty>");
		            sb.append("<Tags>"); 
		            for(Tag tag:tags)
		        	{
			            sb.append("<tag><tagName>" + StringEscapeUtils.escapeHtml(tag.getName()) + "</tagName></tag>");
		        	}
		            sb.append("</Tags>"); 
		            Key lastReviewKey = TDQueryUtils.getLatestReviewByDish(dish.getKey());
                	if(null != lastReviewKey){
                		final Review lastReview = PMF.get().getPersistenceManager().getObjectById(Review.class, lastReviewKey);
                		if(lastReview.getDirection() == Review.POSITIVE_DIRECTION){
                			sb.append("<lastReviewType>P</lastReviewType>");
                		}
                		else
                			sb.append("<lastReviewType>N</lastReviewType>");
                		sb.append("<lastReview>" +HumanTime.approximately(System.currentTimeMillis() - lastReview.getDateCreated().getTime())+ "</lastReview>");
                		}
                	else
                	{
                		sb.append("<lastReviewType>E</lastReviewType>");
                	}
                	sb.append("<numReview>" + dish.getNumReviews() + "</numReview>");
                	
		            
		            sb.append("</Dish>");
		            
	        	}
	        	sb.append("</Dishes>"); 
	        	
	        	sb.append("</DishSearch>");
	        }
	        else
	        {
	        	namesAdded=true;
	        	sb.append("<dishMesg>No records found</dishMesg>"); 
	        }
		}
		catch(Exception e)
		{
			
		}
		finally{
			pm.close();
		}

		
		if (namesAdded) { 
			PrintWriter out = resp.getWriter();

			 resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?>"+sb.toString());
        } else { 
        	resp.setStatus(HttpServletResponse.SC_NO_CONTENT); 
        }
	}
}
