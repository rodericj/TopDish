<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>
<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	long restID = Long.valueOf(request.getParameter("restID"));

	try{
		Restaurant r = pm.getObjectById(Restaurant.class, restID);
%>
<div class="restaurant_full dish_listing_details dish_splitter dish_listing">
	<div class="restaurant_photo_small">
	
<%		if(r.getPhotos().size() > 0){ 
			Photo dishPhoto = pm.getObjectById(Photo.class, r.getPhotos().get(0));
%>
			<img class="dish_image_gold" src="<%=ImagesServiceFactory.getImagesService().getServingUrl(dishPhoto.getBlobKey(), 98, false)%>"></img>
<%		}else{ %>
			<img class="dish_image_gold" src="style/no_rest_img.jpg"></img>
<%		} %>	
	</div>

		<div class="restaurant_name">
		<a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>">
			<% out.print(StringEscapeUtils.escapeHtml(r.getName())); %>
		</a>
<%
			if(TDUserService.getUserLoggedIn()){
%>
				&nbsp;&nbsp;
				<a href="editRestaurant.jsp?restID=<% out.print(r.getKey().getId()); %>">[edit]</a>
<%
			}
%>		
		</div>
		<div class="restaurant_address">
			<% out.print(StringEscapeUtils.escapeHtml(r.getAddressLine1())); %>
		</div>
		<div class="restaurant_city_state">
			<% out.print(StringEscapeUtils.escapeHtml(r.getCity()) + ", "); %>
			<% out.print(StringEscapeUtils.escapeHtml(r.getState())); %>
		</div>
		<div class="restaurant_neighborhood">
			<% out.print(StringEscapeUtils.escapeHtml(r.getNeighborhood())); %>
		</div>
        <div class="dish_listing_terminator"></div>
</div>
<%
  	}
  	finally
  	{
  		pm.close();
  	}
%>