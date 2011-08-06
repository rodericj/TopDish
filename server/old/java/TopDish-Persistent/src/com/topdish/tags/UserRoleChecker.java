package com.topdish.tags;

import javax.jdo.PersistenceManager;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.TDUserRole;
import com.topdish.jdo.Tag;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;
import com.topdish.util.PMF;

public class UserRoleChecker extends TagSupport{

	/**
	 * The roles passed from the the tag. 
	 * Roles are comma separated values e.g. roles="0,2".
	 * Required attribute
	 */
	private String roles;
	
	/**
	 * Dish Id passes from the tag e.g. dishId="59"
	 * Optional attribute  
	 */
	private String dishId;
	
	/**
	 * Restaurant ID passed from the tag e.g. restaurantId="23"
	 * Optional attribute
	 */
	private String restaurantId;
	
	/**
	 * Dishes Tag ID passed from the tag e.g. tagId="23"
	 * Optional attribute
	 */
	private String tagId;
	
	/**
	 * Action value passed from the tag.
	 * Action can be edit/delete/add or any other action defined later on
	 */
	private String action;
	
	
	private boolean isAccessAllowed;
	
	@Override
	public int doEndTag() throws JspException {
		return EVAL_PAGE;
	}

	@Override
	public int doStartTag() throws JspException {
	 	User user = UserServiceFactory.getUserService().getCurrentUser();
	 	int loggedInUserRole = TDUserRole.ROLE_STANDARD;  // default
	 	isAccessAllowed = true;
	 	
	 	if(user!=null){
	 		if(roles!=null){
	 			//check logged-in user's role
	 			if(UserServiceFactory.getUserService().isUserAdmin()){
	 				loggedInUserRole = TDUserRole.ROLE_ADMIN;
	 				return EVAL_BODY_INCLUDE;
	 			}
	 			else{
	 				 				
	 				TDUser tdUser = null;
	 				PersistenceManager pm = PMF.get().getPersistenceManager();
	 				
	 				
	 				
	 				try{
	 					tdUser = TDUserService.getUser(pm);
	 					loggedInUserRole = tdUser.getRole();
	 					
	 					if(action!=null )
		 				{
	 						if(action.equalsIgnoreCase("delete"))
		 						return SKIP_BODY;
	 						else if(action.equalsIgnoreCase("rotate"))
	 						{
	 		 					if(dishId!=null){
	 		 						isAccessAllowed=TDQueryUtils.isAccessible(Long.valueOf(dishId), new Dish(), pm, tdUser);
	 		 					}
	 						}
		 				}
	 					
	 					// check if dishId or restaurantId is present as an attribute. If present, validate whether this user is the owner 
	 					if(dishId!=null){
	 						isAccessAllowed=TDQueryUtils.isAccessible(Long.valueOf(dishId), new Dish(), pm, tdUser);
	 					}
	 					else if(restaurantId!=null){
	 						isAccessAllowed=TDQueryUtils.isAccessible(Long.valueOf(restaurantId), new Restaurant(), pm, tdUser);
	 					}
	 					else if(tagId!=null){
	 						isAccessAllowed=TDQueryUtils.isAccessible(Long.valueOf(tagId), new Tag(), pm, tdUser);
	 					}	
	 				}
	 				catch(UserNotFoundException e1){
	 					return SKIP_BODY;
	 				}
	 				catch(UserNotLoggedInException e1){
	 					return SKIP_BODY;
	 				}
	 			}
	 			
	 			// check permission
	 			String[] userRoles = roles.split(",");
	 			
	 			for(String role:userRoles){
	 				int roleVal = -1;
	 				try{
	 					roleVal = Integer.parseInt(role);
	 				}catch(Exception e){}
	 				
		 			if(roleVal == TDUserRole.ROLE_STANDARD && loggedInUserRole == TDUserRole.ROLE_STANDARD && isAccessAllowed){
	 					return EVAL_BODY_INCLUDE;
	 				}
	 				else if(roleVal == TDUserRole.ROLE_ADVANCED && loggedInUserRole == TDUserRole.ROLE_ADVANCED && isAccessAllowed){
	 					return EVAL_BODY_INCLUDE;
	 				}

	 			}
	 		}
	 	}
	 	
	 	return SKIP_BODY;
	}

	public String getRoles() {
		return roles;
	}

	public void setRoles(String roles) {
		this.roles = roles;
	}

	public String getDishId() {
		return dishId;
	}

	public void setDishId(String dishId) {
		this.dishId = dishId;
	}

	public String getRestaurantId() {
		return restaurantId;
	}

	public void setRestaurantId(String restaurantId) {
		this.restaurantId = restaurantId;
	}

	public String getTagId() {
		return tagId;
	}

	public void setTagId(String tagId) {
		this.tagId = tagId;
	}

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}
	
	

}
