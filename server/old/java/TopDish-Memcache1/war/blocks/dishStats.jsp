<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	String dishIDs = request.getParameter("dishID");

if(dishIDs != null){
	long dishID = Long.parseLong(dishIDs);
	
	try{
		Dish d = pm.getObjectById(Dish.class, dishID);
		int posReviews = 0;
		int negReviews = 0;
		List<Key> tagKeys = d.getTags();
		TDUser creator = pm.getObjectById(TDUser.class,d.getCreator());
		Review firstReview = PMF.get().getPersistenceManager().getObjectById(Review.class, TDQueryUtils.getFirstReviewByDish(d.getKey()));
		Review lastReview = PMF.get().getPersistenceManager().getObjectById(Review.class, TDQueryUtils.getLatestReviewByDish(d.getKey()));
		TDUser firstReviewAuthor = null;
		
		if(firstReview != null)
			firstReviewAuthor = pm.getObjectById(TDUser.class, firstReview.getCreator());
		
		if(d.getNumPosReviews() != null)
			posReviews = d.getNumPosReviews();
		if(d.getNumNegReviews() != null)
			negReviews = d.getNumNegReviews();
			
%>
<div class="rmenu_cont dish_splitter">
	<h1>Top Dish Breakdown</h1>
	<div class="vote_stats">
		<div class="like_stats">
			<h2><img src="img/up_arrow_large.png" width="16" height="16" alt="Like it" /> <%=posReviews%> <% out.print((posReviews != 1) ? "Like" : "Likes"); %> it</h2>
			<h3><%=posReviews%> <% out.print((posReviews != 1) ? "People" : "Person"); %> Rated on:</h3>
			<p><a href="#">QualityA (XXX)</a></p>
			<p><a href="#">QualityB (XX)</a></p>
			<p><a href="#">QualityC (X)</a></p>
		</div>
		<div class="dislike_stats">
			<h2><img src="img/down_arrow_large.png" width="16" height="16" alt="Dislike it" /><%=negReviews%> <% out.print((posReviews != 1) ? "Dislike" : "Dislikes"); %> it</h2>
			<h3><%=negReviews%> <% out.print((posReviews != 1) ? "People" : "Person"); %> Rated on:</h3>
			<p><a href="#">QualityA (XXX)</a></p>
			<p><a href="#">QualityB (XX)</a></p>
			<p><a href="#">QualityC (X)</a></p>
		</div>
	</div>
	<div class="rank_user_stats">
		<div class="rank_category">
			<h3>Rank by Category:</h3>
			<p>#1 <a href="#">CategoryA</a></p>
			<p>#3 <a href="#">CategoryB</a></p>
			<p>#10 <a href="#">CategoryC</a></p>
			<p>#68 <a href="#">CategoryD</a></p>
			<p>#381 <a href="#">CategoryE</a></p>
		</div>
		<div class="user_credits">
			<div class="user_brief">
				<h3>Dish Submitted By:</h3>
				<div class="user_photo">
<%				if(creator.getPhoto() != null){ %>
					<img class="grey_icon" src="/getPhoto?id=<%=creator.getPhoto().getId()%>" />
<%				}else{ %>
					<img class="grey_icon" src="style/no_user_img.jpg" />
<%				} %>	
				</div>
				<div class="user_info">
					<a href="#" class="user_nick">
<%						if(creator != null){
							out.print(creator.getNickname());
						}else{
							out.print("Anonymous");
						}%>
					</a>
					<p>X Likes</p>
					<p>X Dislikes</p>
				</div>
			</div>
<%			if(firstReviewAuthor != null){ %>
			<div class="user_brief">
				<h3>First to review:</h3>
				<div class="user_photo">
<%					if(firstReviewAuthor.getPhoto() != null){ %>
						<img class="grey_icon" src="/getPhoto?id=<%=firstReviewAuthor.getPhoto().getId()%>" />
<%					}else{ %>
						<img class="grey_icon" src="style/no_user_img.jpg" />
<%					} %>	
				</div>
				<div class="user_info">
					<a href="#" class="user_nick">
<%						out.print(firstReviewAuthor.getNickname()); %>
					</a>
						<p>X Likes</p>
						<p>X Dislikes</p>
				</div>
			</div>
<%			} %>
		</div>
	</div>
	<div class="dish_listing_terminator"></div>
</div>
<%		
	} finally {
		pm.close();
	}
}
%>