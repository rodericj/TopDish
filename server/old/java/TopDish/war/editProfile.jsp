<jsp:include page="header.jsp" />
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.jdo.TDUser" %>
<%@ page import="com.topdish.exception.UserNotFoundException" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="com.topdish.jdo.Tag" %>
<%@ page import="com.topdish.jdo.Photo" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.ArrayList" %>

<%
	TDUser user = null;
	try{
		user = TDUserService.getUser(session); 
	}catch(UserNotLoggedInException e){
		response.sendRedirect("index.jsp"); 
	}catch(UserNotFoundException e){
		response.sendRedirect("index.jsp");
	}
%>
<div class="colleft">
	<div class="col1">
		<jsp:include page="/blocks/newDish.jsp"/>
		<jsp:include page="/blocks/topUsers.jsp"/>
		<jsp:include page="/blocks/top10Dishes.jsp"/>
	</div>
	<div class="col2">

<div class="rating_header">
<form action="updateUser" method="post">
	<div class="rating_header dish_splitter">
		<h1>Edit your <span>profile</span></h1>
	</div>
	<br>
	<h2>Nickname</h2>
	<input type="text" class="grey_input_box grey_input_box_none" name="nickname" value="<% out.print(user.getNickname()); %>"></input><br><br>
	<h2>Email</h2>
	<input type="text" class="grey_input_box grey_input_box_none" name="email" value="<% out.print(user.getEmail()); %>"></input><br /><br />
	<h2>Foodie Bio</h2>
	<textarea class="input_textarea" name="bio" rows="3" cols="40"><%
		String bio = user.getBio();
	    if (bio != null && !bio.isEmpty())
			out.print(user.getBio());
	%></textarea>
	
	<div class="clearfix subcolumn" style="margin-bottom: 20px">
	  <div class="left" style="float: left; width: 200px;">	
		<h2>Lifestyle</h2>
<%
	final Set<Tag> userLifestyles = Datastore.get(user.getLifestyles());
	final Set<Tag> userAllergens = Datastore.get(user.getAllergens());
	
	final Set<Tag> lifestyles = TagUtils.getTagsByType(Tag.TYPE_LIFESTYLE);
	final Set<Tag> allergens = TagUtils.getTagsByType(Tag.TYPE_ALLERGEN);
	
	for (Tag t : lifestyles) {
		out.print("<input type=\"checkbox\"");
		out.print(" name=\"lifestyle[]\" ");
		out.print(" value=\"" + t.getKey().getId() + "\"");
		
		//Reflecting the state of the data store
		if (userLifestyles.contains(t)){
			out.print(" checked");
		}
		out.print("> ");
		out.print(t.getName());	
		out.print("</input><br>");	
	}
%>
	  </div>
	  <div>
		<h2>Allergens</h2>
<%	
	for (Tag t: allergens) {
		out.print("<input type=\"checkbox\"");
		out.print(" name=\"allergen[]\" ");
		out.print(" value=\"" + t.getKey().getId() + "\"");
		
		if(userAllergens.contains(t)){
			out.print(" checked");
		}
		
		out.print("> ");
		out.print(t.getName());
		out.print("</input><br>");
	}
%>	
	  </div>
	</div>
	
	<input type="hidden" name="userKey" value="<% out.print(user.getKey().getId()); %>"></input>
	<input type="submit" value="Update Profile"></input>
</form>
	
<br />
<h2>Your photo <span><a href="photoUpload.jsp?userID=<%=user.getKey().getId()%>">Change your photo!</a></span></h2>
<div class="user_photo">
<%		if(user.getPhoto() != null){
			Photo userPhoto = Datastore.get(user.getPhoto());
			final String url = userPhoto.getURL(250);
%>
		<img class="dish_image_gold" src="<%=url%>"></img>
		<br />
		<div class="photo_controls">
		<form action="/deletePhoto" method="post">
			<input type="hidden" name="photoID" value="<%=user.getPhoto().getId()%>" />
			<input type="hidden" name="userID" value="<%=user.getKey().getId()%>" />
			<input type="submit" value="Delete Photo" />
		</form>
		</div>
<%		}else{ %>
		<img class="dish_image_gold" src="style/no_user_img.jpg"></img>
<%		} %>
<br /><br />
</div>
</div>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />