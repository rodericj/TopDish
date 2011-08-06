<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>

<jsp:include page="header.jsp" />

<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	long dishID = Long.valueOf(request.getParameter("dishID"));	
	Dish d = (Dish)pm.getObjectById(Dish.class, dishID);
	long restID = d.getRestaurant().getId();
	Restaurant rest = (Restaurant) pm.getObjectById(Restaurant.class, d.getRestaurant());
%>

<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/dishBio.jsp">
			<jsp:param name="dishID" value="<%= dishID %>" />
		</jsp:include> 
		<jsp:include page="/blocks/restaurantBrief.jsp">
			<jsp:param name="restID" value="<%= restID %>" />
			<jsp:param name="dishID" value="<%= dishID %>" />
		</jsp:include>
		<jsp:include page="/blocks/singleDishMap.jsp" />
	</div>
	<div class="col2">
<%
		List<Key> reviewKeys = TDQueryUtils.getReviewKeysByDish(d.getKey());
		List<Key> tagKeys = d.getTags();
		List<Key> photoKeys = d.getPhotos();
		List<Tag> tags;
		
		int posReviews = 0;
		int negReviews = 0;
		
		if(d.getNumPosReviews() != null)
			posReviews = d.getNumPosReviews();
		if(d.getNumNegReviews() != null)
			negReviews = d.getNumNegReviews();

		if(photoKeys.size() > 0) { %>
			<ul id="gallery">
<%			for(Key k : photoKeys) {
				Photo p = pm.getObjectById(Photo.class, k);
				if(p.getNumFlagsTotal() < 3){
%>
				<li>
					<img src="<%=ImagesServiceFactory.getImagesService().getServingUrl(p.getBlobKey(), 572, true)%>"></img>
	                 <div class="panel-overlay">
	                     <p>
	                     <a href="flag.jsp?photoID=<%=p.getKey().getId()%>">Flag this photo</a>
	                     </p>
					</div>
				</li>
<%				}
			}%>
			</ul>
<%		} %>
		<div class="color_bar gold_bar">
<%	 		if(reviewKeys != null)
				out.print("Ratings with comments");
			else
				out.print("No Ratings with comments");
%>
			<!-- <span><a href="#">show list</a></span> -->
		</div>
        
<%			if(reviewKeys.size() > 0){			
				for (Key k: reviewKeys) {%>
					<jsp:include page="partials/reviewListing.jsp">
						<jsp:param name="reviewID" value="<%= k.getId() %>" />
					</jsp:include>
<%				}
			}
%>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />