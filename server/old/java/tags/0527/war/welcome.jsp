<%@page import="com.topdish.comparator.TagNameComparator"%>
<%@ page import="com.topdish.jdo.Tag" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.util.FacebookUtils" %>
<%@ page import="com.topdish.api.util.FacebookConstants" %>
<%@ page import="com.topdish.api.util.UserConstants" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.json.JSONObject" %>

<%
	String name = "";
	String email = "";
	
	if(null != request.getUserPrincipal()){
		email = request.getUserPrincipal().getName();
	}else{
		name = String.valueOf(request.getSession().getAttribute(UserConstants.NICKNAME));
		email = String.valueOf(request.getSession().getAttribute(UserConstants.EMAIL));
	}
%>

<jsp:include page="header.jsp" />
<div class="colleft">
	<p>
	TopDish is a service find and rank the best foods near you. 
	</p>
	<br />
	<p>
	To get started, please fill out your profile information below. 
	</p>
	<br />
	<form id="welcome_form" action="/addUser" method="post">
	<fieldset>
		<label for="name">Name
		<input type="text" name="nickname" value="<%= name %>"/>
		</label>
		<br /><br/>
		<label for="email">Email
		<input type="text" name="email" value="<%= email %>"/>
		</label>
		<br /><br/>
		<div class="left" style="float: left; width: 200px;">
			<h2>Lifestyle</h2>
	<%
			final List<Tag> lifestyles = new ArrayList<Tag>(
					TagUtils.getTagsByType(Tag.TYPE_LIFESTYLE));
			Collections.sort(lifestyles, new TagNameComparator());
	
			for (final Tag t : lifestyles) {%>
				<input type="checkbox" name="allergen[]" value="<%=t.getKey().getId()%>"><%=t.getName()%></input><br /><%
			}%>		
		</div>
			<h2>Allergies</h2>
	<%
			final List<Tag> allergies = new ArrayList<Tag>(
					TagUtils.getTagsByType(Tag.TYPE_ALLERGEN));
			Collections.sort(allergies, new TagNameComparator());
			
			for (final Tag t: allergies) {%>
				<input type="checkbox" name="allergen[]" value="<%=t.getKey().getId()%>"><%=t.getName()%></input><br /><%
			}%>
            <br />
            <input type="checkbox" name="" ><% out.print("  Click here to accept our <a href=\"/terms.jsp\">Terms of Service</a>." ); %></input>
			<br />
		<input type="submit" value="Join">
	</fieldset>
	</form>
    <br />
    <%
	String XX = "";
	String YY = "";
	if(TDUserService.isFacebookUser(request.getSession(true))) {
		XX = "Facebook";
		YY = "Google";
	} else if(TDUserService.isGoogleUser(request)) {
		XX = "Google"; 
		YY = "Facebook";
	} %>
    Already have a <%= XX %> TopDish Account? <a href="pairUsers.jsp">Click here to link your <%= YY %> Account.</a>
</div> <!--  colleft -->
<jsp:include page="footer.jsp"/>