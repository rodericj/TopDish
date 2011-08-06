package com.topdish;

import java.io.IOException;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Flag;
import com.topdish.jdo.Photo;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.Review;
import com.topdish.jdo.TDUser;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;

public class AddFlagServlet extends HttpServlet{
	private static final long serialVersionUID = 4924551326574743200L;
	public void doPost(HttpServletRequest req, HttpServletResponse resp)throws IOException{
		PersistenceManager pm = PMF.get().getPersistenceManager();
		
		String reviewIDs = req.getParameter("reviewID");
		String photoIDs = req.getParameter("photoID");
		String dishIDs = req.getParameter("dishID");
		String restaurantIDs = req.getParameter("restaurantID");
		String restDishIds = req.getParameter("restDishId");
		String flagTypeS = req.getParameter("type");
		String comment = req.getParameter("comment");
		
		long reviewID = 0;
		long photoID = 0;
		long dishID = 0;
		long restaurantID = 0;
		long restDishId = 0;
		int flagType = 0;
		
		TDUser creator = null;
		Review review = null;
		Photo photo = null;
		Dish dish = null;
		Restaurant restaurant= null;
		try{
			reviewID = Long.parseLong(reviewIDs);
		}catch(NumberFormatException e){
			//not a long
		}
		
		try{
			photoID = Long.parseLong(photoIDs);
		}catch(NumberFormatException e){
			//not a long
		}
		
		try{
			dishID = Long.parseLong(dishIDs);
		}catch(NumberFormatException e){
			//not a long
		}
		
		try{
			restaurantID = Long.parseLong(restaurantIDs);
		}catch(NumberFormatException e){
			//not a long
		}
		
		try{
			restDishId = Long.parseLong(restDishIds);
		}catch(NumberFormatException e){
			//not a long
		}
		
		try{
			flagType = Integer.parseInt(flagTypeS);
		}catch(NumberFormatException e){
			//not an integer
		}
		
		try{
			creator = TDUserService.getUser(pm);
		}catch(UserNotLoggedInException e){
			//forward to log in page
			UserService userService = UserServiceFactory.getUserService();
			String url = "flag.jsp?reviewID=" + reviewID + "&photoID=" + photoID+ "&dishID=" + dishID+ "&restaurantID=" + restaurantID + "&type=" + flagType;
			resp.sendRedirect(userService.createLoginURL(url));
		}catch(UserNotFoundException e){
			//user not found...panic?
			//redirect back to front page
			resp.sendRedirect("index.jsp");
		}

		if(dishID != 0){
			try{
				dish = pm.getObjectById(Dish.class, dishID);
				Flag flag = new Flag(flagType, creator.getKey(), dish.getCreator(),comment);
				
				pm.makePersistent(flag);
				dish.addFlag(flag);
				creator.addFlag(flag);
				pm.makePersistent(dish);
				pm.makePersistent(creator);
			}finally{
				pm.close();
			}
			
			//TODO: find a better place to redirect
			resp.sendRedirect("dishDetail.jsp?dishID="+dishID);
		}
		else if(restaurantID != 0){
			try{
				restaurant = pm.getObjectById(Restaurant.class, restaurantID);
				Flag flag = new Flag(flagType, creator.getKey(), restaurant.getCreator(),comment);
				
				pm.makePersistent(flag);
				restaurant.addFlag(flag);
				creator.addFlag(flag);
				pm.makePersistent(restaurant);
				pm.makePersistent(creator);
			}finally{
				pm.close();
			}
			
			if(restDishId>0)
				resp.sendRedirect("dishDetail.jsp?dishID="+restDishId);
			else
				resp.sendRedirect("index.jsp");
		}
		else if(reviewID != 0 || photoID != 0){
			Flag flag = null;
			
			if(reviewID != 0){
				try{
					review = pm.getObjectById(Review.class, reviewID);
					flag = new Flag(flagType, creator.getKey(), review.getCreator(),comment);
					
					pm.makePersistent(flag);
					review.addFlag(flag);
					creator.addFlag(flag);
					pm.makePersistent(review);
					pm.makePersistent(creator);
				}finally{
					pm.close();
				}
				
				//TODO: find a better place to redirect
				resp.sendRedirect("index.jsp");
			}
			if(photoID != 0){
				try{
					photo = pm.getObjectById(Photo.class, photoID);
					flag = new Flag(flagType, creator.getKey(), photo.getCreator(),comment);
					
					pm.makePersistent(flag);
					photo.addFlag(flag);
					creator.addFlag(flag);
					pm.makePersistent(photo);
					pm.makePersistent(flag);
				}finally{
					pm.close();
				}
				
				//TODO: find a better place to redirect
				resp.sendRedirect("index.jsp");
			}
		}else{
			//redirect back to front page
			resp.sendRedirect("index.jsp");
		}
	}
}