<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="com.topdish.exception.UserNotFoundException" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:catch var="parsingError">
	<fmt:parseNumber var="dishID" value="${param.dishID}"/>
</c:catch>

<c:catch var="parsingError">
	<fmt:parseNumber var="restaurantID" value="${param.restaurantID}"/>
</c:catch>

<jsp:include page="header.jsp" />
<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/newDish.jsp"/>
		<jsp:include page="/blocks/topUsers.jsp"/>
		<jsp:include page="/blocks/top10Dishes.jsp"/>
	</div>
	<div class="col2">
<div class="rating_header dish_splitter">
	<h1>Flag an item${dishID }</h1>
</div>
<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	
	String reviewIDs = request.getParameter("reviewID");
	String photoIDs = request.getParameter("photoID");
	String flagTypeS = request.getParameter("type");
	
	long reviewID = 0;
	long photoID = 0;
	int flagType = 0;
	
	TDUser creator = null;
	Review review = null;
	Photo photo = null;
	
	try{
		creator = TDUserService.getUser(pm);
	}catch(UserNotLoggedInException e){
		//forward to log in page
	}catch(UserNotFoundException e){
		//user not found...panic?
	}
	
	try{
		reviewID = Long.parseLong(reviewIDs);
	}catch(NumberFormatException e){
		//not a long
	}
	
	try{
		photoID = Long.parseLong(photoIDs);
	}catch(NumberFormatException e){
		//not a long
	}
	
	try{
		flagType = Integer.parseInt(flagTypeS);
	}catch(NumberFormatException e){
		//not an integer
	}
	
	if(reviewID != 0 || photoID != 0){
		
		if(reviewID != 0){
			review = pm.getObjectById(Review.class, reviewID);
			%>
			<jsp:include page="partials/reviewListing.jsp">
				<jsp:param name="reviewID" value="<%= review.getKey().getId() %>" />
			</jsp:include>
			<%
		}
		if(photoID != 0){
			photo = pm.getObjectById(Photo.class, photoID);
			%><img src="<%=ImagesServiceFactory.getImagesService().getServingUrl(photo.getBlobKey(), 200, true)%>"><%
		}
		
		//ask user what kind of flag to assign and OK, or Back

	}else{
		//panic?
	}

%>
	<c:choose>
	<c:when test="${dishID gt 0}">
		<jsp:include page="/blocks/dishBio.jsp">
			<jsp:param name="dishID" value="${dishID}" />
			<jsp:param name="limitedView" value="true" />
		</jsp:include>
	</c:when>
	<c:when test="${restaurantID gt 0}">
		<jsp:include page="/blocks/restaurantBrief.jsp">
			<jsp:param name="restID" value="${restaurantID}" />
			<jsp:param name="limitedView" value="true" />
		</jsp:include>
	</c:when>
	</c:choose>
	<div class="rating_header">
		<h2>Please tell us why you flagged the item above:</h2>
		<form action="/addFlag" method="post">
			<c:choose>
				<c:when test="${dishID gt 0}">
					<input type="radio" name="type" value="<%= Flag.INCORRECT_LIFESTYLE_TAG %>"> Incorrect lifestyle tag</input><br />
					<input type="radio" name="type" value="<%= Flag.INCORRECT_ALLERGY_TAG %>"> Incorrect allergy tag</input><br />
					<input type="radio" name="type" value="<%= Flag.INCORRECT_DESCRIPTION %>"> Incorrect dish description</input><br />
					<input type="radio" name="type" value="<%= Flag.DISH_NOT_ON_MENU %>"> Dish no longer on menu</input><br />
					<input type="radio" name="type" value="<%= Flag.COPYRIGHTED_PICTURE %>"> Copyrighted picture</input><br />
					<input type="radio" name="type" value="<%= Flag.OTHER %>"> Other</input><br />
					<input type="hidden" name="dishID" value="${dishID}"></input>
				</c:when>
				<c:when test="${restaurantID gt 0}">
					<input type="radio" name="type" value="<%= Flag.INCORRECT_CUISINE_TYPE %>"> Incorrect cuisine type</input><br />
					<input type="radio" name="type" value="<%= Flag.INCORRECT_ADDRESS %>"> Incorrect address</input><br />
					<input type="radio" name="type" value="<%= Flag.INCORRECT_CONTACT_DETAIL %>"> Incorrect contact details</input><br />
					<input type="radio" name="type" value="<%= Flag.COPYRIGHTED_PICTURE %>"> Copyrighted Picture</input><br />
					<input type="radio" name="type" value="<%= Flag.RESTAURANT_CLOSED %>"> Restaurant Closed</input><br />
					<input type="radio" name="type" value="<%= Flag.OTHER %>"> Other</input><br />
					<input type="hidden" name="restaurantID" value="${restaurantID }"></input>
					<input type="hidden" name="restDishId" value="${param.dishId}"></input>
				</c:when>
				<c:otherwise>
					<input type="radio" name="type" value="<%= Flag.SPAM %>"> Its spam! (advertising, unrelated links, etc.)</input><br />
					<input type="radio" name="type" value="<%= Flag.INAPPROPRIATE %>"> Its inappropriate! (vulgar, adult, hurtful, etc.)</input><br />
					<input type="radio" name="type" value="<%= Flag.INACCURATE %>"> Its inaccurate! (misspellings, duplicate, misplaced, etc.)</input><br />
					<input type="hidden" name="reviewID" value="<%= reviewID %>"></input>
					<input type="hidden" name="photoID" value="<%= photoID %>"></input>
				</c:otherwise>
			</c:choose>
			<br/>
			<b>Comments:</b><br/>
			<textarea name="comment" cols="30" rows="4" ></textarea><br/>
			<input type="submit" value="Flag it!"></select>
		</form>
	</div>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />