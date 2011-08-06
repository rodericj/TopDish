<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>

<%
	long restID = Long.valueOf(request.getParameter("restID"));
	Restaurant r = Datastore.get(KeyFactory.createKey(Restaurant.class.getSimpleName(), restID));
%>
<div class="restaurant_full dish_listing_details dish_splitter dish_listing">
	<div class="restaurant_photo_small">
	
<%		if(r.getPhotos().size() > 0){ 
			Photo dishPhoto = Datastore.get(r.getPhotos().get(0));
			final String url = dishPhoto.getURL(98);%>
			<img class="dish_image_gold" src="<%=url%>"></img>
<%		}else{ %>
			<img class="dish_image_gold" src="style/no_rest_img.jpg"></img>
<%		} %>	
	</div>

		<div class="restaurant_name">
		<a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>">
			<% out.print(r.getName()); %>
		</a>
<%
			if(TDUserService.isUserLoggedIn(request.getSession(true))){
%>
				&nbsp;&nbsp;
				<a href="editRestaurant.jsp?restID=<% out.print(r.getKey().getId()); %>">[edit]</a>
<%
			}
%>		
		</div>
		<div class="restaurant_address">
			<% out.print(r.getAddressLine1()); %>
		</div>
		<div class="restaurant_city_state">
			<% out.print(r.getCity() + ", "); %>
			<% out.print(r.getState()); %>
		</div>
		<div class="restaurant_neighborhood">
			<% out.print(r.getNeighborhood()); %>
		</div>
        <div class="dish_listing_terminator"></div>
</div>