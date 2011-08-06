<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.TDMathUtils" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="com.beoui.geocell.model.Point" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	long restID = Long.valueOf(request.getParameter("restID"));
	Restaurant r = (Restaurant)pm.getObjectById(Restaurant.class, restID);
	Point userLoc = ((TDPoint)request.getSession().getAttribute("userLocationPoint")).getPoint();
	String distance = TDMathUtils.formattedGeoPtDistanceMiles(userLoc, r.getLocation());
	String primaryUrl = "http://"+request.getRequestURL().toString().split("/")[2];  
%>

<div class="rmenu_cont dish_splitter">
    <h1>
    Restaurant Information
    <c:if test="${param.limitedView ne 'true'}">
    <span><a href="flag.jsp?restaurantID=${param.restID}&dishId=${param.dishID}"><img src="img/red_flag.gif" width="8" height="12" />Flag</a> (<%=r.getNumFlagsTotal()%>)</span>
    </c:if>
    </h1>
   
    <div class="rmenu_disp">
    	  <div class="top_dish_left">
           <a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>">
		<%	if(r.getPhotos().size() > 0) { 
				Photo p = pm.getObjectById(Photo.class, r.getPhotos().get(0));
%>
           		<img class="grey_icon left" src="<%=ImagesServiceFactory.getImagesService().getServingUrl(p.getBlobKey(), 98, true)%>"/>
           <%	} else { %>
           		<img class="grey_icon left" src="style/no_rest_img.jpg" />
           <%	} %></a>
           </div>
           <div class="top_dish_right">
               <h3><a href="restaurantDetail.jsp?restID=<% out.print(r.getKey().getId()); %>"><% out.print(StringEscapeUtils.escapeHtml(r.getName())); %></a></h3>
               <p>
					<% out.print(StringEscapeUtils.escapeHtml(r.getAddressLine1())); %>
               </p>
               <p>
					<% out.print(StringEscapeUtils.escapeHtml(r.getCity())); %>,
					<% out.print(StringEscapeUtils.escapeHtml(r.getState())); %>
               </p>
               <p><% out.print(StringEscapeUtils.escapeHtml(r.getPhone().getNumber())); %></p>
               <%
					if(r.getNeighborhood() != null && !r.getNeighborhood().equals("")){
						%>
						<p>Neighborhood: <a href="#"><% out.print(StringEscapeUtils.escapeHtml(r.getNeighborhood())); %></a></p>
						<%
					}
               %>
               <p><%=distance%> Miles Away</p>
           </div>
           <div class="dish_listing_terminator"></div>
    </div>
</div>