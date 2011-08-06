<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>

<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	long restID = Long.valueOf(request.getParameter("restID"));
	Restaurant r = (Restaurant)pm.getObjectById(Restaurant.class, restID);
	
	Query q = pm.newQuery(Dish.class);
	q.setOrdering("dateCreated desc");
	q.setRange("0,1");
	q.setFilter("restaurant == :restParam");
	List<Dish> results = (List<Dish>)q.execute(r.getKey());
	
	if(results.size() > 0){
		Dish d = results.get(0);
%>
<div class="rmenu_cont dish_splitter">
	<div class="top_dish_left">
		<h2>Recently Added</h2>
	    <div class="top_dish_left">
       		<a href="dishDetail.jsp?dishID=<% out.print(d.getKey().getId()); %>">
	       	<%	if(d.getPhotos() != null && d.getPhotos().size() > 0){ 
	       			Photo p = pm.getObjectById(Photo.class, d.getPhotos().get(0));
	       	%>
	       			<img class="dish_image_gold" src="<%=ImagesServiceFactory.getImagesService().getServingUrl(p.getBlobKey(), 98, true)%>" />
	       	<%	}else{%>
	       			<img class="dish_image_gold" src="/style/no_dish_img.jpg" />
	       	<%	} %></a>
        </div>
		<div class="dish_summary">
			<a href="dishDetail.jsp?dishID=<%=d.getKey().getId()%>"><h3><%=d.getName()%></h3></a>
			<span class="ingredients_list"></span>
			<span class="dish_description"></span>
		</div>
	</div>
	<div class="dish_listing_terminator"></div>
</div>
<%}%>