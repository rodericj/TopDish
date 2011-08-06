<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.topdish.comparator.DishPosReviewsComparator" %>
<%@ page import="com.topdish.comparator.RestaurantPosReviewsComparator" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>

<%
	List<Dish> dishes = TDQueryUtils.getTopDishes(10);
	List<Restaurant> restaurants = TDQueryUtils.getTopRestaurants(10);

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
	    <h1>The absolute best!<span><!-- a href="javascript:void(0)" onclick="top10Dishes();">dish</a>
	    &nbsp;&nbsp;<a href="javascript:void(0)" onclick="top10Restaurants();">restaurant</a --></span></h1>
	    <div class="top10 dishes" id="top10_dishes" style="display:block">
	    <div class="top10_separator"></div>
		<%
		for(Dish d : dishes){
			Restaurant r = null;
			Photo dishPhoto = null;
			
			try{
				r = Datastore.get(d.getRestaurant());
				if(null != d.getPhotos() && !d.getPhotos().isEmpty()){
					dishPhoto = Datastore.get(d.getPhotos().get(0));
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
<%					if(null != dishPhoto){
						final String url = dishPhoto.getURL(36);
						if(null != url){ %>
							<img class="grey_icon" src="<%=url%>" alt="<% out.print(d.getName()); %>" /><%
						} else {
							//bad image
							%><img class="grey_icon" src="style/no_dish_img.jpg" alt="<% out.print(d.getName()); %>" /><%
						}
					}else{ %>
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
				if(null != r.getPhotos() && !r.getPhotos().isEmpty()){
					restPhoto = Datastore.get(r.getPhotos().get(0));
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
	<%				if(restPhoto != null){ 
						final String url = restPhoto.getURL(36);
						if(null != url){ %>
							<img class="grey_icon" src="<%=url%>" alt="<% out.print(r.getName()); %>" /><%
						} else {
							//bad image
							%><img class="grey_icon" src="style/no_rest_img.jpg" alt="<% out.print(r.getName()); %>" /><%
						}%>
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
%>
	
	</div>
</div>