<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.util.HashSet"%>
<%@ page import="java.util.Collections"%>
<%@ page import="javax.jdo.PersistenceManager"%>
<%@ page import="com.google.appengine.api.datastore.Key"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>
<%@ page import="com.topdish.util.PMF"%>
<%@ page import="com.topdish.util.Datastore"%>
<%@ page import="com.topdish.jdo.*"%>
<%@ page import="com.topdish.util.TDQueryUtils"%>
<%@ page import="com.topdish.util.TDUserService"%>
<%@ page import="com.topdish.comparator.DishPosReviewsComparator"%>
<%@ page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ page import="javax.jdo.JDOObjectNotFoundException"%>
<%@ page import="com.beoui.geocell.model.Point"%>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory"%>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService"%>


<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/newDish.jsp" />
		<jsp:include page="/blocks/topUsers.jsp" />
        <jsp:include page="/blocks/iPhoneAd.jsp" />
		<jsp:include page="/blocks/fbLikeBox.jsp" />
		<jsp:include page="/blocks/topDishesMap.jsp" />
		<jsp:include page="/blocks/top10Dishes.jsp" />
	</div>
	<div class="col2">
		<jsp:include page="/blocks/filterBar.jsp" />
		<!-- 
    <div class="top_categories">
        Categories: San Francisco | Grilled Bacon | Bacon Cheddar | Chai Bacon | Los Bacon
    </div> -->
		<%
			Point userLoc = TDUserService.getUserLocation(request);
			int maxResults = 25;
			double maxDistance = 0.0; //meters // using 0 will return all distances up to max # of results

			String category = request.getParameter("categoryID");
			String price = request.getParameter("priceID");
			String lifestyle = request.getParameter("lifestyleID");
			String cuisine = request.getParameter("cuisineID");
			String distanceS = request.getParameter("distance");
			String pageNumS = request.getParameter("page");
			long priceID = 0;
			long categoryID = 0;
			long lifestyleID = 0;
			long cuisineID = 0;
			int pageNum = 0;
			
			final BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
			final String uploadURL = blobstoreService.createUploadUrl("/addReview");

			try {
				priceID = Long.parseLong(price);
			} catch (NumberFormatException e) {
				//not a long
			}
			try {
				categoryID = Long.parseLong(category);
			} catch (NumberFormatException e) {
				//not a long
			}
			try {
				//maxDistance = Double.parseDouble(distanceS);
			} catch (NumberFormatException e) {
				//not a long
			}
			try {
				lifestyleID = Long.parseLong(lifestyle);
			} catch (NumberFormatException e) {
				//not a long
			}
			try {
				pageNum = Integer.parseInt(pageNumS);
			} catch (NumberFormatException e) {
				//not a long
			}
			try {
				cuisineID = Integer.parseInt(cuisine);
			} catch (NumberFormatException e) {
				//not a long
			}

			//compute distance from miles to meters
			maxDistance *= 1609.334;

			Tag categoryTag = null;
			Tag priceTag = null;
			Tag lifestyleTag = null;
			Tag cuisineTag = null;
			Set<Key> tagKeysToFilter = new HashSet<Key>();

			if (category != null && !category.equals("")) {
				categoryTag = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(),
						categoryID));
				tagKeysToFilter.add(categoryTag.getKey());
			}

			if (price != null && !price.equals("")) {
				priceTag = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), priceID));
				tagKeysToFilter.add(priceTag.getKey());
			}

			if (lifestyle != null && !lifestyle.equals("")) {
				lifestyleTag = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(),
						lifestyleID));
				tagKeysToFilter.add(lifestyleTag.getKey());
			}

			if (cuisine != null && !cuisine.equals("")) {
				cuisineTag = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(),
						cuisineID));
				tagKeysToFilter.add(cuisineTag.getKey());
			}

			try {
				List<Dish> dishResults = new ArrayList<Dish>(TDQueryUtils.filterDishes(maxResults,
						tagKeysToFilter, maxDistance, userLoc.getLat(), userLoc.getLon(), pageNum
								* maxResults));
				Collections.sort(dishResults, new DishPosReviewsComparator());
		%>
		<div id="breadCrumbId" class="breadcrumb">
			<div
				style="float: left; padding-left: 10px; padding-top: 2px; padding-bottom: 2px;">Filters
				:</div>
			<div
				style="float: left; padding-left: 15px; padding-top: 2px; padding-bottom: 2px; display: none;"
				id="bcCuisineDiv">
				<div id="bcCuisine" style="float: left;"></div>
				<div id="bcCuisineRem" style="float: left;">
					&nbsp;<a href="#">[X]</a>
				</div>
			</div>
			<div
				style="float: left; padding-left: 15px; padding-top: 2px; padding-bottom: 2px; display: none;"
				id="bcCatDiv">
				<div id="bcCat" style="float: left;"></div>
				<div id="bcCatRem" style="float: left;">
					&nbsp;<a href="#">[X]</a>
				</div>
			</div>
			<div
				style="float: left; padding-left: 15px; padding-top: 2px; padding-bottom: 2px; display: none;"
				id="bcLifeDiv">
				<div id="bcLife" style="float: left;"></div>
				<div id="bcLifeRem" style="float: left;">
					&nbsp;<a href="#">[X]</a>
				</div>
			</div>
			<div
				style="float: left; padding-left: 15px; padding-top: 2px; padding-bottom: 2px; display: none;"
				id="bcDistDiv">
				<div id="bcDist" style="float: left;"></div>
				<div id="bcDistRem" style="float: left;">
					&nbsp;<a href="#">[X]</a>
				</div>
			</div>
			<div
				style="float: left; padding-left: 15px; padding-top: 2px; padding-bottom: 2px; display: none;"
				id="bcPriceDiv">
				<div id="bcPrice" style="float: left;"></div>
				<div id="bcPriceRem" style="float: left;">
					&nbsp;<a href="#">[X]</a>
				</div>
			</div>
		</div>
		<div
			style="display: none; position: absolute; left: 575px; top: 66px;"
			id="ajax_status">
			<img src="/img/progress.gif">
		</div>
		<br />
		<div class="searchResultMessage" id="dishFoundId">
			<h1>Dishes Found</h1>
		</div>
		<div id="dishResultId">

			<%
				for (Dish d : dishResults) {
			%>

			<jsp:include page="partials/dishListingComplete.jsp">
				<jsp:param name="dishID" value="<%= d.getKey().getId() %>" />
				<jsp:param name="uploadURL" value="<%= uploadURL %>" />
			</jsp:include>

			<%
				}
			%>
		</div>
		<%
			} catch (Exception e) {
				e.printStackTrace();
			}
			/*	finally{
			 pm.close();
			 }
		%>
		<div id="paginationDiv" style="width: 100%;">
			<%
				String styleToHide="display:none;";
															 if(pageNum >= 1){
															 styleToHide="";
															
															 }
			%>
			<div class="pageNumDiv" id="<%=pageNum - 1%>"
				style="width: 90%; float: left;<%=styleToHide%>">
				<a href="#" id="backId">Back</a>
			</div>
			<!-- <a href="index.jsp?page=<%=pageNum - 1%>">Back</a> -->
			<%
				
			%>

			<div class="pageNumDiv" id="<%=pageNum + 1%>"
				style="width: 10%; float: left;">
				<a href="#" id="nextId">Next</a>
			</div>
			<!-- <a href="index.jsp?page=<%=pageNum + 1%>">Next</a> -->
		</div>
		<%
			*/
		%>
	</div>
	<!--  col2 -->
</div>
<!--  colleft -->