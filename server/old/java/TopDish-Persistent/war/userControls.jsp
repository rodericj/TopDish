<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.topdish.jdo.TDUser" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="com.topdish.exception.UserNotFoundException" %>

<div class="user_strong_text"><a href="about.jsp">ABOUT</a></div>
<%
	UserService userService = UserServiceFactory.getUserService();
	String thisURL = request.getRequestURI();
	if(request.getQueryString() != null)
		thisURL += "?" + request.getQueryString();
	
	if (request.getUserPrincipal() != null) {
		TDUser tdUser = null;
		try{
			tdUser = TDUserService.getUser(PMF.get().getPersistenceManager());
			%>
			<div>Logged in as: <a href="userProfile.jsp"><% out.write(tdUser.getNickname()); %></a>.</div>
			<%
		}catch(UserNotLoggedInException e){
			//user not logged in
		}catch(UserNotFoundException e){
			//user logged in but new to topdish
			%>
			<script type="text/javascript">
				$(document).ready(function() {
					$("#welcome_dialog").dialog("open");
				});	
			</script>
			<%
		}		
    } else {
%>
<div class="user_strong_text"><a href="<% out.write(userService.createLoginURL(thisURL)); %>">LOGIN</a></div>
<% 
    }
%>