<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>TopDish</title>
<link href="/style/topdish-splash.css" rel="stylesheet" type="text/css" />
</head>
<body>
<%
UserService userService = UserServiceFactory.getUserService();
String testURL = userService.createLoginURL("index.jsp");
String loginURL = "";
if(testURL.indexOf(".com") > 0){
	//we are on appengine
	loginURL = userService.createLoginURL("index.jsp");
}else{
	//we are localhost/testing
	loginURL = userService.createLoginURL("../index.jsp");
}
%>
<div id="container">
	<div id="content">
		<div id="header-main">
			<div id="logo"></div>
			<div id="chinese-box"></div>
		</div>
		<div id="bar">
			<div id="bar-main">
				<h1 class="headline">feed your craving</h1>
				<div id="icon"></div>
				<div class="login"><a href="<%=loginURL%>">LOGIN</a> OR <a href="betaLogin.jsp">NEW BETA USER</a> OR</div>
				<div class="signup"><a href="https://spreadsheets.google.com/a/topdish.com/viewform?hl=en&pli=1&formkey=dFFQUmswaHMzUGdEV2VDUE5rdWttNmc6MQ#gid=0"><span>Request Invite</span></a></div>
				<div class="copyright">&copy; 2010 TopDish, Inc. All Rights Reserved. <a href="mailto:info@topdish.com">Get in touch!</a></div>
			</div>
		</div>
	</div>
</div>
<script>window.scrollTo(0,1)</script>
</body>
</html>