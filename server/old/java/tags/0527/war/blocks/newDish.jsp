<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.util.TDMathUtils" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.comparator.DishDateCreatedComparator" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<%@ page import="java.util.Collections" %>

<%
	String distance = "0.0";
	final Point userLoc = TDUserService.getUserLocation(request);
	final Set<Dish> results = TDQueryUtils.getNewestDishes(1);

	if(null != results && !results.isEmpty()){
		final Iterator<Dish> i = results.iterator();
		final Dish d = i.next();
		final Restaurant r = Datastore.get(d.getRestaurant());
		
		distance = TDMathUtils.formattedGeoPtDistanceMiles(userLoc, d.getLocation());
		final TDUser creator = Datastore.get(d.getCreator());
%>
<div class="rmenu_cont dish_splitter">
	<h1>New To TopDish Near You</h1>
   
    <div class="rmenu_disp new_dish_box new_dish">
    	<div class="top_dish">
        	<div class="top_dish_left">
        	<a href="dishDetail.jsp?dishID=<% out.print(d.getKey().getId()); %>">
        	<%	if(d.getPhotos() != null && d.getPhotos().size() > 0){
        			Photo p = Datastore.get(d.getPhotos().get(0));
        			final String url = p.getURL(98);
        			if (null != url) { %>
	        			<img class="dish_image_gold" src="<%=url%>" />
        	<%		} else { %>
        				<img class="dish_image_gold" src="style/no_dish_img.jpg" /> <%
        			}
        		}else{%>
        			<img class="dish_image_gold" src="style/no_dish_img.jpg" />
        	<%	} %></a>
            </div>
            <div class="top_dish_right">
                <h2><a href="dishDetail.jsp?dishID=<% out.print(d.getKey().getId()); %>"><% out.print(d.getName()); %></a></h2> <% // StringEscapeUtils.escapeHtml doesn't support UTF-8 %>
                <h3><a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>"><% out.print(r.getName()); %></a></h3>
                <p><%=r.getCity()%>, <%=r.getState()%></p>
                <% if(r.getNeighborhood() != null && !r.getNeighborhood().equals("")){%>
                	<p>Area: <a href="#"><%=r.getNeighborhood()%></a></p>
                <%} %>
                <p><%=distance%> Miles Away</p>
                <p>&nbsp;</p>
                <p>Added by: <a href="userProfile.jsp?userID=<%=creator.getKey().getId()%>"><%=creator.getNickname() %></a>
            </div>
            <div class="dish_listing_terminator"></div>
        </div>
    	<span style="background-image: img/shadow.png" class="shadow"></span>
    </div>
</div>
<% } %>