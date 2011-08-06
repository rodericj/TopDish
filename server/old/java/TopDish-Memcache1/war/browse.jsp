<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.search.AbstractSearch" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<jsp:include page="header.jsp" />
<div class="colleft">
	<div class="col1">
	</div>
	<div class="col2">
		<jsp:include page="/blocks/filterBar.jsp"/>
<%
//search options
	//cuisine*
	//price*
	//distance*
	//time

	PersistenceManager pm = PMF.get().getPersistenceManager();
	Point userLoc = TDUserService.getUserLocation(request);
	int maxResults = 10;
	double maxDistance = 0.0; //meters // using 0 will return all distances up to max # of results
	
	
	String cuisine = request.getParameter("cuisineID");
	String price = request.getParameter("priceID");
	String distanceS = request.getParameter("distance");
	
	long cuisineID = 0;
	long priceID = 0;
	
	if(cuisine != null && !cuisine.equals("")){
		cuisineID = Integer.parseInt(cuisine);
	}
	if(price != null && !price.equals("")){
		priceID = Integer.parseInt(price);
	}
	if(distanceS != null && !distanceS.equals("")){
		maxDistance = Double.parseDouble(distanceS);
	}
	
	//compute distance from miles to meters
	maxDistance *= 1609.334;
%>
<br />
<form action="browse.jsp" method="post">
<label>Cuisine:</label>
<select name="cuisineID">
<%
	//print all cuisines
	List<Tag> cuisines;
	Query query = pm.newQuery(Tag.class);
	query.setFilter("type == typeParam");
    query.declareParameters("int typeParam");
    query.setOrdering("name ASC"); //alpha order
	cuisines = (List<Tag>) query.execute(Tag.TYPE_CUISINE); //only cuisines
	out.print("<option value=\"\">All</option>");
	for (Tag c : cuisines) {
		out.print("<option value=\"" + c.getKey().getId() + "\"");
		if(cuisineID == c.getKey().getId())
			out.print(" selected");
		out.print(">" + c.getName() + "</option>");			
	}
%>
</select> 
<label>Price:</label>
<select name="priceID">
<%
	//print all prices
	List<Tag> prices;
	query.setFilter("type == typeParam");
    query.declareParameters("int typeParam");
    query.setOrdering("name ASC"); //alpha order
	prices = (List<Tag>) query.execute(Tag.TYPE_PRICE); //only cuisines
	out.print("<option value=\"\">All</option>");
	for (Tag p : prices) {
		out.print("<option value=\"" + p.getKey().getId() + "\"");
		if(priceID == p.getKey().getId())
			out.print(" selected");
		out.print(">" + p.getName() + "</option>");			
	}
%>
</select>
<label>Distance:</label>
<select name="distance">
	<option value="1" <% if(distanceS != null && distanceS.equals("1")) out.print(" selected"); %>>&lt;1 mi.</option>
	<option value="5" <% if(distanceS != null && distanceS.equals("5")) out.print(" selected"); %>>&lt;5 mi.</option>
	<option value="10" <% if(distanceS != null && distanceS.equals("10")) out.print(" selected"); %>>&lt;10 mi.</option>
	<option value="20" <% if(distanceS != null && distanceS.equals("20")) out.print(" selected"); %>>&lt;20 mi.</option>
	<option value="0" <% if(distanceS == null || distanceS.equals("0")) out.print(" selected"); %>>All</option>
</select>
<input type="submit" value="Show Dishes" />  
</form>
<%
	Tag cuisineTag = null;
	Tag priceTag = null;
	ArrayList<Key> tagKeysToFilter = new ArrayList<Key>();

	if(cuisine != null && !cuisine.equals("")){
		cuisineTag = (Tag)pm.getObjectById(Tag.class, cuisineID);
		tagKeysToFilter.add(cuisineTag.getKey());
	}
	if(price != null && !price.equals("")){
		priceTag = (Tag)pm.getObjectById(Tag.class, priceID);
		tagKeysToFilter.add(priceTag.getKey());
	}
	
	List<Dish>dishResults = AbstractSearch.filterDishes(pm, maxResults, tagKeysToFilter, maxDistance,
			userLoc.getLat(), userLoc.getLon());
	
	for (Dish d : dishResults) {%>
		<jsp:include page="partials/dishListingComplete.jsp">
			<jsp:param name="dishID" value="<%= d.getKey().getId() %>" />
		</jsp:include>
<%	}
	
	pm.close();
%>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />