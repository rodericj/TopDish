<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>
<%@include file="/includes/userTagIncludes.jsp" %>
<jsp:include page="header.jsp" />
<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	
	long restID = Long.valueOf(request.getParameter("restID"));	
	Restaurant found = (Restaurant)pm.getObjectById(Restaurant.class, restID);
%>
<h2>Edit Restaurant</h2>
<div class="restaurant_photo_large">
<%		if(!found.getPhotos().isEmpty()){
			Photo p = pm.getObjectById(Photo.class, found.getPhotos().get(0));
			
			try{
				String url = ImagesServiceFactory.getImagesService().getServingUrl(p.getBlobKey(), 250, false);
%>				<img src="<%=url%>"></img><%
			}catch(Exception e){
				//image serving problem
			}
%>
		<user:isUserInRole roles="${administrator}" >
		<form action="/deletePhoto" method="post">
			<input type="hidden" name="photoID" value="<%=found.getPhotos().get(0).getId()%>" />
			<input type="hidden" name="restID" value="<%=found.getKey().getId()%>" />
			<input type="submit" value="Delete Photo" />
		</form>
		</user:isUserInRole>
<%		}else{ %>
		<img src="style/no_rest_img.jpg"></img>
<%		} %>	
</div>
<a href="photoUpload.jsp?restID=<%=restID%>">Upload a photo!</a>
<br />
<br />
<user:isUserInRole roles="${administrator}" >
<form action="deleteRestaurant" method="post">
	<input type="hidden" name="restID" value="<% out.print(found.getKey().getId()); %>"></input>
	<input type="submit" value="Delete Restaurant"></input>
</form>
</user:isUserInRole>
<br />
<form action="updateRestaurant" method="post">
	<br><label>Name: <input type="text" name="name" value="<% out.print(found.getName()); %>"></input></label><br>
	<br><label>Address Line 1: <input type="text" name="address1" value="<% out.print(found.getAddressLine1()); %>"></input></label><br>
	<br><label>Address Line 2: <input type="text" name="address2" value="<% out.print(found.getAddressLine2()); %>"></input></label><br>
	<br><label>City: <input type="text" name="city" value="<% out.print(found.getCity()); %>"></input></label><br>
	<br><label>State: <input type="text" name="state" value="<% out.print(found.getState()); %>"></input></label><br>
	<br><label>Phone: <input type="text" name="phone" value="<% out.print(found.getPhone().getNumber()); %>"></input></label><br>
	<br><label>Neighborhood: <input type="text" name="neighborhood" value="<% out.print(found.getNeighborhood()); %>"></input></label><br>
	<br><label>Website: <input type="text" name="url" value="<% out.print(found.getUrl().getValue()); %>"></input></label><br>
	<br><label>Cuisine:
	<select name="cuisine_id" id="cuisine">
		<%
			Query query = pm.newQuery(Tag.class);
			List<Tag> cuisines;
			query.setFilter("type == typeParam");
		    query.declareParameters("int typeParam");
		    query.setOrdering("manualOrder ASC"); //manual order
			cuisines = (List<Tag>) query.execute(Tag.TYPE_CUISINE); //only cuisines
			if(null == found.getCuisine()){
				out.print("<option value=\"\" selected>Please Select One</option>\n");
			}
			
			for (Tag c : cuisines) {
				if(c.getKey() == found.getCuisine()){
					out.print("<option value=\"" + c.getKey().getId() + "\" selected=\"selected\">" + c.getName() + "</option>\n");
				}else{
					out.print("<option value=\"" + c.getKey().getId() + "\">" + c.getName() + "</option>\n");
				}
			}
		%>
	</select></label><br>
		
	<br><input type="hidden" name="restID" value="<% out.print(found.getKey().getId()); %>"></input><br>
	<br /><input type="submit" value="Update Restaurant"></input>
</form>
<br />
<jsp:include page="footer.jsp" />