<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.topdish.jdo.*" %>

<jsp:include page="header.jsp" />

<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/newDish.jsp"/>
		<jsp:include page="/blocks/topUsers.jsp"/>
		<jsp:include page="/blocks/top10Dishes.jsp"/>
	</div>
	<div class="col2">
<%	
	long dishID = Long.valueOf(request.getParameter("dishID"));
	String comment = "";
	int dir = 0;
	
	if(request.getParameter("dir") != null){
		dir = Integer.valueOf(request.getParameter("dir"));
	}
	if(request.getParameter("comment") != null){
		comment = request.getParameter("comment");
	}
	
	Dish dish = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), dishID));
	Restaurant rest = Datastore.get(dish.getRestaurant());
	String restAddress = rest.getAddressLine1() + ", " + rest.getCity() + ", " + rest.getState();
	
	String tagList = "";	
%>
<div class="rating_header dish_splitter">
	<h1><span><% out.print(dish.getName()); %></span> @ <% out.print(rest.getName()); %> </h1>
</div>
<form action="addReview" method="post">
	<div class="rating_header dish_splitter">
	    
	</div>
	<div class="rating_header">
		<h2></h2>
	    <h2>Would you recommend this dish?</h2>
	    <fieldset class="rating_radios">
	    	<ol>
	        	<li class="like">
	            	<input name="rating" id="rating-pos" value="pos" type="radio" <% if(dir>0) out.print("checked=\"checked\""); %> />
	        		<label for="rating-pos">Yes</label>
	            </li>
	        	<li class="dislike">
	            	<input name="rating" id="rating-neg" value="neg" type="radio" <% if(dir<0) out.print("checked=\"checked\""); %> />
	       			<label for="rating-neg">No</label>
	            </li>
	        </ol>
	    </fieldset>
	    <!-- //TODO: integrate photo upload addReviewServlet -->
	    <h2>Additional Food for thought?</h2>
	   	<textarea type="text" name="comment" rows="3" cols="40" ><% out.print(comment); %></textarea>
	    <input type="hidden" name="dishID" value="<% out.print(dish.getKey().getId()); %>"></input>
	    <br /><br />
		<input type="submit" value="Add Review"></input>
	</div>
</form>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />