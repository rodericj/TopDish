<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.util.TDMathUtils" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.comparator.DishDateCreatedComparator" %>
<%@ page import="com.topdish.search.AbstractSearch" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>

<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	double maxDistance = 0;
	int maxResults = 250;
	String distance = "0.0";
	Point userLoc = TDUserService.getUserLocation(request);
	List<Dish> results = AbstractSearch.getDishesNearLocation(pm, maxResults, maxDistance, userLoc.getLat(), userLoc.getLon(),
			new DishDateCreatedComparator());

	if(results.size() > 0){
		Dish d = results.get(0);	//the "newest" dish in the list of the 250 "nearest" dishes
		Restaurant r = pm.getObjectById(Restaurant.class, d.getRestaurant());
		distance = TDMathUtils.formattedGeoPtDistanceMiles(userLoc, d.getLocation());
		TDUser creator = pm.getObjectById(TDUser.class, d.getCreator());
%>
<div class="rmenu_cont dish_splitter">
	<h1>New To TopDish Near You</h1>
   
    <div class="rmenu_disp">
    	<div class="top_dish">
        	<div class="top_dish_left">
        	<a href="dishDetail.jsp?dishID=<% out.print(d.getKey().getId()); %>">
        	<%	if(d.getPhotos() != null && d.getPhotos().size() > 0){
        			Photo p = pm.getObjectById(Photo.class, d.getPhotos().get(0));
        			try{
        			String url = ImagesServiceFactory.getImagesService().getServingUrl(p.getBlobKey(), 98, true);%>
        			<img class="dish_image_gold" src="<%=url%>" />
        	<%		}catch(Exception e){
        	%>			<img class="dish_image_gold" src="style/no_dish_img.jpg" /> <%
        			}
        		}else{%>
        			<img class="dish_image_gold" src="style/no_dish_img.jpg" />
        	<%	} %></a>
            </div>
            <div class="top_dish_right">
                <h2><a href="dishDetail.jsp?dishID=<% out.print(d.getKey().getId()); %>"><% out.print(StringEscapeUtils.escapeHtml(d.getName())); %></a></h2>
                <h3><a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>"><% out.print(StringEscapeUtils.escapeHtml(r.getName())); %></a></h3>
                <p><%=r.getCity()%>, <%=r.getState()%></p>
                <p><%=r.getPhone().getNumber()%></p>
                <% if(r.getNeighborhood() != null && !r.getNeighborhood().equals("")){%>
                	<p>Neighborhood: <a href="#"><%=r.getNeighborhood()%></a></p>
                <%} %>
                <p><%=distance%> Miles Away</p>
                <p>&nbsp;</p>
                <p>Added by: <a href="userProfile.jsp?userID=<%=creator.getKey().getId()%>"><%=creator.getNickname() %></a>
            </div>
            <div class="dish_listing_terminator"></div>
        </div>
    </div>
</div>
<% } %>