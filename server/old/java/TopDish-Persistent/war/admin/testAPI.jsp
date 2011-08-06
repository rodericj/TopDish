<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.topdish.jdo.Tag" %>
<%@ page import="com.topdish.jdo.TDBetaInvite" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>

<%
	String API_KEY = "09acca14-58ad-4e97-8c08-516841fc6346";
	String blobUploadURL = "/_ah/upload/agh0b3BkaXNoMXIcCxIVX19CbG9iVXBsb2FkU2Vzc2lvbl9fGNgCDA";
%>

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
    
MOBILE INIT:
	<form  action="/api/mobileInit" method="post">
        <input type="submit" value="Submit" />
	</form>

TERMS AND CONDITIONS:
	<form  action="/api/getTerms" method="post">
        <input type="submit" value="Submit" />
	</form>

SET FACEBOOK ID FOR USER:
	<form  action="/admin/setFacebookId.jsp" method="get">
		&nbsp; User ID:	<input type="text" name="userId" id="lat" /> <br />
        &nbsp; Facebook ID:	<input type="text" name="facebookId" id="lng" /> <br />	
        <input type="submit" value="Submit" />
	</form>
    
TEST FACEBOOK OAUTH KEY:
	<form  action="/api/facebookLogin" method="post">
		&nbsp; OAuth Facebook Key:	<input type="text" name="facebookApiKey" id="facebookApiKey"  /> <br />
        <input type="submit" value="Submit" />
	</form>