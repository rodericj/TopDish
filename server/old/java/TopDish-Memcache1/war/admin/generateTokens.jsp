<html><body>
<%@ page import="com.topdish.jdo.TDBetaInvite" %>
<%@ page import="com.topdish.jdo.TDUser" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.exception.UserNotFoundException" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%

//Generates up to 1000 tokens
PersistenceManager pm = PMF.get().getPersistenceManager();
UserService userService = UserServiceFactory.getUserService();

String numTokens = request.getParameter("num");

try{
	//only allow logged in users to generate tokens;
	TDUserService.getUser(pm);
	
	int num = 0; 
	try{
		num = Integer.parseInt(numTokens);
	}catch(NumberFormatException e){
		//not an integer
	}catch(NullPointerException e){
		//numTokens was null!
	}

	if(num <= 1000){
		for(int i = 0; i < num; i++) {
		    TDBetaInvite curInvite = TDBetaInvite.getNewInvite();
		    pm.makePersistent(curInvite);
		    out.println(curInvite.getHash() + "<br />");
		}
	}
}catch(UserNotLoggedInException e){
	//make user log in! what a sneaky bastard.
	response.sendRedirect(userService.createLoginURL("../generateTokens.jsp?num=" + numTokens));
}catch(UserNotFoundException e){
	//panic
}
%>
</body></html>