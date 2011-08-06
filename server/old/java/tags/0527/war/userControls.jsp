<%@ page import="com.topdish.jdo.TDUser" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="com.topdish.exception.UserNotFoundException" %>

<div class="user_strong_text"><a href="about.jsp">ABOUT</a></div>
<%
	String thisURL = request.getRequestURI();
	if(request.getQueryString() != null)
		thisURL += "?" + request.getQueryString();
	
	if(TDUserService.isUserLoggedIn(request.getSession(true))) {
		//user is logged in, display profile link
		TDUser tdUser = null;
		try{
			tdUser = TDUserService.getUser(request.getSession(true));
			%>
			<div>Logged in as: <a href="userProfile.jsp"><% out.write(tdUser.getNickname()); %></a>.</div>
			<%
		}catch(UserNotLoggedInException e){
			//user not logged in
			response.sendRedirect("multiLogin.jsp");
		}catch(UserNotFoundException e){
			//user logged in but new to topdish
			response.sendRedirect("multiLogin.jsp");
		}		
    } else {
		%>
		<div class="user_strong_text"><a href="login.jsp">LOGIN</a></div>
		<% 
    }
%>