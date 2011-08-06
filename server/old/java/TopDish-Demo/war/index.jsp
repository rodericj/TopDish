<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.topdish.jdo.TDBetaInvite" %>
<%@ page import="com.topdish.util.PMF" %>
<%		
	//page number
	String pageS = request.getParameter("page");
	int pageNum = 0;
	try{
		pageNum = Integer.parseInt(pageS);
	}catch(NumberFormatException e){
		//not an int
	}
%>
<jsp:include page="header.jsp" />
<jsp:include page="toprated.jsp">
	<jsp:param name="page" value="<%= pageNum %>"/>
</jsp:include>
<jsp:include page="footer.jsp"/>

