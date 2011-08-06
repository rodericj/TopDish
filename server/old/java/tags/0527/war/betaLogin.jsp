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
String status = request.getParameter("status");
String token = request.getParameter("token");
if(token == null){
	token = "";
}

String message = "";
if(status != null){
	if(status.equals("used")){
		message = "That beta token is not valid.";
		//token is invalid =(
	}else if(status.equals("notfound")){
		//token not found =(
		message = "That's not a valid beta token.";
	}
}
%>

<div id="container">
	<div id="content">
	<div id="header"></div>
		<div id="header-main">
			<div id="logo"></div>
			<div id="chinese-box"></div>
		</div>
		<div id="bar">
			<div id="bar-main">
				<form action="/validateToken" method="post">
				<h1 class="headline">Beta code:
					<input type="text" name="token" style="width:19em;height:1.5em;" value="<%=token%>"></input>
					<input type="submit" value="Let's Go!" style="height:2em;"/>
					<br />
					<%=message%>
				</h1>
				</form>
				<div class="copyright">&copy; 2010 TopDish, Inc. All Rights Reserved. <a href="mailto:info@topdish.com">Get in touch!</a></div>
			</div>
		</div>
	</div>
</div>

</body>
</html>