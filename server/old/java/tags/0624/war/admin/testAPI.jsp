<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.jdo.TDUser" %>

<%
	TDUser user = TDUserService.getUser(request.getSession(true));
	String API_KEY = user.getApiKey();
	out.println("Your API Key is: "+API_KEY + "\n");
	String blobUploadURL = "/_ah/upload/agh0b3BkaXNoMXIcCxIVX19CbG9iVXBsb2FkU2Vzc2lvbl9fGNgCDA";
%>

<br /><br />
GET API KEY FOR EMAIL:
	<form  action="/api/login" method="get">
		&nbsp; email:	<input type="text" name="email" id="email" value="test@example.com" /> <br />
        <input type="submit" value="Submit" />
	</form>

RATE DISH:
	<form  action="/api/rateDish" method="post">
		&nbsp; DISH ID:	<input type="text" name="dishId" id="dishId" /> <br />
        &nbsp; Direction:	<input type="text" name="direction" id="direction" value="-1"/> <br />
        &nbsp; Comment:	<input type="text" name="comment" id="comment" value="generic comment"/> <br />
		&nbsp; API Key:	<input type="text" name="apiKey" id="apiKey" value="<%=API_KEY %>" /> <br />
        <input type="submit" value="Submit" />
	</form>

SEARCH DISH:
	<form  action="/api/dishSearch" method="get">
		&nbsp; lat:	<input type="text" name="lat" id="lat" value="37.7696" /> <br />
        &nbsp; lng:	<input type="text" name="lng" id="lng" value="-122.446"/> <br />	
        &nbsp; distance:	<input type="text" name="distance" id="distance" value="100000"/> <br />
		&nbsp; limit:	<input type="text" name="limit" id="limit" value="10" /> <br />
   		&nbsp; q:	<input type="text" name="q" id="q" value="burger" /> <br />
   		&nbsp; tags (optional):	<input type="text" name="tags" id="tags" value="102001" /> <br />
        <input type="submit" value="Submit" />
	</form>

RECO DISH:
	<form  action="/api/dishRecommend" method="get">
		&nbsp; lat:	<input type="text" name="lat" id="lat" value="37.7696" /> <br />
        &nbsp; lng:	<input type="text" name="lng" id="lng" value="-122.446"/> <br />	
        &nbsp; distance:	<input type="text" name="distance" id="distance" value="100000"/> <br />
		&nbsp; limit:	<input type="text" name="limit" id="limit" value="10" /> <br />
        <input type="submit" value="Submit" />
	</form>
		
SEARCH RESTAURANT:
	<form  action="/api/restaurantSearch" method="get">
		&nbsp; lat:	<input type="text" name="lat" id="lat" value="37.7696" /> <br />
        &nbsp; lng:	<input type="text" name="lng" id="lng" value="-122.446"/> <br />	
        &nbsp; distance:	<input type="text" name="distance" id="distance" value="100000"/> <br />
		&nbsp; limit:	<input type="text" name="limit" id="limit" value="10" /> <br />
   		&nbsp; q:	<input type="text" name="q" id="q" value="burger" /> <br />
        <input type="submit" value="Submit" />
	</form>
    
ADD DISH:
	<form  action="/api/addDish" method="post">
		&nbsp; name:	<input type="text" name="name" id="name" value="foood" /> <br />
        &nbsp; description:	<input type="text" name="description" id="description" value="its yummy foods"/> <br />	
        &nbsp; tags:	<input type="text" name="tags" id="tags" value="Expensive,Dinner,American"/> <br />
        &nbsp; restaurantId:	<input type="text" name="restaurantId" id="restaurantId" value="36"/> <br />
		&nbsp; API Key:	<input type="text" name="apiKey" id="apiKey" value="<%=API_KEY %>" /> <br />
        <input type="submit" value="Submit" />
	</form>

ADD RESTAURANT:
	<form  action="/api/addRestaurant" method="post">
		&nbsp; name:	<input type="text" name="name" id="name" value="Super Cool Restaurant" /> <br />
        &nbsp; address line 1:	<input type="text" name="addressLine1" id="addressLine1" value="793 N Craig Ave"/> <br />	
        &nbsp; address line 2:	<input type="text" name="addressLine2" id="addressLine2" value=" "/> <br />	 
        &nbsp; city:	<input type="text" name="city" id="city" value="Pasadena"/> <br />
        &nbsp; state:	<input type="text" name="state" id="state" value="CA"/> <br />
        &nbsp; neighborhood:	<input type="text" name="neighborhood" id="neighborhood" value=" "/> <br />
        &nbsp; phone:	<input type="text" name="phone" id="phone" value="999-992-2310"/> <br />
        &nbsp; url:	<input type="text" name="url" id="url" value="http://www.yahoo.com"/> <br />
        &nbsp; cuisine:	<input type="text" name="cuisine" id="cuisine" value="Mexican"/> <br />
		&nbsp; API Key:	<input type="text" name="apiKey" id="apiKey" value="<%=API_KEY %>" /> <br />
        <input type="submit" value="Submit" />
	</form>

