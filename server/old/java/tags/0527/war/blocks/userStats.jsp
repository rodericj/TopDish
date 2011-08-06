<%@ page import="java.util.List"%>
<%@ page import="com.google.appengine.api.datastore.Key"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>
<%@ page import="com.topdish.util.PMF"%>
<%@ page import="com.topdish.util.Datastore"%>
<%@ page import="com.topdish.jdo.*"%>
<%@ page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ page import="com.topdish.util.TDUserService"%>
<%@ page import="javax.jdo.Query"%>
<%
	String userIDs = request.getParameter("userID");

	if (userIDs != null) {
		long userID = Long.parseLong(userIDs);

		TDUser user = Datastore.get(KeyFactory.createKey(
				TDUser.class.getSimpleName(), userID));

		Query qPosReviews = PMF.get().getPersistenceManager()
				.newQuery("select key from " + Review.class.getName());
		qPosReviews.setFilter("direction == "
				+ Review.POSITIVE_DIRECTION);
		List<Key> posRevKeys = (List<Key>) qPosReviews.execute();
		long posReviews = posRevKeys.size();

		Query qNegReviews = PMF.get().getPersistenceManager()
				.newQuery("select key from " + Review.class.getName());
		qNegReviews.setFilter("direction == "
				+ Review.NEGATIVE_DIRECTION);
		List<Key> negRevKeys = (List<Key>) qNegReviews.execute();
		long negReviews = negRevKeys.size();

		Query qLastReview = PMF.get().getPersistenceManager()
				.newQuery(Review.class);
		qLastReview.setFilter("creator == :creatorParam");
		qLastReview.setRange("0,1");
		qLastReview.setOrdering("dateCreated desc");
		List<Review> lastReviews = (List<Review>) qLastReview
				.execute(user.getKey());
		Dish lastReviewedDish = null;

		if (lastReviews.size() > 0) {
			Review lastReview = lastReviews.get(0);
			lastReviewedDish = Datastore.get(lastReview.getDish());
		}

		Query qLastDish = PMF.get().getPersistenceManager()
				.newQuery(Dish.class);
		qLastDish.setFilter("creator == :creatorParam");
		qLastDish.setRange("0,1");
		qLastDish.setOrdering("dateCreated desc");
		List<Dish> lastDishes = (List<Dish>) qLastDish.execute(user
				.getKey());
		Dish lastDishAdded = null;

		if (lastDishes.size() > 0) {
			lastDishAdded = lastDishes.get(0);
		}
%>

<div class="rmenu_cont dish_splitter">
	<div class="vote_stats">
		<div class="like_stats">
			<h2><%=posReviews%>
				Likes
			</h2>
			<h3>I've based votes on:</h3>
			<p>
				<a href="#">QualityA (XXX)</a>
			</p>
			<p>
				<a href="#">QualityB (XX)</a>
			</p>
			<p>
				<a href="#">QualityC (X)</a>
			</p>
		</div>
		<div class="dislike_stats">
			<h2><%=negReviews%>
				Disikes
			</h2>
			<h3>I've based votes on:</h3>
			<p>
				<a href="#">QualityA (XXX)</a>
			</p>
			<p>
				<a href="#">QualityB (XX)</a>
			</p>
			<p>
				<a href="#">QualityC (X)</a>
			</p>
		</div>
	</div>
	<div class="rank_user_stats">
		<div class="rank_category">
			<h3>Contributor Rank:</h3>
			<p>
				#1 <a href="#">CategoryA</a>
			</p>
			<p>
				#3 <a href="#">CategoryB</a>
			</p>
			<p>
				#10 <a href="#">CategoryC</a>
			</p>
			<p>
				#68 <a href="#">CategoryD</a>
			</p>
			<p>
				#381 <a href="#">CategoryE</a>
			</p>
		</div>
		<div class="user_credits">
			<%
				if (lastReviewedDish != null) {
						Restaurant rest = Datastore.get(lastReviewedDish
								.getRestaurant());
			%>
			<div class="user_brief">
				<h3>Most recent rating:</h3>
				<div class="user_photo">
					<%
						if (lastReviewedDish.getPhotos() != null
										&& lastReviewedDish.getPhotos().size() > 0) {
					%>
					<img class="grey_icon"
						src="/getPhoto?id=<%=lastReviewedDish.getPhotos().get(0).getId()%>"></img>
					<%
						} else {
					%>
					<img class="grey_icon" src="style/no_user_img.jpg"></img>
					<%
						}
					%>
				</div>
				<div class="user_info">
					<a href="#" class="dish_name"> <%=lastReviewedDish.getName()%>
					</a>
					<p><%=rest.getName()%></p>
				</div>
			</div>
			<%
				}
			%>
			<%
				if (lastDishAdded != null) {
						Restaurant rest = Datastore.get(lastReviewedDish
								.getRestaurant());
			%>
			<div class="user_brief">
				<h3>Latest Dish Submitted:</h3>
				<div class="user_photo">
					<%
						if (lastDishAdded.getPhotos() != null
										&& lastDishAdded.getPhotos().size() > 0) {
					%>
					<img class="grey_icon"
						src="/getPhoto?id=<%=lastDishAdded.getPhotos().get(0).getId()%>&h=98&w=109"></img>
					<%
						} else {
					%>
					<img class="grey_icon" src="style/no_user_img.jpg"></img>
					<%
						}
					%>
				</div>
				<div class="user_info">
					<a href="#" class="dish_name"> <%=lastDishAdded.getName()%> </a>
					<p><%=rest.getName()%></p>
				</div>
			</div>
			<%
				}
			%>
		</div>
	</div>
	<div class="dish_listing_terminator"></div>
</div>
<%
	}
%>