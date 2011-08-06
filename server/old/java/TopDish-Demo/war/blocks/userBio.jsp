<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.exception.UserNotFoundException" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>

<%
	PersistenceManager pm = PMF.get().getPersistenceManager();
	TDUser user = null;
	//first check if looking for a user via GET var
	String userIDs = request.getParameter("userID");
	long userID = 0;
	boolean loggedIn = false;
	List<Key> usersLifestyles = new ArrayList<Key>();
	
	try{
		userID = Long.parseLong(userIDs);
		user = pm.getObjectById(TDUser.class, userID);
		usersLifestyles = user.getLifestyles();
		if(TDUserService.getUserLoggedIn() && TDUserService.getUser(pm).getKey().getId() == userID){
			//looking at own profile
			loggedIn = true;
		}
	}catch(NumberFormatException e){
		//user id not valid long
	}catch(JDOObjectNotFoundException e){
		//user object not found
	}
	if(user != null){
%>
			<div class="rmenu_cont">
				<div class="user_photo_small">
			<%		if(user.getPhoto() != null){ 
						Photo userPhoto = PMF.get().getPersistenceManager().getObjectById(Photo.class, user.getPhoto());
			%>
						<img class="user_profile_box" src="<%=ImagesServiceFactory.getImagesService().getServingUrl(userPhoto.getBlobKey(), 100, true)%>"></img>
			<%		}else{ %>
						<img class="user_profile_box" src="style/no_user_img.jpg"></img>
			<%		} %>	
				</div>
				<div class="user_description user_profile_box">
					<div class="user_description_text">
						<h1><% out.print(user.getNickname()); %></h1>
						<p><% String bio = user.getBio();
							  if (bio != null && !bio.isEmpty())
							      out.print(bio);
						   %>
							<% if(loggedIn){ %>
								<a href="editProfile.jsp">update profile</a>
							<% } %>
						</p>
					</div>
					<span style="background-image: img/shadow.png"></span>
				</div>				
				
				
				<!-- 
				<div class="user_status">A little about me: I love long walks on the beach and carnitas tacos.</div>
				<div class="user_badges"></div>
				<div class="user_details">
					<h2>Personal Favorites</h2>
					<div class="dish_favorites">
						<h3>Dishes</h3>
					</div>
					<div class="ingredient_favorites">
						<h3>Ingredients</h3>
					</div>
					<div class="cuisine_favorites">
						<h3>Cuisines</h3>
					</div>
					<div class="cateogry_favorites">
						<h3>Categories</h3>
					</div>
				</div>
				 -->

				<div class="user_details">
					<div class="user_profile_splitter">
						<h1>I've Eaten <%= user.getNumReviews() %> Dish<%
							if(user.getNumReviews() != 1)
								out.print("es");
						%></h1>
						<h4 class="like"><%= user.getNumPosReviews() %> Recommended Dishes</h4>
						<h4 class="dislike"><%= user.getNumNegReviews() %> Not Recommended</h4>
					</div>
					
					<div class="rating_header user_profile_splitter">
						<h1>Lifestyle</h1>
						<!-- <div class="spicy_meter"></div> -->
						<div class="diet_prefs like">
							<%
							ArrayList<String> tags = new ArrayList<String>();
							
							if(usersLifestyles != null){
								for(Key k : usersLifestyles){
									Tag t = pm.getObjectById(Tag.class, k);
									tags.add(t.getName());
								}
							}
							
							out.print(StringUtils.join(tags, ", "));
							
						    %>
						</div>
					</div>
					<!-- 
					<div class="allergen_prefs">
						<h3>Allergies</h3>
						<p>Tree Nuts, Milk</p>
					</div>
					 -->
				</div>
			</div>
<%
	}	
%>