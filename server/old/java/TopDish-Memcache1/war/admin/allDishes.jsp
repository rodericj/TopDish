<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>

<h2>All Dishes</h2>
<%
	int oddEven = 0;
	PersistenceManager pm = PMF.get().getPersistenceManager();
	//show top 10 dishes
	String query = "select key from " + Dish.class.getName();
	List<Key> dishKeys = (List<Key>) pm.newQuery(query).execute();
	
	try{
		for (Key k : dishKeys) {
			String url = "partials/dishListingComplete.jsp?dishID=" + k.getId();
			url += "&oddEven=" + oddEven;
%>
			<jsp:include page="<%= url %>"/>
<%
	  		oddEven++;
		}
	}finally{
		pm.close();
	}
%>