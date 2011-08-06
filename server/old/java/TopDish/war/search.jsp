<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.GeoUtils" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<%@ page import="com.topdish.comparator.DishPosReviewsComparator" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory"%>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService"%>
<%

	String query = request.getParameter("q");
	final String locationS = request.getParameter("loc");
	final String latS = request.getParameter("user_lat");
	final String lngS = request.getParameter("user_lng");
	final TDPoint curLocation = TDUserService.getUserLocation(request);
	final BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	final String uploadURL = blobstoreService.createUploadUrl("/addReview");
	
	double lat = 0.0;
	double lng = 0.0;
	
	TDPoint newLocation;
	
	try{
		lat = Double.parseDouble(latS);
		lng = Double.parseDouble(lngS);
		
		newLocation = new TDPoint(new Point(lat, lng), locationS);
		if(!newLocation.equals(curLocation)){
			newLocation = GeoUtils.reverseAddress(newLocation.getAddress(), newLocation.getCity(), newLocation.getState());
			TDUserService.setUserLocation(newLocation, request);
		}		
	} catch (NumberFormatException e){
		// Not doubles.
		newLocation = GeoUtils.defaultTDPoint();
	} catch (NullPointerException e){
		// Null lat or lng.
		newLocation = GeoUtils.defaultTDPoint();
	}
	
	// Just in case this sneaks through.
	if(lat == 0.0 && lng == 0.0){
		newLocation = GeoUtils.defaultTDPoint();
	}

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
		
	if(null==query || query.isEmpty()){
		query = " ";
	}
	
	query = query.toLowerCase();

	int maxResults = 25;
	int maxDistance = 0; //meters // using 0 will return all distances up to max # of results
	int pageNum=0;
	String[] qWords=null;
	if(query.trim().length()>0)
		qWords = query.split(" ");

	final List<Key> tagKeysToFilter = new ArrayList<Key>();
	final List<Dish> dishResults = TDQueryUtils.searchGeoItemsWithFilter(qWords, newLocation, maxResults, maxDistance, new Dish(), pageNum * maxResults, tagKeysToFilter, new DishPosReviewsComparator());
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