UPLOAD PHOTO:
	<form  action="/api/addPhoto" method="post" enctype="multipart/form-data">
    	&nbsp; Photo:<input type="file" name="photo"></input>
		&nbsp; Dish ID:	<input type="text" name="dishId" id="dishId" value="37" /> <br />
        &nbsp; RestaurantId:	<input type="text" name="restaurantId" id="restaurantId" /> <br />
		&nbsp; API Key:	<input type="text" name="apiKey" id="apiKey" value="<%=API_KEY %>" /> <br />
        <input type="submit" value="Submit" />
	</form>
    
FLAG DISH:
	<form  action="/api/flagDish" method="post">
		&nbsp; dish id:	<input type="text" name="dishId" id="dishId" value="318" /> <br />
        &nbsp; type:	<br />
        &nbsp; &nbsp; <input type="radio" name="type" id="type" value="0"> Inaccurate <br />
        &nbsp; &nbsp; <input type="radio" name="type" id="type" value="1"> Spam <br />
        &nbsp; &nbsp; <input type="radio" name="type" id="type" value="2"> Inappropriate <br />
		&nbsp; API Key:	<input type="text" name="apiKey" id="apiKey" value="<%=API_KEY %>" /> <br />
        <input type="submit" value="Submit" />
	</form>

FLAG RESTAURANT:
	<form  action="/api/flagRestaurant" method="post">
		&nbsp; restaurant id:	<input type="text" name="restaurantId" id="restaurantId" value="19" /> <br />
        &nbsp; type:	<br />
        &nbsp; &nbsp; <input type="radio" name="type" id="type" value="0"> Inaccurate <br />
        &nbsp; &nbsp; <input type="radio" name="type" id="type" value="1"> Spam <br />
        &nbsp; &nbsp; <input type="radio" name="type" id="type" value="2"> Inappropriate <br />
		&nbsp; API Key:	<input type="text" name="apiKey" id="apiKey" value="<%=API_KEY %>" /> <br />
        <input type="submit" value="Submit" />
	</form>
    
DISHES BY RESTAURANT:
	<form action="/api/restaurantDetail" method="get">
		&nbsp; rest id 1: <input type="text" name="id[]" /><br />
		&nbsp; rest id 2: <input type="text" name="id[]" /><br />
		&nbsp; rest id 3: <input type="text" name="id[]" /><br />
		<input type="submit" value="Submit" />
	</form>
    
REMOVE REVIEW FROM DISH:
NOTE: This is not a test to be used litely, it WILL delete a review.
	<form action="/api/deleteReview" method="post">
      	&nbsp; Dish Id:	<input type="text" name="dishId" id="dishId"  /> <br />
  		&nbsp; Review Id:	<input type="text" name="reviewId" id="reviewId"  /> <br />
		<input type="submit" value="Submit" />
	</form>
    
MOBILE INIT:
	<form  action="/api/mobileInit" method="post">
        <input type="submit" value="Submit" />
	</form>

TERMS AND CONDITIONS:
	<form  action="/api/getTerms" method="post">
        <input type="submit" value="Submit" />
	</form>
    
TEST FACEBOOK LOGIN: <br />
Note: This requires you give permissions to Topdish for your facebook oauth key to work. This is because your email address MUST be visible to TopDish.
	<form  action="/api/facebookLogin" method="post">
		&nbsp; OAuth Facebook Key:	<input type="text" name="facebookApiKey" id="facebookApiKey"  /> <br />
        <input type="submit" value="Submit" />
	</form>
    
TEST FACEBOOK PAIRING: <br />
	<form  action="/api/pairFacebook" method="post">
		&nbsp; Facebook id:	<input type="text" name="facebookId" id="facebookId"  /> <br />
		&nbsp; TDUser Id:	<input type="text" name="TDUserId" id="TDUserId"  /> <br />
        <input type="submit" value="Submit" />
	</form>
    
TEST API GOOGLE AUTH: <br />
<form  action="/api/googleAuth" method="post">
	&nbsp; Redirect To: <input type="text" name="redirect" id="redirect" value="td://" /> <br />
    <input type="submit" value="Submit" />
</form>
    
TEST GEO LOOKUP: <br />
Note: Just submit, this servlet grabs the IP Address of the requester
	<form  action="/api/locateUser" method="post">
        <input type="submit" value="Submit" />
	</form>

CLEAR MEMCACHE: <br />
	<form action="/clearMemcache" method="post">
		<input type="submit" value="Do it now!" />
	</form>
	
TEST USER FEEDBACK <br />
    <form action="/api/sendUserFeedback" method="post">
        &nbsp; TD User ID: <input type="text" name="TDUserId" id="TDUserId" value="<%= user.getKey().getId() %>" /> <br />
        &nbsp; User Name : <input type="text" name="name" id="name" value="<%= user.getNickname() %>"/> <br />
        &nbsp; Email : <input type="text" name="email" id="email" value="<%= user.getEmail() %>"/> <br />
        &nbsp; TD Platform: <input type="text" name="platform" id="platform" value="TestAPI.jsp"/> <br />
        &nbsp; Feedback Message: <input type="text" name="feedback" id="feedback" value="Coolest Feedback form EVER"/> <br />
		&nbsp; API Key:	<input type="text" name="apiKey" id="apiKey" value="<%=API_KEY %>" /> <br />
        <input type="submit" value="Send Feedback" />
    </form>