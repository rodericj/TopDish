<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.TDMathUtils" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>


<%
	long restID = Long.valueOf(request.getParameter("restID"));
	Restaurant r = Datastore.get(KeyFactory.createKey(Restaurant.class.getSimpleName(), restID));
	Point userLoc = TDUserService.getUserLocation(request);
	String distance = TDMathUtils.formattedGeoPtDistanceMiles(userLoc, r.getLocation());
%>

<div class="rmenu_cont dish_splitter">
    <h1>Restaurant Information</h1>
   
    <div class="rmenu_disp">
           <div class="top_dish_left">
           <a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>">
		<%	if(null != r.getPhotos() && !r.getPhotos().isEmpty()) {
				try{
					Photo p = Datastore.get(r.getPhotos().get(0));
					final String url = p.getURL(98);
		%>			<img class="grey_icon left" src="<%=url%>"/><%
				}catch(Exception e){
					e.printStackTrace();
		%>     		<img class="grey_icon left" src="style/no_rest_img.jpg" /><%
				} %>
		<%	} else { %>
           		<img class="grey_icon left" src="style/no_rest_img.jpg" />
		<%	} %></a>
           </div>
           <div class="top_dish_right">
               <h3><a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>"><% out.print(StringEscapeUtils.escapeHtml(r.getName())); %></a></h3>
               <p>
					<% out.print(r.getAddressLine1()); %>
               </p>
               <p>
					<% out.print(r.getCity()); %>,
					<% out.print(r.getState()); %>
               </p>
               <p><% out.print(r.getPhone().getNumber()); %></p>
               <%
					if(r.getNeighborhood() != null && !r.getNeighborhood().equals("")){
						%>
						<p>Neighborhood: <a href="#"><% out.print(r.getNeighborhood()); %></a></p>
						<%
					}
               %>
               <p><%=distance%> Miles Away</p>
           </div>
           <div class="dish_listing_terminator"></div>
    </div>
</div>