<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="com.topdish.util.PMF" %>

<jsp:include page="header.jsp" />
<%
try {
		TDUserService.getUser(PMF.get().getPersistenceManager());
	} catch(UserNotLoggedInException e) {
		 response.sendRedirect("index.jsp");
	}
%>
<div class="colleft">
		<div class="about">
			<div id="about-hero-img"></div>
			<h1 class="about-header">Our Mission</h1>
			<ul class="about-line-item">
				<li>1. Help foodies find the right dish at the right time</li>
				<li>2. Give restaurateurs the tools and data to grow and enhance their business</li>
				<li>3. Create a platform to enable a dialogue between foodies and restaurateurs </li>
			</ul>
			<h1 class="about-header">What is TopDish?</h1>
	            <p class="about-blue-text">TopDish is a web and mobile app service that provides personalized dish recommendations when dining out. With rich dish meta data, powerful search and filter options and a keen awareness of your taste profile, TopDish makes it easier than ever for you and your friends to discover and enjoy new and amazing dishes.</p>
			<div class="about-tagline-logo"></div>
			<div class="about-tagline">Enjoy Top Dish and Feed your Craving!</div>
				<div style="clear:both;"></div>
			<div class="about-bottom-text"><a href="howTo.jsp">Having trouble getting started? Click here to watch our How To videos!</a></div>
			<div class="about-bottom-text"><a href="mailto:info@topdish.com">Click here to send us your thoughts and ideas. We love to hear from you.</a></div>
		</div>
</div> <!--  colleft -->
<jsp:include page="footer.jsp"/>