<%@ page import="com.topdish.util.Alerts" %>

<%
final String info = Alerts.getInfo(request);
final String error = Alerts.getError(request);
%>

<% if(null != info){ %>
	<div class="alert info">
		<%= info %>
	</div>
<% } %>

<% if(null != error){ %>
	<div class="alert error">
		<%= error %>
	</div>
<% } %>