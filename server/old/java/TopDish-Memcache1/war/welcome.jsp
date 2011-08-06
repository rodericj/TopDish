<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.topdish.jdo.Tag" %>
<%@ page import="com.topdish.jdo.TDBetaInvite" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
	//String email = request.getUserPrincipal().getName(); 
	//UserService userService = UserServiceFactory.getUserService();
	//String thisURL = request.getRequestURI();
	//if(request.getQueryString() != null){
	//	thisURL += "?" + request.getQueryString();
	//}
	String token = request.getParameter("token");
	//User user = userService.getCurrentUser();
%>
<div id="welcome_dialog" title="Welcome to TopDish!" style="display:none;">
	<p>
	TopDish is a new kind of review site.  Our goal is to find and rank the best <em>foods</em> near you. 
	It doesn't matter to us if the dish is served from a moving truck or at a 5 star restaurant, if its
	great, we want to know about it!
	</p>
	<br />
	<p>
	To get started, please fill out your profile information below. 
	</p>
	
	<br />
	<form id="welcome_form" action="/addUser" method="post">
	<fieldset>
		<label for="name">Name</label>
		<input type="text" name="nickname" id="name" class="text ui-widget-content ui-corner-all" />
		<br /><br/>
		<label for="email">Email</label>
		<input type="text" name="email" id="email" class="text ui-widget-content ui-corner-all" />
		<br /><br/>
		<div class="left" style="float: left; width: 200px;">
			<h2>Lifestyle</h2>
	<%
			List<Tag> allLifestyles = new ArrayList<Tag>();
			Query query = PMF.get().getPersistenceManager().newQuery(Tag.class);
			query.setFilter("type == typeParam");
			query.declareParameters("int typeParam");
			query.setOrdering("name ASC"); //alpha order
			allLifestyles = (List<Tag>) query.execute(Tag.TYPE_LIFESTYLE);
	
			for (Tag t : allLifestyles) {
				out.print("<input type=\"checkbox\"");
				out.print(" name=\"lifestyle[]\" ");
				out.print(" value=\"" + t.getKey().getId() + "\"");
				out.print("> ");
				out.print(t.getName());	
				out.print("</input><br>");
			}
	%>		
		</div>
			<h2>Allergens</h2>
	<%
			List<Tag> allAllergens = new ArrayList<Tag>();
			
			query = PMF.get().getPersistenceManager().newQuery(Tag.class);
			query.setFilter("type == typeParam");
			query.declareParameters("int typeParam");
			query.setOrdering("name ASC");
			allAllergens = (List<Tag>) query.execute(Tag.TYPE_ALLERGEN);
			
			for (Tag t: allAllergens) {
				out.print("<input type=\"checkbox\"");
				out.print(" name=\"allergen[]\" ");
				out.print(" value=\"" + t.getKey().getId() + "\"");
				out.print("> ");
				out.print(t.getName());
				out.print("</input><br>");
			}		
	%>		
		<input type="hidden" name="token" value="<%= token %>" />
		<input type="hidden" name="redirect" value="index.jsp" />
	</fieldset>
	</form>
</div>
<div id="welcome_choose_path" style="display: none">
	Would you like to personalize your profile, or start using TopDish now?
</div>
