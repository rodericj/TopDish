<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>

<%
	String dishIDs = request.getParameter("dishID");
	String cssFloat = request.getParameter("float");
	if(cssFloat == null || cssFloat.isEmpty())
		cssFloat = "left";
if(dishIDs != null)
{
	long dishID = Long.parseLong(dishIDs);
	
	int posReviews = 0;
	int negReviews = 0;

	Dish d = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), dishID));
	
	if(d.getNumPosReviews() != null)
		posReviews = d.getNumPosReviews();
	if(d.getNumNegReviews() != null)
		negReviews = d.getNumNegReviews();
	
	String userID = null;
	int vote = 0;
	if(TDUserService.isUserLoggedIn(request.getSession())){
		final TDUser user = TDUserService.getUser(session);
		vote = TDQueryUtils.getLatestUserVoteByDish(user.getKey(), d.getKey());
	}
		
%>
<div class="rating_box <% out.print(cssFloat); %>">
     <div class="rating_box_upboat">
         <div><% out.print("+" + posReviews); %></div>
         <a href="addReview.jsp?dishID=<% out.print(d.getKey().getId()); %>&amp;dir=1">
         <%	if(vote > 0) { %>
         	<img src="img/detailed/button_up_blue.png" alt="Upvote" width="55" height="38" />
         <% } else { %>
         	<img src="img/detailed/button_up_grey.png" alt="Upvote" width="55" height="38" />
         <% } %>
         </a>
     </div>
     <div class="rating_box_downboat">
         <a href="addReview.jsp?dishID=<% out.print(d.getKey().getId()); %>&amp;dir=-1">
         <%	if(vote < 0) { %>
         	<img src="img/detailed/button_down_orange.png" alt="Downvote" width="55" height="38" />
         <% } else { %>
         	<img src="img/detailed/button_down_grey.png" alt="Downvote" width="55" height="38" />
         <% } %>
         </a>
     <div><% out.print("-" + negReviews); %></div>
     </div>
 </div>	
 <%
}
%>