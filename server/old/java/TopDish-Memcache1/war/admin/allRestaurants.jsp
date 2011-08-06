<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>

<h2>All Restaurants</h2>
<%
	int oddEven = 0;
	PersistenceManager pm = PMF.get().getPersistenceManager();
	//show all restaurants
	String query = "select key from " + Restaurant.class.getName();
	List<Key> restKeys = (List<Key>) pm.newQuery(query).execute();
	
	for (Key k : restKeys) {
		String url = "partials/restaurantListing.jsp?restID=" + k.getId();
			url += "&oddEven=" + oddEven;
%>
			<jsp:include page="<%= url %>"/>
<%
	  		oddEven++;
	}
	pm.close();
%>
