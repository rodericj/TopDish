<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.topdish.jdo.TDBetaInvite" %>
<%@ page import="com.topdish.util.PMF" %>
<%
	
	// Redirect to Splash if User is not logged in.
	if(UserServiceFactory.getUserService().getCurrentUser() == null) {
		response.sendRedirect("splash.jsp");
	}else{
		//if user comes with beta token, check that it is still available
		String token = request.getParameter("token");
		if(token != null && !token.equals("")){
			UserService userService = UserServiceFactory.getUserService();
			
			Query query = PMF.get().getPersistenceManager().newQuery(TDBetaInvite.class);
			query.setFilter("hashKey == hashParam");
			query.declareParameters("String hashParam");
	
			List<TDBetaInvite> invites = (List<TDBetaInvite>) query.execute( token );		
			
			//if token is valid, continue on to adding user
			if(invites.size() > 0){
				//token found
				if(invites.get(0).getActive()){
					//token is used, bounce user
					response.sendRedirect("betaLogin.jsp?status=used");
				}
			}
		}
		
		//page number
		String pageS = request.getParameter("page");
		int pageNum = 0;
		try{
			pageNum = Integer.parseInt(pageS);
		}catch(NumberFormatException e){
			//not an int
		}
		
		%>
		<jsp:include page="header.jsp">
			<jsp:param name="token" value="<%= token %>"/>
		</jsp:include>
		<jsp:include page="toprated.jsp">
			<jsp:param name="page" value="<%= pageNum %>"/>
		</jsp:include>
		<jsp:include page="footer.jsp"/>
		<%
	}
%>
