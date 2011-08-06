<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.topdish.util.HumanTime" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>

<%
	long reviewID = 0;
	Review r = null;
	TDUser creator = null;
	String reviewIDs = request.getParameter("reviewID");
	
	try{
		reviewID = Long.parseLong(reviewIDs);
		r = Datastore.get(KeyFactory.createKey(Review.class.getSimpleName(), reviewID));
		creator = Datastore.get(r.getCreator());
	}catch(NumberFormatException e){
		//review ID not a long
	}catch(JDOObjectNotFoundException e){
		//review with given ID not found
	}
	// If user is a professional food critic, use the following HTML before and after their posting
	// <div class="dish_list_special_splitter"></div>
	//TODO: find a more meaningful limit for flags
	if(r != null && creator != null && r.getComment() != null && !r.getComment().equals("") && r.getNumFlagsTotal() < 5){
%>
<div class="dish_listing dish_splitter">
    <div class="dish_review">
        <div class="dish_review_side">	
			        	
	<%		if(creator.getPhoto() != null){ 
				Photo creatorPhoto = Datastore.get(creator.getPhoto());	
				final String url = creatorPhoto.getURL(36);
	%>
				<a href="userProfile.jsp?userID=<%=creator.getKey().getId()%>">
				<img class="grey_icon" src="<%=url%>"></img>
				</a>
	<%		}else{ %>
				<img class="grey_icon" src="style/no_user_img.jpg"></img>
	<%		} %>	
			<h3><a href="userProfile.jsp?userID=<%=creator.getKey().getId()%>"><%=creator.getNickname()%></a></h3>
	<%
			// if:elseif chosen incase, for some reason, a result of 0 is returned. Shouldn't happen.
			int vote = r.getDirection();
			if(vote > 0) {
	%>
            <h4 class="like"><img src="img/up_arrow_icon.png" width="12" height="15" /> Likes it</h4>
	<%		} else if (vote < 0) { %>
			<h4 class="dislike"><img src="img/down_arrow_icon.png" width="12" height="15" /> Dislikes it</h4>
	<%
			}
	%>
		<!-- 
            <div>x likes</div>
            <div>x Dislikes</div>
            <div>x Reviews</div>
            <br />
            <div>Rated on:</div>
            <div><a href="#">Value</a></div>
            <div><a href="#">Portion</a></div>
            <br />
		 -->
            <div><%= HumanTime.approximately(r.getDateCreated().getTime() - System.currentTimeMillis()) %> ago</div>
        </div>
        <div class="dish_review_main">
        	<% // Comment %>
            <p><%
			if(r.getComment() != null && !r.getComment().equals(""))
				out.print(r.getComment());
			else
				out.print("no comment");
			%></p>
            <!-- <span>Custom Ingredient Tags: <a href="#">Beer, Bacon, Horseradish Aioli, No Lettuce</a>.</span> -->
        </div>        
        <div class="dish_review_footer">
	        <span>
	        	<!-- <img src="img/green_flag.gif" width="8" height="12" />Useful(n) --> 
	        	<a href="flag.jsp?reviewID=<%=r.getKey().getId()%>"><img src="img/red_flag.gif" width="8" height="12" />Flag</a> (<%= r.getNumFlagsTotal() %>) 
	        	<!-- <img src="img/document.gif" width="8" height="12" />Message -->
	        </span>
        </div>
        <div class="dish_listing_terminator"></div>
    </div>
</div>
<%
	}
%>