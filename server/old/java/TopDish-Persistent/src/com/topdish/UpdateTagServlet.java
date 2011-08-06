package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.adminconsole.TopDishConstants;
import com.topdish.exception.CuisineCannotHaveParentException;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;
import com.topdish.util.ParentIsSelfException;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

public class UpdateTagServlet extends HttpServlet {
	
	private static final long serialVersionUID = -6416366011223346230L;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		
		PersistenceManager pm = PMF.get().getPersistenceManager();
		
		long tagID = Integer.parseInt(req.getParameter("id"));
		String name = req.getParameter("name");
		String description = req.getParameter("description");
		int type = 0;
		int manualOrder = 0;
		
		String callType=req.getParameter("callType");
		
		try{
			type = Integer.parseInt(req.getParameter("type"));
		}catch(NumberFormatException e){
			//not an int
		}
		try{
			manualOrder = Integer.parseInt(req.getParameter("manual_order"));
		}catch(NumberFormatException e){
			//not an int
		}
		
		Tag parent = null;
		if(req.getParameter("parentID") != null){
			if(!req.getParameter("parentID").equals("")){
				long parentID = Long.parseLong(req.getParameter("parentID"));
				parent = TDQueryUtils.getEntity(pm, parentID, new Tag());
			}
		}
		
		Date date = new Date();
		
		TDUser editor;
		try {
			editor = TDUserService.getUser(pm);

			Tag t = TDQueryUtils.getEntity(pm, tagID, new Tag());
			
			if(null!=t)
			{
				t.setName(name);
				t.setDescription(description);
				t.setLastEditor(editor.getKey());
				t.setDateModified(date);
				t.setType(type);
				t.setManualOrder(manualOrder);
				if(parent != null)
					t.setParentTag(parent.getKey());
			}
			List<Tag> tagList=(List<Tag>)req.getSession(true).getAttribute("tagList");
			if(null!=tagList && tagList.size()>0)
			{
				List<Tag> tagL=new ArrayList<Tag>();
				for(Tag tag:tagList)
				{
					if(null!=t && tag.getKey().getId()==t.getKey().getId())
					{
						TDUser userObj =null;
						try{
							userObj=(TDUser)pm.getObjectById(TDUser.class,t.getCreator().getId());
						}
						catch(Exception e)
						{
							System.err.println("User does not exists");
						}
						if(null!=userObj)
						{
							if(null==t.getCreatorName() || (null!=t.getCreatorName() && t.getCreatorName().length()==0))
								t.setCreatorName(userObj.getNickname().toString());
						}
						t.setTypeString(t.getTagTypeName());
						tagL.add(t);
					}
					else
					{
						tagL.add(tag);
					}
				}
				req.getSession().setAttribute("tagList", tagL);
			}
			try {
				if(null!=t)
					pm.makePersistent(t);
			} finally {
				pm.close();
			}
			if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
			{
				resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>Tag updated successfully!!!</mesg>");
			}
			else
				resp.sendRedirect("index.jsp");
		} catch (ParentIsSelfException e){
			//TODO: show error to user
			if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
			{
				resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>Tag could not be updated!!!</mesg>");
			}
			else
				resp.sendRedirect("editTag.jsp?tagID=" + tagID);
		} catch (CuisineCannotHaveParentException e){
			//TODO: show error to user
			if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
			{
				resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>Tag could not be updated!!!</mesg>");
			}
			else
				resp.sendRedirect("editTag.jsp?tagID=" + tagID);
		} catch (UserNotLoggedInException e) {
			//forward to log in screen
			UserService userService = UserServiceFactory.getUserService();
			String redirectURL = "../editTag.jsp?tagID=" + tagID;
			if(null!=callType && callType.equals(TopDishConstants.CALL_TYPE_AJAX))
			{
				resp.setContentType("text/xml");
			    resp.getWriter().write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?><mesg>Tag could not be updated!!!</mesg>");
			}
			else
				resp.sendRedirect(userService.createLoginURL(redirectURL));
		} catch (UserNotFoundException e) {
			//do nothing
		}
	}
}