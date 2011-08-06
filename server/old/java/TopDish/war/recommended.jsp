<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.SortedMap" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.TDRecoUtils" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>

<jsp:include page="header.jsp" />

<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	TDUser user = null;
	try {
		user = TDUserService.getUser(session);
	} catch(UserNotLoggedInException e) {
		response.sendRedirect("index.jsp");
		//return;
	}
	
	String locationS = request.getParameter("loc");
		
	final String location;
	Point userLoc;
	if(null != (location = request.getParameter("loc"))) {
		TDPoint pt = TDUserService.setUserLocation(location, request);
		userLoc = pt.getPoint();
		response.addCookie(new Cookie("lat", String.valueOf(userLoc.getLat())));
		response.addCookie(new Cookie("lng", String.valueOf(userLoc.getLon())));

		// Lat found
		boolean gotLat = false;
		// Lon found
		boolean gotLng = false;
		
		// Traverse Cookies to find the Latitude and Longitude Cookies
		Cookie[] cookies = request.getCookies();
		for(int i = 0; i < cookies.length; i++) {
			
			if(cookies[i].getName().equals("lat")) {
				gotLat = true;
				//Set Latitude
				request.getCookies()[i].setValue(String.valueOf(userLoc.getLat()));
			} else if (cookies[i].getName().equals("lng")) {
				gotLng = true;
				//Set Longitude
				request.getCookies()[i].setValue(String.valueOf(userLoc.getLon()));
			}
			
			//break if both have been added
			if(gotLat && gotLng)
				break;
		}
		
		final String addrPt[] = pt.getAddress().split(",");
		//Handle result
		if(addrPt.length >= 2) {
			final String city = addrPt[0].replace("\"", "").trim();
			final String state = addrPt[1].replace("\"", "").trim();
			response.addCookie(new Cookie("city", city));
			response.addCookie(new Cookie("state", state));
		} else if (addrPt.length == 1) {
			final String city = addrPt[0].replace("\"", "").trim();
			response.addCookie(new Cookie("city", city));
			response.addCookie(new Cookie("state", " "));
		} else {
			response.addCookie(new Cookie("city", "San Francisco"));
			response.addCookie(new Cookie("state", "CA"));
		}
		
		userLoc = TDUserService.getUserLocation(request).getPoint();
	} else {
		userLoc = TDUserService.getUserLocation(request).getPoint();
	}

	int maxResults = 10;
	int maxDistance = 0; //meters // using 0 will return all distances up to max # of results

	SortedMap<Double, Dish> dishResults = TDRecoUtils.recommendDishes(user, userLoc, maxResults, maxDistance);
	SortedMap<Double, Restaurant> restResults = TDRecoUtils.recommendRestaurants(user, userLoc, maxResults, maxDistance);
	//String[] qWords = (String[]) dishResults.values().toArray(new String[0]);
	List<Tag> tagResults = null; //TDQueryUtils.searchTags(qWords, maxResults);   // TODO keep this ore remove?
%>

<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/newDish.jsp"/>
		<jsp:include page="/blocks/topDishesMap.jsp"/>
	</div>
	<div class="col2">
<%
	if(dishResults != null && dishResults.size() > 0){
%>
<div class="rating_header dish_splitter">
	<h1>Personalized dish recommendations</h1>
<%
		for (Entry<Double, Dish> dishEntry : dishResults.entrySet()) {%>
			<jsp:include page="partials/dishListingComplete.jsp">
				<jsp:param name="dishID" value="<%= dishEntry.getValue().getKey().getId() %>" />
				<jsp:param name="starRating" value="<%= dishEntry.getKey() %>" />
			</jsp:include>
<%		}
	%>
    </div>
    <%
	}
%>

<%
	if(restResults != null && restResults.size() > 0){
%>
<div class="rating_header dish_splitter">
	<h1>Restaurant recommendations</h1>
<%
		for (Entry<Double, Restaurant> restEntry : restResults.entrySet()) {%>
			<jsp:include page="partials/restaurantListing.jsp">
				<jsp:param name="restID" value="<%= restEntry.getValue().getKey().getId() %>" />
			</jsp:include>
<%
		}
%>
</div>
<%
	}
%>

<%
	// TODO - keep or remove or implement tags related to user's profile? (tag recommendation)
	if(tagResults != null && tagResults.size() > 0){
%>
<div class="rating_header dish_splitter">
	<h1>Tags found</h1>
<%
		for (Tag t : tagResults) {
%>
			<jsp:include page="partials/tagListing.jsp">
				<jsp:param name="tagID" value="<%= t.getKey().getId() %>" />
			</jsp:include>
<%		}
%>
</div>
<%
	}
%>
<%
	if( (restResults == null || restResults.size() == 0) && (dishResults == null || dishResults.size() == 0) && (tagResults == null || tagResults.size() == 0) ){
%>
<div class="rating_header dish_splitter">
			<h1>No results? Look for something like 'carnitas tacos'.</h1>
</div>
<%
	}

	pm.close();
%>

			</div> <!--  col2 -->	
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />