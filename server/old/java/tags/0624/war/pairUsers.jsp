<%@ page import="com.topdish.api.util.FacebookConstants" %>
<%@ page import="com.topdish.util.TDUserService" %>

<jsp:include page="header.jsp" />
<div class="colleft">
<%
final boolean isFacebook = TDUserService.isFacebookUser(request);
final boolean isGoogle = TDUserService.isGoogleUser(request);
final String redirectURL = FacebookConstants.FACEBOOK_BASE_REDIRECT_URI + "/facebookLogin";
%>
	<h1 class="about-header">Pair with:</h1>
	<p style="align:center;">
<%	if(isFacebook && !isGoogle){ %>
	
	<a href="<%=TDUserService.getGoogleLoginURL("/loginLogic")%>">
		<img src="img/google.jpg" width="250" style="float:left;"/>
	</a>
<%} else if (isGoogle && !isFacebook){%>
	<a href="https://www.facebook.com/dialog/oauth?client_id=<%=FacebookConstants.APP_ID%>&redirect_uri=<%=redirectURL%>">
		<div id="fb-root"></div>
		<script src="http://connect.facebook.net/en_US/all.js#appId=<%=FacebookConstants.APP_ID%>&amp;xfbml=1"></script>
		<img src="img/facebook.jpg" width="250" style="float:left; padding-top:35px"/>
	</a>
<%} %>
	</p>
</div> <!--  colleft -->
<jsp:include page="footer.jsp"/>