<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.HumanTime" %>
<%
	long dishID = Long.parseLong(request.getParameter("dishID"));
	final Dish d = PMF.get().getPersistenceManager().getObjectById(Dish.class, dishID);
	final List<Tag> genTags = TDQueryUtils.getAll(d.getTags(), new Tag());
	final TDUser creator = PMF.get().getPersistenceManager().getObjectById(TDUser.class, d.getCreator());
%>
		<div class="rmenu_cont dish_splitter">
			<h1 class="dish_name"><%= d.getName() %>
<%			if(TDUserService.getUserLoggedIn()) {%>
				<span><a href="editDish.jsp?dishID=<% out.print(d.getKey().getId()); %>">[edit]</a></span>
<%			}%>
           </h1>
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
                   <div class="dish_listing_infographics">
					<% Key lastReviewKey = TDQueryUtils.getLatestReviewByDish(d.getKey());
						if(lastReviewKey != null){
							final Review lastReview = PMF.get().getPersistenceManager().getObjectById(Review.class, lastReviewKey);
							if(lastReview.getDirection() == Review.POSITIVE_DIRECTION){ %>
	                        <img src="img/up_arrow_icon.png" width="12" height="15" /><span><%= HumanTime.approximately(lastReview.getDateCreated().getTime() - System.currentTimeMillis()) %> ago</span>
	                    <%	}else{ %>
	                    	<img src="img/down_arrow_icon.png" width="12" height="15" /><span><%= HumanTime.approximately(lastReview.getDateCreated().getTime() - System.currentTimeMillis()) %> ago</span>
	                    <%	}
						}%>
						<img src="img/up_arrow_icon.png" width="12" height="15" /><span>Reviews:<%=d.getNumReviews()%></span>
                   </div>
                    <p>Added by: <a href="userProfile.jsp?userID=<%=creator.getKey().getId()%>"><%=creator.getNickname() %></a>
					<div class="dish_lat" style=""><%=d.getLocation().getLat()%></div>
                    <div class="dish_lng" style=""><%=d.getLocation().getLon()%></div>       
               </div>
               <div class="dish_listing_address" style="display:none"></div>
               <div class="dish_listing_terminator"></div>
           </div>
       </div>