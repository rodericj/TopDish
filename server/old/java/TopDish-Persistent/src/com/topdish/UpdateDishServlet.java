package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;


import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.adminconsole.TopDishConstants;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

public class UpdateDishServlet extends HttpServlet
{
	private static final long serialVersionUID = 3426591936548809459L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException 
    	{
		
		String dishIDs = req.getParameter("dishID");
		String name = req.getParameter("name");
		String description = req.getParameter("description");
		String categoryIDs = req.getParameter("categoryID");
		String priceIDs = req.getParameter("priceID");
		String tagList = req.getParameter("tagList");
		
		String callType=req.getParameter("callType");
		Date date = new Date();
		long categoryID = 0;
		long priceID = 0;
		long dishID = 0;
		
		try{
			dishID = Long.parseLong(dishIDs);
		}catch(NumberFormatException e){
			//not a long
		}
		try{
			priceID = Long.parseLong(priceIDs);
		}catch(NumberFormatException e){
			//not a long
		}
		try{
			categoryID = Long.parseLong(categoryIDs);
		}catch(NumberFormatException e){
			//not a long
		}
		
		try 
		{
			String tagString="";
			PersistenceManager pm = PMF.get().getPersistenceManager();
			TDUser editor = TDUserService.getUser(pm);
			Dish d = TDQueryUtils.getEntity(pm, dishID, new Dish());
			if(null!=d)
			{
				d.setName(name);
				d.setDescription(description);
				d.setLastEditor(editor.getKey());
				d.setDateModified(date);
				d.removeAllTags(); 
				Tag category=TDQueryUtils.getEntity(pm, categoryID, new Tag());
				Tag price=TDQueryUtils.getEntity(pm, priceID, new Tag());
				if(null!=category)
				{
					d.addTag(category.getKey());
					tagString=category.getName();
				}
				if(null!=price)
				{
					d.addTag(price.getKey());
					if(tagString.trim().length()>0)
						tagString+=","+price.getName();
					else
						tagString+=price.getName();
				}
				
				if(!tagList.equals("")){
					for(String id : Arrays.asList(tagList.split("[,;]+"))){
						try{
						Tag tag=(Tag)PMF.get().getPersistenceManager().getObjectById(Tag.class, Integer.parseInt(id));
						d.addTag(tag.getKey());
						if(tagString.trim().length()>0)
							tagString+=","+tag.getName();
						else
							tagString+=tag.getName();
						}
						catch(Exception e)
						{
							System.err.println("Tag id does not exists");
						}
					}
					
				}

				pm.makePersistent(d);
			}
			
			
						
			
			
			List<Dish> dishList=(List<Dish>)req.getSession(true).getAttribute("dishList");
			if(null!=dishList && dishList.size()>0)
			{
				List<Dish> dishL=new ArrayList<Dish>();
				for(Dish dish:dishList)
				{
					if(null!=d && dish.getKey().getId()==d.getKey().getId())
					{
						TDUser userObj =null;
						try{
							userObj=(TDUser)pm.getObjectById(TDUser.class,d.getCreator().getId());
						}
						catch(Exception e)
						{
							System.err.println("User does not exists");
						}
						if(null!=userObj)
						{
							if(null==d.getCreatorName() || (null!=d.getCreatorName() && d.getCreatorName().length()==0))
								d.setCreatorName(userObj.getNickname().toString());
						}
						
						int totalReviews=d.getNumPosReviews()+d.getNumNegReviews();
						d.setTotalReviews(totalReviews);
						d.setTagString(TDQueryUtils.getTagString(d.getTags()));
						
						dishL.add(d);
					}
					else
					{
						dishL.add(dish);
					}
				}
				req.getSession().setAttribute("dishList", dishL);
			}
			pm.close();

			if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
			{
				if(tagString.length()>0)
					tagString=StringEscapeUtils.escapeHtml(tagString);
				resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><dish><mesg>Dish Updated successfully!!!</mesg><tagString>"+tagString+"</tagString></dish>");
			}
			else
				resp.sendRedirect("dishDetail.jsp?dishID=" + dishIDs);
		} catch (UserNotLoggedInException e) {
			//forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			String url = "../editDish.jsp?dishID=" + dishIDs;
			if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
			{
				resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>Dish could not be updated!!!</mesg>");
			}
			else
				resp.sendRedirect(userService.createLoginURL(url));
		} catch (UserNotFoundException e) {
						//do nothing
			System.err.println("Err is:"+e.getMessage());
		} catch (JDOObjectNotFoundException e){
			e.printStackTrace();
		}
	}
}