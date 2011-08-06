<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@include file="/includes/userTagIncludes.jsp" %>
<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	long restID = Long.valueOf(request.getParameter("restID"));
	Restaurant r = (Restaurant)pm.getObjectById(Restaurant.class, restID);
	TDUser creator = pm.getObjectById(TDUser.class, r.getCreator());
	Tag cuisine = null;
	if(null != r.getCuisine())
		cuisine = pm.getObjectById(Tag.class, r.getCuisine());
%>
<div class="rmenu_cont dish_splitter">
	<h2><% out.print(r.getName()); %></h2>
	<user:isUserInRole roles="${administrator},${advanced},${standard}" restaurantId="${param.restID}">
		<a href="editRestaurant.jsp?restID=<%out.print(r.getKey().getId());%>">[Edit]</a>
	</user:isUserInRole>
<div class="restaurant_address">
	<% out.print(StringEscapeUtils.escapeHtml(r.getAddressLine1())); %>
</div>
<div class="restaurant_city">
	<% out.print(StringEscapeUtils.escapeHtml(r.getCity())); %>
</div>
<div class="restaurant_state">
	<% out.print(StringEscapeUtils.escapeHtml(r.getState())); %>
</div>
<div class="restaurant_neighborhood">
	<% out.print(StringEscapeUtils.escapeHtml(r.getNeighborhood())); %>
</div>
<div class="restaurant_phone">
	<% out.print(StringEscapeUtils.escapeHtml(r.getPhone().getNumber())); %>
</div>
<%
	if(null != cuisine){
%>
<div class="cuisine_type">
	Cuisine: <% out.print(StringEscapeUtils.escapeHtml(cuisine.getName())); %>
</div>
<%
	}
%>

<% 
	if(!r.getUrl().toString().equals("")){
%>
		<div class="restaurant_url">
			<a href="<% out.print(r.getUrl().toString()); %>">More Info</a>
		</div>

<%		
	}
%>
<br />
<p>Added by: <a href="userProfile.jsp?userID=<%=creator.getKey().getId()%>"><%=creator.getNickname() %></a>

</div>