<%@page import="com.topdish.util.TDQueryUtils"%>
<%
	//should this be 4 users within 25 miles with the most reviews? (top _local_ foodies?)
		//get all dishes within 25 miles
		//get all reviews for those dishes
		//count reviews for each user
		//show top 4 users
	//if this is top users of all TopDish, it may be more costly to compute
		//pull all reviews?!?!
		//count reviews for all users?!?!
		//show top 4 users
	//would be easiest if we stored some kind of karma rank for each user
		//get 4 users, sort by karma.  easy, cheap, simple.
		//of course we shouldn't store a user's location so we can't make this "local"
%>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.topdish.search.AbstractSearch" %>
<%@ page import="java.util.List" %>
<%@ page import="com.topdish.jdo.TDUser" %>
<%@ page import="com.topdish.jdo.Review" %>
<%@ page import="com.topdish.jdo.Dish" %>
<%@ page import="com.topdish.jdo.Photo" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.topdish.util.RemoveOrphans" %>
<%@ page import="com.topdish.util.HumanTime" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>

<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	Query q = pm.newQuery(TDUser.class);
	q.setOrdering("numReviews desc");
	q.setRange(0,4);
	
	List<TDUser> users = (List<TDUser>)q.execute();
	int oddEven = 0;
%>
<div class="rmenu_cont dish_splitter">
   <h1>Our Top Foodies</h1>
   <div class="rmenu_disp">
   <div class="top_foodie_cont">
   		<% for(TDUser u : users){ %>
       	<div class="top_foodie_box_border<%if(oddEven % 2 == 0){%><%=" top_foodie_box_even"%><%}%>">
       		<div class="top_foodie_box">
       			<div class="photo">
	       			<% if(u.getPhoto() != null){ 
	       				Photo userPhoto = PMF.get().getPersistenceManager().getObjectById(Photo.class, u.getPhoto());
	       			%>
	       				<img src="<%=ImagesServiceFactory.getImagesService().getServingUrl(userPhoto.getBlobKey(), 36, true)%>"></img>
	       			<%}else{ %>
	       				<img src="style/no_user_img.jpg"></img>
	       			<% } %>
       			</div>
       			<div class="name_stats">
	       			<h3><a href="userProfile.jsp?userID=<%=u.getKey().getId()%>"><%=u.getNickname()%></a></h3>
	       			<p>
	       			<%
	       				if(u.getNumPosReviews() == null){
	       					%><%=0%><%
	       				}else{
	       					%><%=u.getNumPosReviews()%><%
	       				}
	       			%> Likes
	       			</p><p>
	       			<%
	       				if(u.getNumNegReviews() == null){
	       					%><%=0%><%
	       				}else{
	       					%><%=u.getNumNegReviews()%><%
	       				}
	       			%> Dislikes
	       			</p>
       			</div>
       			<div class="last_review">
	       			<%
	       				Key lastRevKey = TDQueryUtils.getLatestReviewByUser(u.getKey());
	       				if(lastRevKey != null){
	       					Review r = null;
	       					Dish d = null;
	       					try{
	       						r = pm.getObjectById(Review.class, lastRevKey);
	       						d = pm.getObjectById(Dish.class, r.getDish());
	           					if(r.getDirection() == Review.POSITIVE_DIRECTION){
	           						%><h3 class="pos_review">Likes <a href="dishDetail.jsp?dishID=<%=d.getKey().getId()%>"><%=d.getName()%></a></h3><%
	           					}else{
	           						%><h3 class="neg_review">Dislikes <a href="dishDetail.jsp?dishID=<%=d.getKey().getId()%>"><%=d.getName()%></a></h3><%
	           					}%>
	           					<p><a href="restaurantDetail.jsp?restID=<%=d.getRestaurant().getId()%>"><% if(d.getRestaurantName() != null) out.print(d.getRestaurantName()); %></a></p>
	           					<p><%=HumanTime.approximately(System.currentTimeMillis() - r.getDateCreated().getTime())%> ago</p><%
	       					}catch(JDOObjectNotFoundException e){
	       						if(r == null){
	       							//review object not found
	       							RemoveOrphans.removeReview(lastRevKey);
	       						}
	       					}
	       				}
	       		 	%>
       		 	</div>
       		</div>
       		
       	</div>
       <%	oddEven++; 
       } %>
       </div>
       <div class="dish_listing_terminator"></div>
   </div>
</div>