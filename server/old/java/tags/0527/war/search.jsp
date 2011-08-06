<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="com.topdish.comparator.DishPosReviewsComparator" %>
<%@ page import="java.util.Collections" %>

<%
	if(null == request.getParameter("q")) {
	
%>
		<jsp:include page="header.jsp" >
		<jsp:param name="callType" value="search" />
		<jsp:param name="query" value="" />
		</jsp:include>

<%
	} else {
	String toPass = request.getParameter("q");
	if(toPass == null || toPass.equals(" ") || toPass.equalsIgnoreCase("null"))
		toPass = "";
	%>
		<jsp:include page="header.jsp">
			<jsp:param name="query" value='<%=toPass%>' />
			<jsp:param name="callType" value="search" />
		</jsp:include>
    <%
	}
%>

<%
	String query = request.getParameter("q");
	String locationS = request.getParameter("loc");
	
	if(null==query || query.isEmpty())
		query = " ";
	
	query = query.toLowerCase();
	
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

	int maxResults = 25;
	int maxDistance = 0; //meters // using 0 will return all distances up to max # of results
	String[] qWords=null;
	if(query.trim().length()>0)
		qWords = query.split(" ");


	int pageNum=0;
	
	List<Key> tagKeysToFilter = new ArrayList<Key>();
	//Set<Key> tagKeysToFilter = new HashSet<Key>();
	//List<Dish> dishResults = new ArrayList<Dish>(TDQueryUtils.searchGeoItems(qWords, userLoc, maxResults, maxDistance, new Dish()));
	List<Dish> dishResults = TDQueryUtils.searchGeoItemsWithFilter(qWords, userLoc, maxResults, maxDistance, new Dish(), pageNum * maxResults, tagKeysToFilter, new DishPosReviewsComparator());
	//List<Dish> dishResults = new ArrayList<Dish>(TDQueryUtils.filterDishes(maxResults, tagKeysToFilter, maxDistance, userLoc.getLat(), userLoc.getLon(), pageNum * maxResults, new DishPosReviewsComparator()));
	Collections.sort(dishResults, new DishPosReviewsComparator());
	//System.out.println("HI: "+dishResults);
	//<Restaurant> restResults = TDQueryUtils.searchGeoItems(qWords, userLoc, maxResults, maxDistance, new Restaurant());
	//List<Tag> tagResults = TDQueryUtils.searchTags(qWords, maxResults);
%>

<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/newDish.jsp"/>
		<jsp:include page="/blocks/topUsers.jsp"/>
		<jsp:include page="/blocks/topDishesMap.jsp"/>
		<jsp:include page="/blocks/top10Dishes.jsp"/>
	</div>
	<div class="col2">
	<jsp:include page="/blocks/filterBar.jsp"/>
	<div id="breadCrumbId" class="breadcrumb" >
			<div style="float:left;padding-left: 10px;padding-top:2px;padding-bottom:2px;">Filters :</div>
			<div style="float:left;padding-left: 15px;padding-top:2px;padding-bottom:2px;display:none;" id="bcCuisineDiv"><div id="bcCuisine" style="float:left;"></div><div id="bcCuisineRem" style="float:left;">&nbsp;<a href="#" >[X]</a></div></div>
			<div style="float:left;padding-left: 15px;padding-top:2px;padding-bottom:2px;display:none;" id="bcCatDiv"><div id="bcCat" style="float:left;"></div><div id="bcCatRem" style="float:left;"><a href="#" >[X]</a></div></div>
			<div style="float:left;padding-left: 15px;padding-top:2px;padding-bottom:2px;display:none;" id="bcLifeDiv"><div id="bcLife" style="float:left;"></div><div id="bcLifeRem" style="float:left;"><a href="#" >[X]</a></div></div>
			<div style="float:left;padding-left: 15px;padding-top:2px;padding-bottom:2px;display:none;" id="bcDistDiv"><div id="bcDist" style="float:left;"></div><div id="bcDistRem" style="float:left;"><a href="#" >[X]</a></div></div>
			<div style="float:left;padding-left: 15px;padding-top:2px;padding-bottom:2px;display:none;" id="bcPriceDiv"><div id="bcPrice" style="float:left;"></div><div id="bcPriceRem" style="float:left;"><a href="#" >[X]</a></div></div>
		</div>
		<div style="display:none;position:absolute;left:575px;top:66px;" id="ajax_status"><img src="/img/progress.gif"></div>		
		<br/>
		<div class="searchResultMessage" id="dishFoundId">Dishes Found
		</div>
		<div id="dishResultId">
<%
	if(dishResults != null && dishResults.size() > 0){
%>
<div class="rating_header dish_splitter">
	<h1>Dishes found</h1>
<%
		for (Dish d : dishResults) {%>
			<jsp:include page="partials/dishListingComplete.jsp">
				<jsp:param name="dishID" value="<%= d.getKey().getId() %>" />
			</jsp:include>
<%		}
	%>
 </div>
    <%
	}%></div><%
	if( (dishResults == null || dishResults.size() == 0)  ){
%>
<div class="rating_header dish_splitter">
			<h1>No results? Look for something like 'carnitas tacos'.</h1>
</div>
<%
	}
/*
%>
<div id="paginationDiv" style="width:100%;">
	<%
	String styleToHide="display:none;";
		if(pageNum >= 1){
			styleToHide="";
			
		}
			
	%>		<div class="pageNumDiv" id="<%=pageNum - 1%>" style="width: 90%; float: left;<%=styleToHide%>" ><a href="#" id="backId">Back</a></div><!-- <a href="index.jsp?page=<%=pageNum - 1%>">Back</a> -->
	<%
		
	%>
	
		<div class="pageNumDiv" id="<%=pageNum + 1%>" style="width: 10%; float: left;"><a href="#" id="nextId">Next</a></div><!-- <a href="index.jsp?page=<%=pageNum + 1%>">Next</a> -->
</div>
<% */ %>
			</div> <!--  col2 -->	
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />