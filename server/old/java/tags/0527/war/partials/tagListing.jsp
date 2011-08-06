<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>

<%
	String tagIDs = request.getParameter("tagID");
	long tagID = 0;
	Tag t = null;
	
	try{
		tagID = Long.parseLong(tagIDs);
		t = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), tagID));
	}catch(NumberFormatException e){
		//tag ID not a long
	}catch(JDOObjectNotFoundException e){
		//tag with given ID not found
	}
	
	if(t != null){%>
		<div class="tag_info dish_listing dish_splitter">
			<div class="tag_name">
				<% out.print(t.getName()); %>
<%				if(TDUserService.isUserLoggedIn(request.getSession(true))){%>
						&nbsp;&nbsp;
						<a href="editTag.jsp?tagID=<% out.print(t.getKey().getId()); %>">[edit]</a>
<%				}%>
			</div>
			<div class="tag_description">
				<% out.print(t.getDescription()); %>
			</div>
		</div>
	<%
  	}
%>