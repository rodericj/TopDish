<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Collections" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.comparator.TagManualOrderComparator" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>
<%@include file="/includes/userTagIncludes.jsp" %>

<jsp:include page="header.jsp" />
<script type="text/javascript" src="/js/TextboxList.js"></script>
<script type="text/javascript" src="/js/TextboxList.Autocomplete.js"></script>
<script type="text/javascript" src="/js/GrowingInput.js"></script>
<script type="text/javascript" src="/js/topdish.autocomplete.js"></script>



<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/newDish.jsp"/>
		<jsp:include page="/blocks/topUsers.jsp"/>
		<jsp:include page="/blocks/top10Dishes.jsp"/>
	</div>
	<div class="col2">
<%
	long dishID = 0;
	String dishIDs = request.getParameter("dishID");
	
	try{
		dishID = Long.parseLong(dishIDs);
	}catch(NumberFormatException e){
		//not a long
	}

	final Dish dish = (Dish)PMF.get().getPersistenceManager().getObjectById(Dish.class, dishID);
	final Restaurant rest = (Restaurant)PMF.get().getPersistenceManager().getObjectById(Restaurant.class, dish.getRestaurant());
	final List<Key> tagKeys = dish.getTags();
	final List<Key> photoKeys = dish.getPhotos();
	final List<Tag> categories = TagUtils.getTagsByType(Tag.TYPE_MEALTYPE);
	final List<Tag> prices = TagUtils.getTagsByType(Tag.TYPE_PRICE);
	Collections.sort(categories, new TagManualOrderComparator());
	Collections.sort(prices, new TagManualOrderComparator());
	ArrayList<Integer> tagTypes = new ArrayList<Integer>();
	tagTypes.add(Tag.TYPE_ALLERGEN);
	tagTypes.add(Tag.TYPE_GENERAL);
	tagTypes.add(Tag.TYPE_LIFESTYLE);
	tagTypes.add(Tag.TYPE_CUISINE);
	List<Tag> tags = TagUtils.filterTagsByType(TDQueryUtils.getAll(dish.getTags(), new Tag()), tagTypes);
%>

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
})
</script>


<div class="rating_header dish_splitter">
	<h1>Edit <span>dish</span></h1>
</div>

<form action="updateDish" method="post">
	<div class="rating_header">
		<h2>Location</h2>
	    <h3><% out.print(rest.getName() + " (" + rest.getAddressLine1() + ", " + rest.getCity() + ", " + rest.getState() + ")"); %></h3>
	</div>
	<div class="rating_header">
		<h2>Dish Name</h2>
	    <input type="text" class="grey_input_box grey_input_box_none" name="name" value="<% out.print(dish.getName());%>"/>
	</div>
	<div class="rating_header">
	    <h2>Dish Details</h2>
		<span class="rating_categories">Category:</span>
		<select name="categoryID">
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
	    <span class="rating_ingredients">Price:</span>
		<select name="priceID">
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
	    <br /><br />
        <p><span class="rating_categories">Tags</span> e.g. Vegetarian, Shellfish, Gluten Free, Spicy, Greasy</p>
	    <div class="tag_input tag_red">
	    	<input type="text" name="tagList" id="tag_list1"/>
	    </div>
	    <br /><br />
	    <p><span class="rating_description">Description</span> Enter a detailed description.</p>
	    <textarea name="description" id="description" rows="3" cols="40" ><% out.print(dish.getDescription());%></textarea>
	    <br /><br />
		<input type="hidden" name="dishID" id="dish_id" value="<% out.print(dish.getKey().getId());%>"></input>
	    <input type="submit" value="Update Dish"/>
	</div>
</form>
<div class="rating_header">
    <h2>Dish photos <span><a href="photoUpload.jsp?dishID=<%=dishID%>">Upload a photo!</a></span></h2>
    <div class="dish_photo">
	<%	if(photoKeys.size() > 0){ 
			for(Key k : photoKeys){ 
				Photo p = PMF.get().getPersistenceManager().getObjectById(Photo.class, k);
			%>
				<img class="dish_image_gold" src="<%=ImagesServiceFactory.getImagesService().getServingUrl(p.getBlobKey(), 250, true)%>"></img>
				
				<div class="photo_controls">
				<c:set var="dishId" value="<%=dish.getKey().getId()%>"/>
				<user:isUserInRole roles="${administrator},${standard},${advanced}" dishId="${dishId}" action="rotate">
					<form action="/rotatePhoto" method="post">
						<input type="hidden" name="photoID" value="<%=k.getId()%>" />
						<input type="hidden" name="dishID" value="<%=dish.getKey().getId()%>" />
						<input type="submit" value="Rotate Photo" />
					</form>
				</user:isUserInRole>
					<user:isUserInRole roles="${administrator}" >
					<form action="/deletePhoto" method="post">
						<input type="hidden" name="photoID" value="<%=k.getId()%>" />
						<input type="hidden" name="dishID" value="<%=dish.getKey().getId()%>" />
						<input type="submit" value="Delete Photo" />
					</form>
					</user:isUserInRole>
				</div>
				
	<%		}
		}else{ %>
			<img class="dish_image_gold" src="/style/no_dish_img.jpg"></img>
	<% 	} %>
	</div>
	<br /><br />
</div>
<user:isUserInRole roles="${administrator}" >
<form action="/deleteDish" method="post">
	<input type="hidden" name="dishID" value="<% out.print(dish.getKey().getId()); %>" />
	<input type="submit" value="Delete Dish" />
</form>
</user:isUserInRole>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />