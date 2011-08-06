 <%@page import="org.datanucleus.store.appengine.EntityUtils"%>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.TDMathUtils" %>
<%@ page import="com.topdish.util.HumanTime" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>
<%@include file="/includes/userTagIncludes.jsp" %>
<%
	Point userLoc = ((TDPoint)request.getSession().getAttribute("userLocationPoint")).getPoint();
	long dishID = Long.parseLong(request.getParameter("dishID"));
	final Dish d = PMF.get().getPersistenceManager().getObjectById(Dish.class, dishID);
	final Restaurant r = PMF.get().getPersistenceManager().getObjectById(Restaurant.class, d.getRestaurant());
	final List<Tag> tags = TDQueryUtils.getAll(d.getTags(), new Tag());
	BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	String blobUploadURL = blobstoreService.createUploadUrl("/addReview");
	Photo dishPhoto = null;

	if(d.getPhotos() != null && d.getPhotos().size() > 0){
		dishPhoto = PMF.get().getPersistenceManager().getObjectById(Photo.class, d.getPhotos().get(0));
	}
%>
	<div class="upVotePanel votePanel" style="display:none;">
		<form action="<%= blobUploadURL %>" method="post" id="reviewDishForm" enctype="multipart/form-data">
			<h2>Additional Food for thought? <span>Tell us why you would recommend this dish.</span></h2>
			<textarea name="comment" class="textVote"></textarea>
			<div class='cover'><h3>If you change your mind later <a href="#">revote</a>, or edit from you <a href="#">profile</a>.</h3></div>
			<img src="/img/panel/voteup_photo.png" alt="Add a Photo" class="photo" />
			<input type="file" name="myFile" class="browse" />
			<input name="rating" value="pos" type="hidden" />
			<input name="dishID" value="<%= d.getKey().getId() %>" type="hidden" />
			<input type="image" src="/img/panel/voteup_submit.png" name="submit" class="submit" />
		</form>
	</div>
	<div class="dish_listing dish_splitter">
       	<div class="dish_listing_quick">
       	
            <% // Rating Box %>
			<jsp:include page="/blocks/ratingBox.jsp">
				<jsp:param name="dishID" value="<%= d.getKey().getId() %>" />
				<jsp:param name="float" value="left" />
			</jsp:include>

			<div class="dish_listing_details">
                    <a href="dishDetail.jsp?dishID=<%= d.getKey().getId() %>">
<%					if(dishPhoto != null){ %>
						<img class="dish_image_gold" src="<%=ImagesServiceFactory.getImagesService().getServingUrl(dishPhoto.getBlobKey(), 98, true)%>" alt="<% out.print(d.getName()); %>"></img>
<%					}else{ %>
						<img class="dish_image_gold" src="style/no_dish_img.jpg" alt="<% out.print(d.getName()); %>"></img>
<%					} %>
                    </a>
                    <div class="dish_listing_text">
                        <h1><a href="dishDetail.jsp?dishID=<%= d.getKey().getId() %>" class="dish_name"><% out.print(StringEscapeUtils.escapeHtml(d.getName())); %></a>
                        <c:set var="dishId" value="<%= d.getKey().getId() %>"/>
                        <user:isUserInRole roles="${administrator},${standard},${advanced}" dishId="${dishId}">
<%							if(TDUserService.getUserLoggedIn()){%>
                            		<span><a href="editDish.jsp?dishID=<%= d.getKey().getId() %>">[edit]</a></span>
<%							}%>
						</user:isUserInRole>
						</h1>
					
                        <!-- <span><% //if(d.getCategory() != null) { out.write("CatKey: " + d.getCategory()); }%></span> -->
                        <p><% out.print(StringEscapeUtils.escapeHtml(d.getDescription())); %> </p>
                    </div>
                </div>
                <div class="dish_listing_address">
                    <div class="dish_height_bar"></div>
                    <h3><a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>"><% out.print(StringEscapeUtils.escapeHtml(r.getName())); %></a></h3>
                    <p><% out.print(StringEscapeUtils.escapeHtml(r.getAddressLine1())); %></p>
                    <p><% out.print(StringEscapeUtils.escapeHtml(r.getCity()) + ", "); %>
					<% out.print(StringEscapeUtils.escapeHtml(r.getState())); %></p>
                    <p><% out.print(StringEscapeUtils.escapeHtml(r.getNeighborhood())); %></p>
                    <p><% out.print("Distance: " + TDMathUtils.formattedGeoPtDistanceMiles(userLoc, d.getLocation()) + " mi"); %></p>
                    <div class="dish_lat" style=""><%=d.getLocation().getLat()%></div>
                    <div class="dish_lng" style=""><%=d.getLocation().getLon()%></div>                    
                </div>
			</div>
			     <div class="dish_listing_footer">
                    <div class="dish_status">
                    <!--  <img src="img/availability/now_serving.png" width="55" height="23" alt="Now Serving" /> -->
                    </div>
<%					if(tags != null && !tags.isEmpty()){ %>
                    <div class="dish_listing_categories">
                        <h3>Tags:</h3>
                        <p>
<%						for(Tag t : tags){%>
							<%= t.getName() + "&nbsp;&nbsp;"%>
<%                		}%>
                     	</p>
                    </div>
<%                  }
%>
                    <div class="dish_listing_infographics">
                    <%	Key lastReviewKey = TDQueryUtils.getLatestReviewByDish(d.getKey());
                    	if(null != lastReviewKey){
                    		final Review lastReview = PMF.get().getPersistenceManager().getObjectById(Review.class, lastReviewKey);
                    		if(lastReview.getDirection() == Review.POSITIVE_DIRECTION){%>
	                        <img src="img/up_arrow_icon.png" width="12" height="15" /><span><%= HumanTime.approximately(System.currentTimeMillis() - lastReview.getDateCreated().getTime()) %> ago</span>
	                    <%	}else{ %>
	                    	<img src="img/down_arrow_icon.png" width="12" height="15" /><span><%= HumanTime.approximately(System.currentTimeMillis() - lastReview.getDateCreated().getTime()) %> ago</span>
	                    <%	}
                    	}
                    %>
                        <img src="img/comment_icon.png" width="16" height="15" /><span><a href="dishDetail.jsp?dishID=<%= d.getKey().getId() %>">Reviews: <%=d.getNumReviews()%></a></span>
                    </div>
                </div>
                <div class="dish_listing_terminator"></div>
		</div>
		<div class="downVotePanel votePanel" style="display:none;">
			<form action="<%= blobUploadURL %>" method="post" id="reviewDishForm" enctype="multipart/form-data">
				<h2>Additional Food for thought? <span>Tell us why you would not recommend this dish.</span></h2>
				<textarea name="comment" class="textVote"></textarea>
				<div class='cover'><h3>If you change your mind later <a href="#">revote</a>, or edit from you <a href="#">profile</a>.</h3></div>
				<img src="/img/panel/votedown_photo.png" alt="Add a Photo" class="photo" />
				<input type="file" name="myFile" class="browse" />
				<input name="rating" value="neg" type="hidden" />
				<input name="dishID" value="<%= d.getKey().getId() %>" type="hidden" />
				<input type="image" src="/img/panel/votedown_submit.png" name="submit" class="submit" />
			</form>
		</div>