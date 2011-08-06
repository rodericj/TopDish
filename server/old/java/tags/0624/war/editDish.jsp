<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.jdo.TDUserRole" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.topdish.comparator.TagManualOrderComparator" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@include file="/includes/userTagIncludes.jsp" %>

<jsp:include page="header.jsp" />
<script type="text/javascript" src="/js/TextboxList.js"></script>
<script type="text/javascript" src="/js/TextboxList.Autocomplete.js"></script>
<script type="text/javascript" src="/js/GrowingInput.js"></script>
<script type="text/javascript" src="/js/topdish.autocomplete.js"></script>
<script type="text/javascript" src="/js/jquery.ui.position.min.js"></script>
<script type="text/javascript" src="/js/topdish.confirmdialog.js"></script>

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

	final Dish dish = Datastore.get(KeyFactory.createKey(Dish.class.getSimpleName(), dishID));
	final Restaurant rest = Datastore.get(dish.getRestaurant());
	final Set<Key> tagKeys = dish.getTags();
	final List<Tag> categories = new ArrayList<Tag>(TagUtils.getTagsByType(Tag.TYPE_MEALTYPE));
	final List<Tag> prices = new ArrayList<Tag>(TagUtils.getTagsByType(Tag.TYPE_PRICE));	
	Collections.sort(categories, new TagManualOrderComparator());
	Collections.sort(prices, new TagManualOrderComparator());
	List<Integer> tagTypes = new ArrayList<Integer>();
	tagTypes.add(Tag.TYPE_ALLERGEN);
	tagTypes.add(Tag.TYPE_GENERAL);
	tagTypes.add(Tag.TYPE_LIFESTYLE);
	tagTypes.add(Tag.TYPE_CUISINE);
	
	// Only allow Admins to add Ingredient tags
	if(TDUserService.getUser(session).getRole() == TDUserRole.ROLE_ADMIN)
		tagTypes.add(Tag.TYPE_INGREDIENT);
		
	Set<Tag> foundTags = Datastore.get(dish.getTags());
	Set<Tag> tags = TagUtils.filterTagsByType(foundTags, tagTypes);
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
				out.print(">" + p.getName() + "</option>");				
			}
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
	<%	if(null != dish.getPhotos() && !dish.getPhotos().isEmpty()){
			for(Key k : dish.getPhotos()){
				try{
					final Photo p = Datastore.get(k);
					final String url = p.getURL(250);
				%>
					<img class="dish_image_gold" src="<%=url%>"></img>
                    <%
					
					Set<Key> sourceKeys = p.getSources().keySet();
					
					if(!sourceKeys.isEmpty()) { 
					 out.print("Sourced from: ");
					 
					 Set<Source> sourcesSet = Datastore.get(sourceKeys);
					 Iterator<Source> sources = sourcesSet.iterator();
					 
					 //for(final Source source : sources) {
					 while(sources.hasNext()) {
					 	final Source source = sources.next();
						final String photoLinkURL = p.getForeignIdForSource(source.getKey());
						
						out.print("<a href=\""+(!photoLinkURL.isEmpty() ? photoLinkURL : source.getUrl())+"\">"+source.getName()+"</a>" + (sources.hasNext() ? ", " : ""));
					 }
					}
					
					%>
					<c:set var="req" value="<%= request %>"/>
					<user:isUserInRole roles="${administrator},${advanced}" dishId="${dishId}" action="rotate" req="${req}">
						<div class="photo_controls">
							<form action="/rotatePhoto" method="post">
								<input type="hidden" name="photoID" value="<%=k.getId()%>" />
								<input type="hidden" name="dishID" value="<%=dish.getKey().getId()%>" />
								<input type="submit" value="Rotate Photo" />
							</form>
							<form id="delete-photo-form" action="/deletePhoto" method="post">
                                <input type="hidden" name="photoID" value="<%=k.getId()%>" />
                                <input type="hidden" name="dishID" value="<%=dish.getKey().getId()%>" />
                                <input id="delete-photo-button" type="submit" value="Delete Photo" />
                            </form>
                            <div id="delete-photo-dialog" title="Delete Photo" style="display:none;">
                                <p>Are you sure you want to delete this photo?<br></p>
                            </div>
						</div>
					</user:isUserInRole>
<%				}catch(Exception e){
					//null blobkey
					e.printStackTrace();
				}
			}
		}else{ %>
			<img class="dish_image_gold" src="style/no_dish_img.jpg"></img>
	<% 	} %>
	</div>
	<br /><br />
</div>
<c:set var="req" value="<%= request %>"/>
<user:isUserInRole roles="${administrator}" req="${req}">
<form id="delete-dish-form" action="/deleteDish" method="post">
	<input type="hidden" name="dishID" value="<% out.print(dish.getKey().getId()); %>" />
	<input id="delete-dish-button" type="submit" value="Delete Dish" />
	<div id="delete-dish-dialog" title="Delete Dish" style="display:none;">
	   <p>Are you sure you want to delete this dish?</p>
	</div>
</form>
</user:isUserInRole>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />