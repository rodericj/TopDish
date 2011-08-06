<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.jdo.TDUser" %>
<%@ page import="com.topdish.exception.UserNotFoundException" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<%
	TDUser user = null;
	try{
		user = TDUserService.getUser(session); 
	}catch(UserNotLoggedInException e){
%>
		<jsp:forward page="index.jsp" />
<% 
		
	}catch(UserNotFoundException e){
%>
		<jsp:forward page="index.jsp" />
<% 
	}
%>


<jsp:include page="header.jsp" />
<style type="text/css">
	.addDishError
	{
		border: 1px solid #FF0000;
	}
	
	.addDishErrorMsg
	{
		padding: 10px 0;
		color: #FF0000;
	}
</style>
<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/newDish.jsp"/>
		<jsp:include page="/blocks/topUsers.jsp"/>
		<jsp:include page="/blocks/top10Dishes.jsp"/>
	</div>
	<div class="col2">
<script type="text/javascript" src="/js/TextboxList.js"></script>
<script type="text/javascript" src="/js/TextboxList.Autocomplete.js"></script>
<script type="text/javascript" src="/js/GrowingInput.js"></script>
<script type="text/javascript" src="/js/topdish.autocomplete.js"></script>
<%
	Restaurant r = null;
	String name = "";
	String description = "";
	String restName = "";
	String tagList = "";
	String restID = "";
	if(request.getParameter("name") != null)
		name = request.getParameter("name");
	if(request.getParameter("description") != null)
		description = request.getParameter("description");
	if(request.getParameter("restaurantName") != null)
		restName = request.getParameter("restaurantName");
	if(request.getParameter("tagList") != null)
		tagList = request.getParameter("tagList");
	if(request.getParameter("restID") != null)
		restID = request.getParameter("restID");
	
	if(restID != null && !restID.equals(""))
	{
		try{
			r = Datastore.get(KeyFactory.createKey(Restaurant.class.getSimpleName(), Long.parseLong(restID)));
		}catch(NumberFormatException e){
			//not a long
		}
	}
	
    BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	String blobUploadURL = blobstoreService.createUploadUrl("/rateDish");
%>
<!-- 
<div class="top_categories">
	*Top Categories: San Francisco | Grilled Bacon | Bacon Cheddar | Chai Bacon | Los Bacon
</div> -->
<div class="rating_header dish_splitter">
	<h1>Rate a <span>dish</span></h1>
</div>
<form action="<%= blobUploadURL %>" autocomplete="off" method="post" id="rateDishForm" enctype="multipart/form-data">
	<div class="rating_header">
		<h2>Location</h2>
		<% if(r != null) { %>
	    	<input type="text" class="grey_input_box grey_input_box_none" name="restaurantName" id="rest_name1" value="<% out.print(r.getName()); %>"></input>
	    	<input type="hidden" id="rest_id1" name="restID" value="<%=restID%>"></input>
		    <div id="rest_ac_info">
			    <div id="rest_ac_address">
			    	<% 
			    		if(r.getAddressLine2() != "")
			    		{
			    			out.print(r.getAddressLine1() + " " + r.getAddressLine2() + " " + r.getCity() + ", " + r.getState());
			    		}
			    		else
			    		{
			    			out.print(r.getAddressLine1() + " " + r.getCity() + ", " + r.getState());
			    		}
			    	%>
			    </div>
			    <div id="rest_ac_dishes">
			    	<% out.print(r.getNumDishes() + " dishes listed"); %>
			    </div>
			    <div id="rest_ac_photos">
			    </div>
		    </div>
	    <%} else { %>
	    	<input type="text" class="grey_input_box grey_input_box_none" name="restaurantName" id="rest_name1" value="<% out.print(restName); %>"></input>
	    	<input type="hidden" id="rest_id1" name="restID"></input>
		    <div id="rest_ac_info">
			    <div id="rest_ac_address"></div>
			    <div id="rest_ac_dishes"></div>
			    <div id="rest_ac_photos"></div>
			    <div id="rest_finder">Can't find what you want?  <a href="restaurantSearch.jsp">Try this.</a></div>
		    </div>
	    <% } %>
	    
	</div>
	<div class="rating_header dish_splitter">
		<h2>Dish Name</h2>
	    <input type="text" class="grey_input_box grey_input_box_none" name="dishName" id="dish_name1" value="<% out.print(name); %>"></input>
	    <input type="hidden" id="dish_id1" name="dishID"></input>
	    <br /><br />
	</div>
	<div class="rating_header">
	    <h2>Would you recommend this dish?</h2>
	    <fieldset class="rating_radios">
	    	<ol>
	        	<li class="like" id="like_radio">
	            	<input name="rating" id="rating-pos1" value="1" type="radio" />
	        		<label for="rating-pos">Yes</label>
	            </li>
	        	<li class="dislike" id="dislike_radio">
	            	<input name="rating" id="rating-neg1" value="-1" type="radio" />
	       			<label for="rating-neg">No</label>
	            </li>
	        </ol>
	    </fieldset>
	    <h2>Dish Details</h2>
		<p>
		<span class="rating_categories">Category:</span>
		<select name="categoryID" id="category_id1">
		<%
			Query query = PMF.get().getPersistenceManager().newQuery(Tag.class);
			List<Tag> categories;
			query.setFilter("type == typeParam");
		    query.declareParameters("int typeParam");
		    query.setOrdering("manualOrder ASC"); //manual order
			categories = (List<Tag>) query.execute(Tag.TYPE_MEALTYPE); //only cuisines
			out.print("<option value=\"\" selected></option>\n");
			for (Tag c : categories) {
				out.print("<option value=\"" + c.getKey().getId() + "\">" + c.getName() + "</option>\n");			
			}
		%>
		</select>
		
		<span class="rating_ingredients">Price:</span>
		<select name="priceID" id="price_id1">
		<%
			List<Tag> prices;
			query.setFilter("type == typeParam");
		    query.declareParameters("int typeParam");
		    query.setOrdering("manualOrder ASC"); //manual order
			prices = (List<Tag>) query.execute(Tag.TYPE_PRICE); //only cuisines
			out.print("<option value=\"\" selected></option>\n");
			for (Tag p : prices) {
				out.print("<option value=\"" + p.getKey().getId() + "\">" + p.getName() + "</option>\n");			
			}
		%>
		</select>
		</p>
		<br/>
		<p><span class="rating_categories">Tags</span> e.g. San Francisco, Mission District, Night Life, Brunch, Cheap Eats.</p>
	    <div class="tag_input tag_red">
	    <%
	    	ArrayList<String> tags = new ArrayList<String>();
	    	List<Key> usersLifestyles = user.getLifestyles();
	    	List<Key> usersAllergens = user.getAllergens();
	    	
	    	if(usersLifestyles != null){
		    	for(Key k : usersLifestyles){
		    		Tag t = Datastore.get(k);
		    		tags.add(t.getName());
		    	}
	    	}
	    	if(usersAllergens != null){
		    	for(Key k: usersAllergens){
		    		Tag t = Datastore.get(k);
					tags.add(t.getName());
		    	}
	    	}
	    	String taglist = StringUtils.join(tags, ", ");
	   	%>
	    	<input type="text" name="tagList" id="tag_list1" value="<%=taglist%>" />
	    </div>
	    <p>Can't find it? <a href="addTag.jsp">Add a Tag</a></p>
	    <br/>
	    <p><span class="rating_description">Description</span> Enter a detailed description.</p>
	    <textarea name="dishDesc" id="description1" rows="3" cols="40"><% out.print(description); %></textarea><br />
	    <h2>Upload a Photo</h2>
	    <input type="file" name="myFile"></input><br /><br />
	    <h2>Additional Food for thought?</h2>
	   	<textarea name="comments" rows="3" cols="40" id="comments_text1" ><% //out.print(comment); %></textarea>
	    <input type="hidden" name="isYelp" id="is_yelp1" value="false"></input>
	    <input type="hidden" name="yelpName" id="yelp_name1" value=""></input>
	    <input type="hidden" name="yelpID" id="yelp_id1" value=""></input>
	    <input type="hidden" name="yelpAddress1" id="yelp_address1a" value=""></input>
	    <input type="hidden" name="yelpAddress2" id="yelp_address2a" value=""></input>
	    <input type="hidden" name="yelpCity" id="yelp_city1" value=""></input>
	    <input type="hidden" name="yelpState" id="yelp_state1" value=""></input>
	    <input type="hidden" name="yelpLatitude" id="yelp_latitude1" value=""></input>
	    <input type="hidden" name="yelpLongitude" id="yelp_longitude1" value=""></input>
	    <input type="hidden" name="yelpPhone" id="yelp_phone1" value=""></input>
	    <input type="hidden" name="yelpURL" id="yelp_url1" value=""></input><br /><br />
		<input type="submit" value="Add Review" id="rateDishSubmit1"></input>
	</div>
</form>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<script type="text/javascript">
	$("#rateDishSubmit1").click(function()
	{
		var firstErr, result;
		var err = false;
		
		//check location
		result = ($("#rest_name1").val()=="") ? doError($("#rest_name1"), "'Location' cannot be blank") : removeError($("#rest_name1"));
		if(!result && !firstErr){
			firstErr = $("#rest_name1");
			//alert("restaurant name error");
		}
		if (!result) err = true;
		
				//check comment
		result = ($("#comments_text1").val()=="") ? doError($("#comments_text1"), "'Comment' cannot be blank") : removeError($("#comments_text1"));
		if(!result && !firstErr){
			firstErr = $("#comments_text1");
			//alert("restaurant name error");
		}
		if (!result) err = true;
		
		//check description
		result = ($("#description1").val()=="") ? doError($("#description1"), "'Description' cannot be blank") : removeError($("#description1"));
		if(!result && !firstErr){
			firstErr = $("#description1");
			//alert("restaurant name error");
		}
		if (!result) err = true;
		
		//check dishname
		result = ($("#dish_name1").val()=="") ? doError($("#dish_name1"), "'Dish Name' cannot be blank") : removeError($("#dish_name1"));
		if(!result && !firstErr){
			firstErr = $("#dish_name1");
			//alert("dish name error");
		}
		if (!result) err = true;
		
		//Check Catagory
		result = ($("#category_id1").val()=="") ? doError($("#category_id1"), "Please select a 'Category' from the drop down") : removeError($("#category_id1"));
		if(!result && !firstErr){
			firstErr = $("#category_id1");
			//alert("category error");
			//console.log($("#category_id1 option:selected").text());
		}
		if (!result) err = true;
		
		//Check Price
		result = ($("#price_id1").val()=="") ? doError($("#price_id1"), "Please select a 'Price' from the drop down") : removeError($("#price_id1"));
		if(!result && !firstErr){
			firstErr = $("#price_id1");
			//alert("price error");
		}
		if (!result) err = true;
		
		//check like / dislike
		result = (!$("#rating-pos1").is(":checked") && !$("#rating-neg1").is(":checked")) ? doError($(".rating_radios"), "You must like or dislike this dish") : removeError($(".rating_radios"));
		if(!result && !firstErr){
			firstErr = $("#rating-pos1");
			//alert("rating error");
		}
		if (!result) err = true;
		
		if(err){
			firstErr.focus();
			return false;
		}else{
			return true;
		}
	});
	
	function doError(obj, msg)
	{
		obj.addClass("addDishError");
		(!obj.next().hasClass('addDishErrorMsg')) ? obj.after("<div class='addDishErrorMsg'>"+msg+"</div>") : "";
		return false;
	}
	
	function removeError(obj)
	{
		obj.removeClass("addDishError");
		(obj.next().hasClass('addDishErrorMsg')) ? obj.next().remove() : "";
		return true;
	}
</script>
<jsp:include page="footer.jsp" />