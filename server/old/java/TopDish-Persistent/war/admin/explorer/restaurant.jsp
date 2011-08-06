<%@ page import="com.topdish.adminconsole.TopDishConstants"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.comparator.TagManualOrderComparator" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ include file="/includes/userTagIncludes.jsp" %>

<script src="../../js/jquery-1.4.2.min.js" type="text/javascript"></script>
<script src="../../js/jquery-ui-1.8.1.custom.min.js" type="text/javascript"></script>
<script src="../../js/admin/jquery.form.js" type="text/javascript"></script>
<script src="../../js/admin/topdish.adminconsole.explorer.js" type="text/javascript" ></script>

<%
	String phone = "";
	String url = "";
	
	long restID = Long.parseLong(request.getParameter("restID"));	
	final Restaurant rest = Datastore.get(KeyFactory.createKey(Restaurant.class.getSimpleName(), restID));
	final Set<Photo> photos = Datastore.get(rest.getPhotos()); 

	if(null != rest.getPhone()){
		phone = rest.getPhone().getNumber();
	}
	if(null != rest.getUrl()){
		url = rest.getUrl().getValue();
	}
	
	
    BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	String blobUploadURL = blobstoreService.createUploadUrl("/addPhoto");
%>

<div class="editTitleHeader_2cols">Edit Restaurant</div>
<div id="col2Div">
	<div id="col2Right">
		<form action="/updateRestaurant" method="post" id="updateRestForm">
			<div class="rating_header" >
				<div class="editTitle">Name:</div>
				<input type="text" class="grey_input_box grey_input_box_none" name="name" id="name" value="<%= rest.getName() %>"/>

			</div>
			<div class="rating_header">
				<div class="editTitle">Address Line1</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" name="address1" id="address1" value="<%= rest.getAddressLine1() %>"/>
			</div>
			<div class="rating_header">
				<div class="editTitle">Address Line2</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" name="address2" id="address2" value="<%= rest.getAddressLine2() %>"/>
			</div>
			<div class="rating_header">
				<div class="editTitle">City</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" name="city" id="city" value="<%= rest.getCity() %>"/>
			</div>

			<div class="rating_header">
				<div class="editTitle">State</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" name="state" id="state" value="<%= rest.getState() %>"/>
			</div>
			<div class="rating_header">
				<div class="editTitle">Phone</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" name="phone" id="phone" value="<%= phone %>"/>
			</div>
			<div class="rating_header">
				<div class="editTitle">Neighborhood</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" name="neighborhood" id="neighborhood" value="<%= rest.getNeighborhood() %>"/>
			</div>
			<div class="rating_header">
				<div class="editTitle">Website</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" name="url" value="<%= url %>"/>
			</div>
			<div class="rating_header">
				<div class="editTitle">Cuisine</div>
			   	<select name="cuisine_id" id="cuisine">
			   	<%
			   		final ArrayList<Tag> cuisines = new ArrayList<Tag>(TagUtils.getTagsByType(Tag.TYPE_CUISINE));

					if(null == rest.getCuisine()){
			   			out.print("<option value=\"\" selected></option>\n");
					}
					if(null != cuisines){
			   			Collections.sort(cuisines, new TagManualOrderComparator());
			   		
						for (Tag c : cuisines) {
							if(null != rest.getCuisine() && rest.getCuisine().getId() == c.getKey().getId()){
								out.print("<option value=\"" + c.getKey().getId() + "\" selected=\"selected\">" + c.getName() + "</option>\n");
							}else{
								out.print("<option value=\"" + c.getKey().getId() + "\">" + c.getName() + "</option>\n");
							}
						}
					}
				%>
				</select>
			</div>
			<div class="rating_header">
			    <input type="hidden" name="restID" id="rest_id" value="<% out.print(rest.getKey().getId()); %>"></input>
			</div>
			<div class="rating_header">
		    	<input type="hidden" name="ajax" value="true" />
		    	<input type="button" value="Cancel" class="submitButton" id="cancel"/>
		    	<input type="submit" value="Update Restaurant" class="submitButton"/>
			</div>
		</form>
	</div>
	<div id="col2left">
		<div class="rating_header">
		    <div class="editTitle" style="padding-bottom:10px;">Dish photos <span><a href="#" id="ulPhotoAId">Upload a photo!</a></span></div> 
		</div>
		<div id="uploadPhotoDiv">
			<div class="editTitle">Add Photo</div>
			<form action="<%=blobUploadURL %>" method="post" enctype="multipart/form-data" id="updatePhotoId">
				<div class="rating_header">
					<div class="photoDescTitle">Photo:</div><div class=""><input type="file" name="myFile"></input></div>
				</div>
				<div class="rating_header">
					<div class="photoDescTitle">Description:</div><div class=""><input type="text" name="description"></input></div>	<div></div>
				</div>
			
				<div class="rating_header">
					<div class="photoDescTitleBox"><input type="hidden" name="restID" value="<%=restID%>"><input type="hidden" name="callType" value="<%= TopDishConstants.CALL_TYPE_AJAX %>"/><input type="submit" value="Add Photo" class="submitButton" id="addPhotId"></div>
				</div>
			</form>
		</div>
		
		<div class="rating_header" style="padding-top:15px;">
		<%	if(!photos.isEmpty()){ 
				for(Photo p : photos){%>
		   		 <div class="photoDiv">
					<img src="<%= p.getURL(250)%>" class="photoImage"  />
					<div class="photo_controls_single">

						<div id="photoDel">
							<form action="/deletePhoto" method="post" class="delPhtFrm" >
								<input type="hidden" name="photoID" id="photoID" value="<%=p.getKey().getId()%>" />
								<input type="hidden" name="restID" value="<%=rest.getKey().getId()%>" />
								<input type="hidden" name="callType" value="<%= TopDishConstants.CALL_TYPE_AJAX %>"/>
								<input type="submit" value="Delete Photo" class="submitButton"  />
							</form>
							
						</div>
					</div>
				 </div>
			<%	}
			}else{ %>
				<div class="photoDiv">
					<img class="dish_image_gold" src="/style/no_dish_img.jpg"></img>
			 	</div>
		<% 	} %> 
		</div>	
	</div><!--left-->
</div><!--div2-->
<div id="messageId" class="editFooter_2cols"></div>