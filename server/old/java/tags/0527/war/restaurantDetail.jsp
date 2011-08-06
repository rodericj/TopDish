<%@ page import="java.util.Collection" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>


<jsp:include page="header.jsp" />

<%
	long restID = 0;
	Restaurant r = null;
	Collection<Key> dishKeys = null;
	
	try{
		restID = Long.parseLong(request.getParameter("restID"));
	}catch(NumberFormatException e){
		//not a long
	}
	try{
		r = Datastore.get(KeyFactory.createKey(Restaurant.class.getSimpleName(), restID));
		dishKeys = TDQueryUtils.getDishKeysByRestaurant(r.getKey());
	}catch(JDOObjectNotFoundException e){
		response.sendRedirect("index.jsp");
	}
%>

<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/restaurantBio.jsp">
			<jsp:param name="restID" value="<%= restID %>" />
		</jsp:include> 
		<jsp:include page="/blocks/newDishAtRestaurant.jsp">
			<jsp:param name="restID" value="<%= restID %>" />
		</jsp:include>
		<jsp:include page="/blocks/singleDishMap.jsp" />
	</div>
	<div class="col2">
<%
	if(dishKeys != null && dishKeys.size() > 0){
		for (Key k : dishKeys) {%>
				<jsp:include page="partials/dishListingComplete.jsp">
					<jsp:param name="dishID" value="<%= k.getId() %>" />
				</jsp:include>
<%			}
	}%>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />