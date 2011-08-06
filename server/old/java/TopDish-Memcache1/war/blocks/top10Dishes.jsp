<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.search.AbstractSearch" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.topdish.comparator.DishPosReviewsComparator" %>
<%@ page import="com.topdish.comparator.RestaurantPosReviewsComparator" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>

<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	Point userLoc = TDUserService.getUserLocation(request);
	double maxDistance = 16093.44;	//16 093.44 meters = 10 miles
	int maxResults = 100;			//return up to 100 dishes
	List<Dish> dishes = null;
	List<Restaurant> restaurants = null;
	
	//TODO: modify GeocellManager to sort by posReviews
	// currently fetching up to 100 dishes in a 10 mile radius
	// then sorting by posReviews and showing the top 10
	// this can be done with a query that returns pre-sorted results
	
	try{
		dishes = TDQueryUtils.getTopDishes(10);
		//dishes = AbstractSearch.getDishesNearLocation(pm, maxResults, maxDistance, userLoc.getLat(), userLoc.getLon());
		restaurants = AbstractSearch.getRestaurantsNearLocation(pm, maxResults, maxDistance, userLoc.getLat(), userLoc.getLon());
	}catch(JDOObjectNotFoundException e){
		//object not found
	}
	
	if(dishes != null && restaurants != null){
		int rank = 1;
		%>
	<script type="text/javascript">
		function top10Dishes(){
			$("#top10_restaurants").hide();
			$("#top10_dishes").show();
		}
		function top10Restaurants(){
			$("#top10_restaurants").show();
			$("#top10_dishes").hide();
		}
	</script>
	
	<div class="rmenu_cont dish_splitter">
	    <h1>The absolute best!<span><a href="javascript:void(0)" onclick="top10Dishes();">dish</a>
	    &nbsp;&nbsp;<a href="javascript:void(0)" onclick="top10Restaurants();">restaurant</a></span></h1>
	    <div class="top10 dishes" id="top10_dishes" style="display:block">
	    <div class="top10_separator"></div>
		<%
		for(Dish d : dishes){
			Restaurant r = null;
			Photo dishPhoto = null;
			
			try{
				r = pm.getObjectById(Restaurant.class, d.getRestaurant());
				if(null != d.getPhotos() && !d.getPhotos().isEmpty()){
					dishPhoto = pm.getObjectById(Photo.class, d.getPhotos().get(0));
				}
			}catch(JDOObjectNotFoundException e){
				//object not found
			}
		%>
			<div class="top10_listing">
				<div class="top10_dish_rank">
					<div class="top10_rank_num">#<%=rank%></div>
					<!-- <div class="top10_rank_time">Xm</div> -->
				</div>
				<div class="top10_dish_photo">
					<a href="dishDetail.jsp?dishID=<% out.print(d.getKey().getId()); %>">
	<%				if(dishPhoto != null){ %>
						<img class="grey_icon" src="<%=ImagesServiceFactory.getImagesService().getServingUrl(dishPhoto.getBlobKey(), 36, true)%>" alt="<% out.print(d.getName()); %>" />
	<%				}else{ %>
						<img class="grey_icon" src="style/no_dish_img.jpg" alt="<% out.print(d.getName()); %>" />
	<%				} %></a>
				</div>
				<div class="top10_dish_info">
					<div class="top10_dish_name"><a href="dishDetail.jsp?dishID=<% out.print(d.getKey().getId()); %>"><%=d.getName()%></a></div>
					<div class="top10_rest_info"><a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>"><%=r.getName()%></a>, <%=r.getCity()%>, <%=r.getState()%></div>
				</div>
			</div>
			<div class="top10_separator"></div>
	<%
			rank++;
		}
	%>
		</div>
		<div class="top10 restaurants" id="top10_restaurants" style="display:none">
		<div class="top10_separator"></div>
		<%
		rank = 1;
		for(Restaurant r : restaurants){
			Photo restPhoto = null;
			try{
				if(r.getPhotos().size() > 0){
					restPhoto = pm.getObjectById(Photo.class, r.getPhotos().get(0));
				}
			}catch(JDOObjectNotFoundException e){
				//object not found
			}
		%>
			<div class="top10_listing">
				<div class="top10_dish_rank">
					<div class="top10_rank_num">#<%=rank%></div>
					<!-- <div class="top10_rank_time">Xm</div> -->
				</div>
				<div class="top10_dish_photo">
					<a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>">
	<%				if(restPhoto != null){ %>
						<img class="grey_icon" src="<%=ImagesServiceFactory.getImagesService().getServingUrl(restPhoto.getBlobKey(), 36, true)%>" alt="<% out.print(r.getName()); %>" />
	<%				}else{ %>
						<img class="grey_icon" src="style/no_rest_img.jpg" alt="<% out.print(r.getName()); %>" />
	<%				} %></a>
				</div>
				<div class="top10_dish_info">
					<div class="top10_dish_name"><a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>"><%=r.getName()%></a></div>
					<div class="top10_rest_info"><%=r.getCity()%>, <%=r.getState()%></div>
				</div>
			</div>
			<div class="top10_separator"></div>
	<%
			rank++;
		}
	}
	pm.close();
%>
	
	</div>
</div>