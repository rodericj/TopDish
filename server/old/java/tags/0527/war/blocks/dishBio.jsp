<%@ page import="java.util.Collection" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.HumanTime" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%
	long dishID = Long.parseLong(request.getParameter("dishID"));
	final Dish d = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), dishID));	
	final Set<Tag> genTags = Datastore.get(d.getTags());
	final TDUser creator = Datastore.get(d.getCreator());
	Photo dishPhoto = null;
	if(d.getPhotos() != null && d.getPhotos().size() > 0){
		dishPhoto = Datastore.get(d.getPhotos().get(0));
	}
%>
		<div class="rmenu_cont dish_splitter">
			<div class="dish_photo_small">
<%				if(dishPhoto != null){
					final String url = dishPhoto.getURL(98);
					if(null != url){%>
						<img class="user_profile_box" src="<%=url%>" alt="<% out.print(d.getName()); %>"></img>
<%					} else {
%>						<img class="user_profile_box" src="style/no_dish_img.jpg" /> <%
					}
				}else{ %>
					<img class="user_profile_box" src="style/no_dish_img.jpg" alt="<% out.print(d.getName()); %>"></img>
<%				} %>
			</div>
			
			<div class="dish_description user_profile_box">
				<div class="dish_description_text">
					<h1 class="dish_name"><%= d.getName() %>
<%						if(TDUserService.isUserLoggedIn(request.getSession(true))) {%>
						<span><a href="editDish.jsp?dishID=<% out.print(d.getKey().getId()); %>">[edit]</a></span>
<%						}%>
	           		</h1>
	           </div>
	           <span style="background-image: img/shadow.png" class='corner'></span>
           </div>
          
           <div class="rmenu_disp">
               <div class="menu_disp_detailed">
               	<% // Rating Box %>
				<jsp:include page="/blocks/ratingBoxDirectToReview.jsp">
					<jsp:param name="dishID" value="<%= dishID %>" />
					<jsp:param name="float" value="right" />
				</jsp:include>
                   <!-- <div class="dish_text_rating"><img src="img/fork_gold.png" alt="" width="40" height="10" />Delicious!</div>
                   <div class="dish_status">
                       <img src="img/availability/now_serving.png" width="55" height="23" alt="Now Serving" />
                   </div>-->
              		<h3>Tags</h3>
                   <p><% out.write(TagUtils.formatTagHTML(genTags)); %></p>
                   <% // Description %>
                   <h3>General Description</h3>
					<p><%= d.getDescription() %></p>
					<p>&nbsp;</p>
					<p>Added by: <a href="userProfile.jsp?userID=<%=creator.getKey().getId()%>"><%=creator.getNickname() %></a>
                    <div class="dish_listing_infographics">
                    <%	final Review lastReview = TDQueryUtils.getLatestReviewByDish(d.getKey());
                    	if(null != lastReview){
                    		if(lastReview.getDirection() == Review.POSITIVE_DIRECTION){%>
	                        <img src="img/up_arrow_icon.png" width="12" height="15" /><span><%= HumanTime.approximately(System.currentTimeMillis() - lastReview.getDateCreated().getTime()) %> ago</span>
	                    <%	}else{ %>
	                    	<img src="img/down_arrow_icon.png" width="12" height="15" /><span><%= HumanTime.approximately(System.currentTimeMillis() - lastReview.getDateCreated().getTime()) %> ago</span>
	                    <%	}
                    	}
                    %>
                        <img src="img/comment_icon.png" width="16" height="15" /><span><a href="dishDetail.jsp?dishID=<%= d.getKey().getId() %>">Reviews: <%=d.getNumReviews()%></a></span>
                    </div>
					<div class="dish_lat" style=""><%=d.getLocation().getLat()%></div>
                    <div class="dish_lng" style=""><%=d.getLocation().getLon()%></div>
               </div>
               <div class="dish_listing_terminator"></div>
           </div>
       </div>