<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.comparator.TagManualOrderComparator" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ include file="/includes/userTagIncludes.jsp" %>

<script src="../../js/jquery-1.4.2.min.js" type="text/javascript"></script>
<script src="../../js/jquery-ui-1.8.1.custom.min.js" type="text/javascript"></script>
<script src="../../js/admin/jquery.form.js" type="text/javascript"></script>
<script src="../../js/admin/topdish.adminconsole.explorer.js" type="text/javascript" ></script>

<%
	long reviewID = Long.valueOf(request.getParameter("reviewID"));	
	final Review r = Datastore.get(KeyFactory.createKey(Review.class.getSimpleName(), reviewID));
	final Dish d = Datastore.get(r.getDish());
%>

<div class="editTitleHeader">View Review </div>
<div id="col1Div">
	<form action="#" method="post" >
		<div class="rating_header" >
			<div class="editTitle">Dish Name:</div>
			<% out.print(d.getName()!=null?d.getName():""); %>
			<c:set var="reviewID" value="<%=r.getKey().getId() %>"/>
			</div>
			<div class="rating_header">
				<div class="editTitle">Comment</div>
			   	<% out.print(r.getComment()); %>
			</div>
			<div class="rating_header">
				<input type="button" value="Cancel" class="submitButton" id="cancel"/>
			   	<input type="button" value="Delete" class="submitButton" onclick="javascript:deleteEntity('review', '${reviewID}')"/>
			</div>
		</form>

</div><!--div2-->
<div id="messageId" class="editFooter_1col"></div>