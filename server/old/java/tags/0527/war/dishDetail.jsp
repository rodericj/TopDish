<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Collection" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.Datastore" %>

<jsp:include page="header.jsp" />

<%
	long dishID = Long.valueOf(request.getParameter("dishID"));
	final Dish d = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), dishID));
	long restID = d.getRestaurant().getId();
	final Restaurant rest = Datastore.get(d.getRestaurant());
%>

<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/dishBio.jsp">
			<jsp:param name="dishID" value="<%= dishID %>" />
		</jsp:include> 
		<jsp:include page="/blocks/restaurantBrief.jsp">
			<jsp:param name="restID" value="<%= restID %>" />
		</jsp:include>
		<jsp:include page="/blocks/singleDishMap.jsp" />
	</div>
	<div class="col2">
<%
		Collection<Key> reviewKeys = TDQueryUtils.getReviewKeysByDish(d.getKey());
		Set<Key> tagKeys = d.getTags();
		List<Key> photoKeys = d.getPhotos();
		List<Tag> tags;
		
		int posReviews = 0;
		int negReviews = 0;
		
		if(d.getNumPosReviews() != null)
			posReviews = d.getNumPosReviews();
		if(d.getNumNegReviews() != null)
			negReviews = d.getNumNegReviews();

		if(null != photoKeys && !photoKeys.isEmpty()) { %>
			<ul id="gallery">
<%			for(Key k : photoKeys) {
				try{
					Photo p = Datastore.get(k);
					if(p.getNumFlagsTotal() < 3){
						final String url = p.getURL(384);
%>
						<li>
							<img src="<%=url %>"></img>
			                 <div class="panel-overlay">
			                     <p>
			                     <a href="flag.jsp?photoID=<%=p.getKey().getId()%>">Flag this photo</a>
			                     </p>
							</div>
						</li>
<%
					}
				}catch(Exception e){
						//image is broken
						e.printStackTrace();
				}
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