<%@ page import="com.topdish.adminconsole.TopDishConstants"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.comparator.TagManualOrderComparator" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ include file="/includes/userTagIncludes.jsp" %>

<script src="../../js/admin/topdish.adminconsole.explorer.js" type="text/javascript" ></script>
<script src="../../js/jquery-1.4.2.min.js" type="text/javascript"></script>
<script src="../../js/jquery-ui-1.8.1.custom.min.js" type="text/javascript"></script>
<script src="../../js/admin/jquery.form.js" type="text/javascript"></script>
<script src="../../js/TextboxList.js" type="text/javascript" ></script>
<script src="../../js/TextboxList.Autocomplete.js" type="text/javascript" ></script>
<script src="../../js/GrowingInput.js" type="text/javascript" ></script>

<%
	long dishID = 0;
	String dishIDs = request.getParameter("dishID");
	
	try{
		dishID = Long.parseLong(dishIDs);
	}catch(NumberFormatException e){
		//not a long
	}

	final Dish dish = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), dishID));
	final Restaurant rest = Datastore.get(dish.getRestaurant());
	final Set<Key> tagKeys = dish.getTags();
	final Set<Photo> photos = Datastore.get(dish.getPhotos());
	final List<Tag> categories = new ArrayList<Tag>(TagUtils.getTagsByType(Tag.TYPE_MEALTYPE));
	final List<Tag> prices = new ArrayList<Tag>(TagUtils.getTagsByType(Tag.TYPE_PRICE));
	Collections.sort(categories, new TagManualOrderComparator());
	Collections.sort(prices, new TagManualOrderComparator());
	final Set<Tag> allTags = Datastore.get(dish.getTags());
	Integer[] tagTypes = {Tag.TYPE_ALLERGEN, Tag.TYPE_CUISINE, Tag.TYPE_GENERAL, Tag.TYPE_INGREDIENT, Tag.TYPE_LIFESTYLE};
	final Set<Tag> tags = TagUtils.filterTagsByType(allTags, Arrays.asList(tagTypes));

	BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	String blobUploadURL = blobstoreService.createUploadUrl("/addPhoto");
%>

<div class="editTitleHeader_2cols">Edit Dish </div>
<div id="col2Div">
	<div id="col2Right">
		<form action="/updateDish" method="post" id="updateDishForm">
			<div class="rating_header" >
				<div class="editTitle">Location</div>
				<% out.print(rest.getName() + " (" + rest.getAddressLine1() + ", " + rest.getCity() + ", " + rest.getState() + ")"); %>
			</div>
			<div class="rating_header">
				<div class="editTitle">Dish Name</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" id="dish_name" name="name" value="<% out.print(dish.getName());%>"/>
			</div>
			<div class="rating_header">
			    <div class="editTitle">Edit Details</div>
				<div class="twodetailbox">
					<div class="detailTitle" >Category:</div>
					<div class="detailBox" >
						<select name="categoryID" id="category_ID" style="width:80px;">
							<%
								out.print("<option value=\"\"></option>");
								for (Tag c : categories) {
									out.print("<option value=\"" + c.getKey().getId() + "\"");
									if(tagKeys.contains(c.getKey())){
										out.print(" selected");
									}
									out.print(">" + c.getName() + "</option>");			
								}
							%>
						</select>
					</div>
					
			    	<div class="detailTitle">Price:</div>
					<div class="detailBox" >
						<select name="priceID" id="price_ID" style="width:80px;">
							<%
								out.print("<option value=\"\"></option>");
								for (Tag p : prices) {
									out.print("<option value=\"" + p.getKey().getId() + "\"");
									if(tagKeys.contains(p.getKey())){
										out.print(" selected");
									}
									out.print(">" + p.getName() + "</option>");				}
							%>
						</select>
					</div>
				</div>
			</div>
			<div class="rating_header">
		        <div class="editTitle">Tags</div> 
				<div class="editTitleDesc">e.g. Vegetarian, Shellfish, Gluten Free, Spicy, Greasy</div>
			    <div class="tag_input tag_red">
			    	<input type="text" name="tagList" id="tag_list1"/>
			    </div>
			</div>
			<div class="rating_header">
			    <div class="editTitle">Description</div> 
				<div class="editTitleDesc">Enter a detailed description</div>
			    <textarea name="description" id="describe" rows="3" cols="35" ><% out.print(dish.getDescription());%></textarea>
			    <input type="hidden" name="dishID" id="dish_id" value="<% out.print(dish.getKey().getId());%>"></input>
			</div>
			<div class="rating_header">
				<input type="hidden" name="ajax" value="true" />
				<input type="button" value="Cancel" class="submitButton" id="cancel"/>
		    	<input type="submit" value="Update Dish" class="submitButton" id="updateDish"/>
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
					<div class="photoDescTitleBox"><input type="hidden" name="dishID" value="<%=dishID%>"><input type="hidden" name="callType" value="<%= TopDishConstants.CALL_TYPE_AJAX %>"/><input type="submit" value="Add Photo" class="submitButton" id="addPhotId"></div>
				</div>
			</form>
		</div>
		
		<div class="rating_header" style="padding-top:15px;">
		<%	if(! photos.isEmpty()){ 
				for(Photo p : photos){ %>
			   		 <div class="photoDiv">
						<img src="<%=p.getURL(250)%>" class="photoImage"  />
						<div class="photo_controls">
							<div id="photoRot">
								<c:set var="dishId" value="<%=dish.getKey().getId()%>"/>
								<form action="/rotatePhoto" method="post" class="rotatFrm" >
									<input type="hidden" name="photoID" value="<%=p.getKey().getId()%>" />
									<input type="hidden" name="dishID" value="<%=dish.getKey().getId()%>" />
									<input type="hidden" name="callType" value="<%= TopDishConstants.CALL_TYPE_AJAX %>"/>
									<input type="submit" value="Rotate Photo" class="submitButton"/>
								</form>
							</div>
							<div id="photoDel">
								<form action="/deletePhoto" method="post" class="delPhtFrm" >
									<input type="hidden" name="photoID" value="<%=p.getKey().getId()%>" />
									<input type="hidden" name="dishID" value="<%=dish.getKey().getId()%>" />
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

<script type="text/javascript">
	$(function(){
		var tagList = new $.TextboxList('#tag_list1',{
			unique: true, 
			bitsOptions:{
				editable:{addKeys: 188}
			},
			plugins: {
				autocomplete: {
					queryRemote: true,
					remote: {url: '/tagAutoComplete', param: 'q'},
					minLength: 1,
				}
			}
		});
	
	<%	for(Tag t : tags){ %>
			tagList.add('<%=t.getName()%>', '<%=t.getKey().getId()%>');
	<%  } %>
	});
</script>