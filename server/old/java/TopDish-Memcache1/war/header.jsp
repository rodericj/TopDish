<%@ page import="java.util.List" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.jdo.TDUser" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.search.AbstractSearch" %>
<%@ page import="javax.jdo.Query" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<% 
	UserService userService = UserServiceFactory.getUserService(); 
	String thisURL = request.getRequestURI();
	if(request.getQueryString() != null)
		thisURL += "?" + request.getQueryString();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!-- html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" xmlns:fb="http://www.facebook.com/2008/fbml" -->
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
    <c:set var="urlStr" value="<%=thisURL%>"/>
    <c:if test="${fn:contains(urlStr,'dishDetail') eq true}">
    	<% 
    	long dishID = Long.parseLong(request.getParameter("dishID"));
		final Dish d = PMF.get().getPersistenceManager().getObjectById(Dish.class, dishID);
		%>
		<meta property="og:title" content="<%=d.getName()%> from <%=d.getRestaurantName()%>"/>
		<meta property="og:type" content="article"/>
		<meta property="og:site_name" content="TopDish"/>
    </c:if>
    <link href="style/topdish-global.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="style/topdish-listing.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="style/topdish-right.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="style/topdish-panel.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="style/reset-min.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="style/smoothness/jquery-ui-1.8.1.custom.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="style/jquery.ac.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="style/jquery.ui.stars.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="js/galleryview-2.1.1/galleryview.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="style/TextboxList.css" media="screen" rel="stylesheet" type="text/css" />
    <link href="style/TextboxList.Autocomplete.css" media="screen" rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true"></script>
    
    
	<script type="text/javascript" src="js/jquery-1.4.2.min.js"> </script>
	<script type="text/javascript" src="js/jquery-ui-1.8.1.custom.min.js"></script>
	<script type="text/javascript" src="js/jquery.autocomplete.jorn.min.js"></script>
	<script type="text/javascript" src="js/jquery.bgiframe.min.js"></script>
	<script type="text/javascript" src="js/jquery.dimensions.min.js"></script>
	<script type="text/javascript" src="js/jquery.cookie.js"></script>
    <script type="text/javascript" src="js/jquery.corner.js"></script>
    <script type="text/javascript" src="js/jquery.ui.stars.js"></script>
    <script type="text/javascript" src="js/galleryview-2.1.1/jquery.easing.1.3.js"></script>
    <script type="text/javascript" src="js/galleryview-2.1.1/jquery.galleryview-2.1.1-pack.js"></script>
    <script type="text/javascript" src="js/galleryview-2.1.1/jquery.timers-1.2.js"></script>
    
    <script type="text/javascript" src="js/topdish.custom.js"></script>
    <script type="text/javascript" src="js/topdish.panel.js"></script>
    <script type="text/javascript" src="js/topdish.panelautocomplete.js"></script>
	<script type="text/javascript" src="js/topdish.dialog.js"></script>
	<script type="text/javascript" src="http://www.geoplugin.net/javascript.gp"></script>
   	<script type="text/javascript" src="js/topdish.locationfinder.js"></script>
	<!-- Get Satisfacation Code -->
	<script type="text/javascript" charset="utf-8">
	var is_ssl = ("https:" == document.location.protocol);
	var asset_host = is_ssl ? "https://s3.amazonaws.com/getsatisfaction.com/" : "http://s3.amazonaws.com/getsatisfaction.com/";
	document.write(unescape("%3Cscript src='" + asset_host + "javascripts/feedback-v2.js' type='text/javascript'%3E%3C/script%3E"));
	</script>
	<script type="text/javascript" charset="utf-8">
	var feedback_widget_options = {};
	
	feedback_widget_options.display = "overlay";  
	feedback_widget_options.company = "topdish";
	feedback_widget_options.placement = "right";
	feedback_widget_options.color = "#336699";
	feedback_widget_options.style = "problem";
	var feedback_widget = new GSFN.feedback_widget(feedback_widget_options);
	</script>
	<!-- End Get Satisfacation Code -->
    
    <!-- Begin Google Analytics Code -->
    <script type="text/javascript">
	var _gaq = _gaq || [];
	_gaq.push(['_setAccount', 'UA-19265500-1']);
	_gaq.push(['_trackPageview']);
	
	(function() {
		var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	})();
	
	//function facebook_onlogin(){
	  //FB.Connect.ifUserConnected("SomeServletOrStrutsActionOrJsp?back="+window.location,null);
	//}
	</script>
    <!-- End Google Analytics Code -->

	<title>Top Dish</title> 
</head>
<%
	String token = "";
	if(request.getParameter("token") != null){
		token = request.getParameter("token");
	}
