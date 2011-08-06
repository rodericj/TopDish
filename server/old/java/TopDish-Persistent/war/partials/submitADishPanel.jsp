<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%

BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
String blobUploadURL = blobstoreService.createUploadUrl("/rateDish");
PersistenceManager pm = PMF.get().getPersistenceManager();
%>

<script type="text/javascript" src="/js/TextboxList.js"></script>
<script type="text/javascript" src="/js/TextboxList.Autocomplete.js"></script>
<script type="text/javascript" src="/js/GrowingInput.js"></script>

<div id="submitadish_main_panel"  class="clearfix" style="display:none;">
	<span class="submitadish_close">X</span>
	<form action="<%= blobUploadURL %>" method="post" id="rateDishForm" enctype="multipart/form-data">
		<ul id="twopanel" class="clearfix">
			<li id="one">
				<h1>Submit a dish to TopDish!</h1>
				<input type="text" class="text" name="restaurantName" id="rest_name" placeholder="Find the Restaurant" value="Find the Restaurant"/>
				<br/><h6><a href="/restaurantSearch.jsp">Add a new restaurant</a></h6>
				<input type="text" class="text" name="dishName" id="dish_name" placeholder="Enter the dish name" />

				<br/>
            	<!-- <input type="text" class="text" name="tagList" id="submitdish_tag_list"/> -->
				
				<div id="categoryDown" class="fakeDropDown">
					<span class="fakeDropDownLabel">Dish Category</span>
					<div class="contextBox">
						<ul>
							<%
								Query query = pm.newQuery(Tag.class);
								List<Tag> categories;
								query.setFilter("type == typeParam");
							    query.declareParameters("int typeParam");
							    query.setOrdering("manualOrder ASC"); //manual order
								categories = (List<Tag>) query.execute(Tag.TYPE_MEALTYPE); //only cuisines
								for (Tag c : categories) {
									out.print("<li rel=\"" + c.getKey().getId() + "\">" + c.getName() + "</li>");			
								}
							%>
						</ul>
					</div>
				</div>
				
				<div id="priceDown" class="fakeDropDown">
					<span class="fakeDropDownLabel">Select a price</span>
					<div class="contextBox">
						<ul>
							<%
								List<Tag> prices;
								query.setFilter("type == typeParam");
							    query.declareParameters("int typeParam");
							    query.setOrdering("manualOrder ASC"); //manual order
								prices = (List<Tag>) query.execute(Tag.TYPE_PRICE); //only prices
								for (Tag p : prices) {
									out.print("<li rel=\"" + p.getKey().getId() + "\">" + p.getName() + "</li>");			
								}
							%>
						</ul>
					</div>
				</div>
			</li>
			<li id="two">
				<h2 class="textLabel">Description as seen on the menu</h2><h3>240</h3>
				<textarea id="describe" name="dishDesc" maxlength="240" class="textbox" placeholder="Please provide a detailed description of the dish as seen on the menu. Try and include as many ingredients as possible."></textarea>
				<h2 class="textLabel">Additional Food for thought?</h2></h2><h3>240</h3>
				<textarea id="comments" name="comments" maxlength="240" class="textbox" placeholder="What did you think of the dish? Please be as descriptive as possible to help future users"></textarea>
				<h2 class="textLabel" style="width: 310px;">Would you recommend this dish?</h2><br>
				<div id="chooseRating" style="display: block;">
					<img src="/img/panel/submitadish_no.png" alt="Yes" id="ratingYes" class="fakeRadio" /><h2 class="left fakeRadioLabel">Yes</h2>
					<img src="/img/panel/submitadish_no.png" alt="No" id="ratingNo" class="fakeRadio" /><h2 class="left fakeRadioLabel">No</h2>
				</div>
				<img src="/img/panel/submitadish_photo.png" id="uploadPhoto" class="browse" alt="upload a photo" />
				<div id="fileCover">Take any photos?</div>
				<input type="file" name="myFile" id="dishPhoto" />
				
				<input type="image" src="/img/panel/submitadish_submit.png" name="submit" id="submit" />
			</li>
		</ul>
		
		<input type="hidden" id="category_ID" name="categoryID" value="" />
		<input type="hidden" id="price_ID" name="priceID" value="" />
		<input type="hidden" id="rest_id" name="restID" value="" />
		<input type="hidden" value="" name="rating" id="dishRating" />
		<input type="hidden" name="restaurantID" id="rest_id" value=""></input>
	    <input type="hidden" name="isYelp" id="is_yelp" value="false"></input>
	    <input type="hidden" name="yelpName" id="yelp_name" value=""></input>
	    <input type="hidden" name="yelpID" id="yelp_id" value=""></input>
	    <input type="hidden" name="yelpAddress1" id="yelp_address1" value=""></input>
	    <input type="hidden" name="yelpAddress2" id="yelp_address2" value=""></input>
	    <input type="hidden" name="yelpCity" id="yelp_city" value=""></input>
	    <input type="hidden" name="yelpState" id="yelp_state" value=""></input>
	    <input type="hidden" name="yelpLatitude" id="yelp_latitude" value=""></input>
	    <input type="hidden" name="yelpLongitude" id="yelp_longitude" value=""></input>
	    <input type="hidden" name="yelpPhone" id="yelp_phone" value=""></input>
	    <input type="hidden" name="yelpURL" id="yelp_url" value=""></input>
	</form>
</div>