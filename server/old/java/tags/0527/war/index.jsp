<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.topdish.jdo.TDBetaInvite" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TokenUtils" %>
<%
	
		//page number
		String pageS = request.getParameter("page");
		int pageNum = 0;
		try{
			pageNum = Integer.parseInt(pageS);
		}catch(NumberFormatException e){
			//not an int
		}
		
		String code = (null != request.getParameter("code") ? request.getParameter("code") : new String());
	
		%>
		<jsp:include page="header.jsp">
			<jsp:param name="code" value="<%= code %>"/>
		</jsp:include>
		<jsp:include page="toprated.jsp">
			<jsp:param name="page" value="<%= pageNum %>"/>
		</jsp:include>
		<jsp:include page="footer.jsp"/>