%>
<body>
	<jsp:include page="welcome.jsp"></jsp:include>
    <div class="mask">
    	<div class="majoras">
        <div class="header">
            <div class="header_top">
                <div id="header_logos">
           	    	<a href="index.jsp"><img src="img/header/topdish_logo.png" width="170" height="49" alt="Top Dish!" /></a>
                    <div>Feed your craving</div>
                    <!-- div><fb:login-button onlogin="facebook_onlogin();"></fb:login-button >
                    <script type="text/javascript">
						FB.init("3e4f5a3a412647c0876251281a184703", "index.jsp");
					</script>
                    </div -->
                </div>
                <div class="user">
                    <!-- User information: name, logged in status, etc. -->
                    <jsp:include page="userControls.jsp">
                    	<jsp:param name="token" value="<%=token%>"/>
                    </jsp:include>
                </div>
            </div>
          <div id="header_bottom">
            <div id="header_search_container">
                    <div id="header_search_top_container">
                        <div id="header_search_description">
                        	<span id="header_search_description_big">Dish Search</span>
                            <span id="header_search_description_small">(i.e. dish name, cuisine, location)</span>
                        </div>
                        <div id="header_quick_links">
                            <a href="http://www.facebook.com/pages/TopDish/157065227639134"><img src="img/header/mini_like_facebook.jpg" alt="Facebook" width="16" height="16" /></a>
                            <a href="http://twitter.com/topdishinc"><img src="img/header/mini_like_twitter.jpg" alt="Twitter" width="16" height="16" /></a>
                            <a href="#"><img src="img/header/mini_like_yelp.jpg" alt="Yelp" width="16" height="16" /> </a>
                            <a href="#"><img src="img/header/mini_like_topdish.jpg" alt="Topdish" width="16" height="16" /></a>
                        </div>
                    </div>
                    <div id="header_search_bar_container">
                        <div class="search">
                            <form action="search.jsp" method="post">
                           	  <fieldset class="main_search">
                              <%
							  String toShow="",callType="";
                              try{
							  toShow = request.getParameter("query");
							  if(null == toShow || toShow.equals(" ") || toShow.equalsIgnoreCase("null")) {
							  	toShow = "";
							  }
							   callType = request.getParameter("callType");
							  if(null == callType || callType.equals(" ") || callType.equalsIgnoreCase("null")) {
								  callType = "";
							  }
                              }
                              catch(Exception e)
                              {
                            	 // toShow="";
                            	  //callType="search";
                              }
							  %>
                               	  <input class="searchbox searchbox_up" id="searchId" name="q" type="text" value='<%=toShow%>' onchange="keepSearchWord"/>
                               	  
                               	  <input class="locationbox locationbox_up" name="loc" id="loc" type="text" value="Acquiring location..." />
                               	  <input class="searchbox_submit" type="submit" value=" " id="submitId"/>  
                               	  <input type="hidden" name="hiddenSearchWord" id="hiddenSearchWordId" value="<%=toShow%>"/>
                               	  <input type="hidden" name="callType" id="callTypeId" value="<%=callType%>"/>
                               	  <input type="hidden" name="locHidden" id="locHidden" value=""/>
                                </fieldset>
                            </form>
                        </div>
                        <div id="location_options" class="location_bar_options"></div>
                        
                        <div class="rate_a_dish">
                        	<a href="rateDish.jsp" id="submit_panel">
                        		<img src="img/header/rate_dish_button.png" width="132" height="43" />
                        	</a>
                        </div>
                        
                        <div id="header_search_bar_quicklinks">
                            <ul>
                                <li><a href="index.jsp">Top Dishes</a></li>
                                <li><a href="addTag.jsp">Add Tag</a></li>
                                <li>
								<% 
								if(TDUserService.getUserLoggedIn())
								{
									%><a href="<%=userService.createLogoutURL("../splash.jsp")%>">Log Out</a><%
								}
								%></li>
                            </ul>
                        </div>
                    </div>
            </div>
          </div>
          <jsp:include page="partials/submitADishPanel.jsp"></jsp:include>
        </div>
        <div class="the_main_divide">
        	<div class="main_divide_content">
            </div>
        </div>
		<div class="main_wrapper">
       	  
       	<%       		
       		String category = request.getParameter("categoryID");
       		String cuisine = request.getParameter("cuisineID");
       		String price = request.getParameter("priceID");
       		String lifestyle = request.getParameter("lifestyleID");
       		String distanceS = request.getParameter("distance");
       		
       		long priceID = 0;
       		long categoryID = 0;
       		long lifestyleID = 0;
       		long cuisineID = 0;
       		
       		if(cuisine != null && !cuisine.equals("")){
       			cuisineID = Long.parseLong(cuisine);
       		}
       		if(price != null && !price.equals("")){
       			priceID = Integer.parseInt(price);
       		}
       		
       		if(category != null && !category.equals("")){
       			categoryID = Integer.parseInt(category);
       		}
       		
       		if(lifestyle != null && !lifestyle.equals("")){
       			lifestyleID = Integer.parseInt(lifestyle);
       		}
       	%>
       	  <div id="filter_list">
       	  	<ul>
       	  	   <li class="hover closed">
       	  			<div class="filterDiv">
       	  				Cuisine
       	  			</div>
       	  			<ul>
       	  			<%
						Query query = PMF.get().getPersistenceManager().newQuery(Tag.class);
       	  				//print all cuisines
       	  				query = PMF.get().getPersistenceManager().newQuery(Tag.class);
						List<Tag> cuisines;
						query.setFilter("type == typeParam");
					    query.declareParameters("int typeParam");
					    query.setOrdering("name ASC"); //alpha order
					    cuisines = (List<Tag>) query.execute(Tag.TYPE_CUISINE);
						for (Tag c : cuisines) 
						{
							out.print("<li class=\"cuisineFilter");
							if(cuisineID == c.getKey().getId())
								out.print(" selected");
							out.print("\" rel=\"" + c.getKey().getId() + "\"");
							out.print(">" + c.getName() + "</li>");	
						}
       	  			
       	  			%>
       	  			</ul>
       	  		</li>
       	  		<li class="closed" >
       	  			<div class="filterDiv">
       	  				Category 
       	  			</div>
       	  			<ul >
       	  				<%
						//print all prices
						List<Tag> categories;
						query.setFilter("type == typeParam");
					    query.declareParameters("int typeParam");
					    query.setOrdering("manualOrder ASC"); //manual order
					    categories = (List<Tag>) query.execute(Tag.TYPE_MEALTYPE);
						for (Tag c : categories) 
						{
							out.print("<li class=\"categoryFilter");
							if(categoryID == c.getKey().getId())
								out.print(" selected");
							out.print("\" rel=\"" + c.getKey().getId() + "\"");
							out.print(">" + c.getName() + "</li>");	
						}
					%>
       	  			</ul>
       	  			
       	  		</li>
       	  		<li class="hover closed" >
       	  			<div class="filterDiv">
       	  				Lifestyle
       	  			</div>
       	  			<ul >
       	  				<%
						//print all prices
						query = PMF.get().getPersistenceManager().newQuery(Tag.class);
						List<Tag> lifestyles;
						query.setFilter("type == typeParam");
					    query.declareParameters("int typeParam");
					    query.setOrdering("name ASC"); //alpha order
					    lifestyles = (List<Tag>) query.execute(Tag.TYPE_LIFESTYLE);
						for (Tag l : lifestyles) 
						{
							out.print("<li class=\"lifestyleFilter");
							if(lifestyleID == l.getKey().getId())
								out.print(" selected");
							out.print("\" rel=\"" + l.getKey().getId() + "\"");
							out.print(">" + l.getName() + "</li>");	
						}
					%>
       	  			</ul>
       	  			
       	  		</li>
       	  		<li class="hover closed" >
       	  			<div class="filterDiv">
       	  				Distance
       	  			</div>
       	  			<ul >
       	  			<%
       	  		 distanceS = request.getParameter("distance");
       	  			String oneselected="",fivesel="",tensel="",twentysel="";
       	  			if(null!=distanceS)
       	  			{
	       	  			if(distanceS.equals("1"))
	       	  			{
	       	  				oneselected="selected";
	       	  			}
	       	  			else if(distanceS.equals("5"))
		   	  			{
	       	  				fivesel="selected";
		   	  			}
	       	  			else if(distanceS.equals("10"))
				  			{
			       	  		tensel="selected";
				  			}
	       	  			else if(distanceS.equals("20"))
				  			{
	       	  					twentysel="selected";
				  			}
       	  			}
       	  				%>
       	  				<li class="distanceFilter <%=oneselected %>" rel="1">&lt; 1 mi.</li>
       	  				<li class="distanceFilter <%=fivesel %>" rel="5">&lt; 5 mi.</li>
       	  				<li class="distanceFilter <%=tensel %>" rel="10">&lt; 10 mi.</li>
       	  				<li class="distanceFilter <%=twentysel %>" rel="20">&lt; 20 mi.</li>
       	  			</ul>
       	  			
       	  		</li>
       	  		<li class="hover closed last" >
       	  			<div class="filterDiv">
       	  				Price
       	  			</div>
       	  			<ul >
					<%
						//print all prices
						query = PMF.get().getPersistenceManager().newQuery(Tag.class);
						List<Tag> prices;
						query.setFilter("type == typeParam");
					    query.declareParameters("int typeParam");
					    query.setOrdering("manualOrder ASC"); //manual order
						prices = (List<Tag>) query.execute(Tag.TYPE_PRICE);
						for (Tag p : prices) 
						{
							out.print("<li class=\"priceFilter");
							if(priceID == p.getKey().getId())
								out.print(" selected");
							out.print("\" rel=\"" + p.getKey().getId() + "\"");
							out.print(">" + p.getName() + "</li>");			
						}
					%>
       	  			</ul>
       	  		</li>
       	  	</ul>
       	  </div>
          
          <div id="fork"></div>
		  <div class="main_top_c">
            <div class="main_tl_c"></div>
                <div class="main_tr_c"></div>
          </div>
          <div class="main_container">