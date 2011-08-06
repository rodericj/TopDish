<jsp:include page="header.jsp" />
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.exception.UserNotFoundException" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="java.util.List" %>

<%
	TDUser user = null;
	//first check if looking for a user via GET var
	String userIDs = request.getParameter("userID");
	long userID = 0;
	if(userIDs != null){
		userID = Long.parseLong(userIDs);
	}
	
	//then check if the user is logged in
	boolean loggedIn = false;
	try{
		user = TDUserService.getUser(request.getSession(true));		//will return valid user or throw exception
		if(null!= user && (user.getKey().getId() == userID || userID == 0)){
			//looking at own profile
			loggedIn = true;
			userID = user.getKey().getId();
		}
		else{
			//looking at another user's profile
			loggedIn = false;
			if(userID > 0){
				user = Datastore.get(KeyFactory.createKey(TDUser.class.getSimpleName(), userID));
			}
			else{
				//userID <= 0 is an invalid key value
				throw new UserNotFoundException();
			}
		}
	}catch(UserNotLoggedInException e){
		e.printStackTrace();
		//display bio as normal
		if(userID > 0){
			user = Datastore.get(KeyFactory.createKey(TDUser.class.getSimpleName(), userID));
			loggedIn = false;
		}else{
			response.sendRedirect("index.jsp");
		}
	}catch(UserNotFoundException e){
		e.printStackTrace();
		//TODO: redirect to error page
		//response.sendRedirect("index.jsp");
		
		if(userID > 0){
			user = Datastore.get(KeyFactory.createKey(TDUser.class.getSimpleName(), userID));
			loggedIn = false;
		}else{
			response.sendRedirect("index.jsp");
		}
 	}%>

<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/userBio.jsp">
			<jsp:param name="userID" value="<%= userID %>" />
		</jsp:include>
	</div>
	<div class="col2">
<%
	int queryLimit = 10;
	
	List<Key> reviewKeys = null;
	List<Key> dishKeys = null;
	
	//reviews created by this user
	Query qReviews = PMF.get().getPersistenceManager().newQuery("select key from " + Review.class.getName());
	qReviews.setOrdering("dateCreated desc");
	qReviews.setRange("0,5");
	qReviews.setFilter("creator == :creatorParam");
	//reviewKeys = (List<Key>)qReviews.execute(user.getKey());
    reviewKeys = (List<Key>)qReviews.execute(KeyFactory.createKey(TDUser.class.getSimpleName(), userID));
	//dishes added by this user
	Query qDishes = PMF.get().getPersistenceManager().newQuery("select key from " + Dish.class.getName());
	qDishes.setOrdering("dateCreated desc");
	qDishes.setRange("0,5");
	qDishes.setFilter("creator == :creatorParam");
    dishKeys = (List<Key>)qDishes.execute(user.getKey());
%>
	<div class="user_bio">
	<div class="rating_header dish_splitter">
		<h1>Last 5 dishes added</h1>
	</div>
		<div class="user_dishes">
		<%
			if(dishKeys != null && dishKeys.size() > 0){
				for (Key k : dishKeys) {%>
					<jsp:include page="partials/dishListingComplete.jsp">
						<jsp:param name="dishID" value="<%= k.getId() %>" />
					</jsp:include>
		<%		}
			}else{
				out.print("You have not added any dishes.");
			}
		%>
		</div>
	</div>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />