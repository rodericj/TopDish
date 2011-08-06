<%@ page import="com.topdish.jdo.TDUser" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>

<%
	try {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		final String id = request.getParameter("userId");
		TDUser user = pm.getObjectById(TDUser.class, Long.valueOf(id));
		user.setFacebookId(request.getParameter("facebookId"));
		pm.makePersistent(user);
		pm.close();
		%> Success <%
		
	} catch(Exception e) {
		e.printStackTrace();
		%> Failed <%
	}
%>
<br />
<p />
<br />
<a href="/admin/testAPI.jsp">Back to Test API </a>