<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@include file="/includes/userTagIncludes.jsp" %>
<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	String tagIDs = request.getParameter("tagID");
	long tagID = 0;
	Tag t = null;
	
	try{
		tagID = Long.parseLong(tagIDs);
		t = pm.getObjectById(Tag.class, tagID);
	}catch(NumberFormatException e){
		//tag ID not a long
	}catch(JDOObjectNotFoundException e){
		//tag with given ID not found
	}finally{
		pm.close();
	}
	
	if(t != null){%>
		<div class="tag_info dish_listing dish_splitter">
			<div class="tag_name">
				<% out.print(t.getName()); %>
<%				if(TDUserService.getUserLoggedIn()){%>
					<user:isUserInRole roles="${administrator},${standard},${advanced}" tagId="<%=t.getKey().getId() %>">
						&nbsp;&nbsp;
						<a href="editTag.jsp?tagID=<% out.print(t.getKey().getId()); %>">[edit]</a>
					</user:isUserInRole>
<%				}%>
			</div>
			<div class="tag_description">
				<% out.print(t.getDescription()); %>
			</div>
		</div>
	<%
  	}
%>