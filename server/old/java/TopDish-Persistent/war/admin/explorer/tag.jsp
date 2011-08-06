<%@ page import="com.topdish.adminconsole.TopDishConstants"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Collections" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.comparator.TagManualOrderComparator" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ include file="/includes/userTagIncludes.jsp" %>

<script src="../../js/admin/topdish.adminconsole.explorer.js" type="text/javascript" ></script>
<script src="../../js/jquery-1.4.2.min.js" type="text/javascript"></script>
<script src="../../js/jquery-ui-1.8.1.custom.min.js" type="text/javascript"></script>
<script src="../../js/admin/jquery.form.js" type="text/javascript"></script>

<%
	long tagID = Long.parseLong(request.getParameter("tagID"));
	final Tag t = Datastore.get(KeyFactory.createKey(Tag.class.getSimpleName(), tagID));
	Tag parent = null;
	if(null != t.getParentTag()){
		parent = Datastore.get(t.getParentTag());
	}
%>

<div class="editTitleHeader">Edit Tag </div>
<div id="col1Div">
	<form action="/updateTag" method="post" id="updateTagForm">
		<div class="rating_header" >
			<div class="editTitle">Name:</div>
			<input type="text" class="grey_input_box grey_input_box_none" name="name" id="name" value="<% out.print(t.getName()); %>"/>

			</div>
			<div class="rating_header">
				<div class="editTitle">Description</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" name="description" id="description" value="<% out.print(t.getDescription()); %>"/>
			</div>
			<div class="rating_header">
				<div class="editTitle">Type:</div>
			   	<select name="type" id="type">
					<option <% if(t.getType() == Tag.TYPE_GENERAL) out.print("selected"); %> value="<% out.print(Tag.TYPE_GENERAL); %>">General</option>
					<option <% if(t.getType() == Tag.TYPE_CUISINE) out.print("selected"); %> value="<% out.print(Tag.TYPE_CUISINE); %>">Cuisine</option>
					<option <% if(t.getType() == Tag.TYPE_LIFESTYLE) out.print("selected"); %> value="<% out.print(Tag.TYPE_LIFESTYLE); %>">Lifestyle</option>
					<option <% if(t.getType() == Tag.TYPE_PRICE) out.print("selected"); %> value="<% out.print(Tag.TYPE_PRICE); %>">Price</option>
					<option <% if(t.getType() == Tag.TYPE_LIFESTYLE) out.print("selected"); %> value="<% out.print(Tag.TYPE_ALLERGEN); %>">Allergen</option>
					<option <% if(t.getType() == Tag.TYPE_MEALTYPE) out.print("selected"); %> value="<% out.print(Tag.TYPE_MEALTYPE); %>">Meal Type</option>
					<option <% if(t.getType() == Tag.TYPE_INGREDIENT) out.print("selected"); %> value="<% out.print(Tag.TYPE_INGREDIENT); %>">Ingredient</option>
				</select>
				<input type="hidden" name="id" id="tag_id" value="<% out.print(t.getKey().getId()); %>"/>
				<input type="hidden" name="ajax" value="true"/>
			</div>
			<div class="rating_header">
				<div class="editTitle">Parent Tag</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" name="parent" value="<% if(parent != null) out.print(parent.getName()); %>"/>
			</div>

			<div class="rating_header">
				<div class="editTitle">Manual Order</div>
			   	<input type="text" class="grey_input_box grey_input_box_none" name="manual_order" value="<%=t.getManualOrder()%>"/>
			</div>
			<div class="rating_header">
				<input type="hidden" name="parentID" id="tag_parent_id" value="<% if(parent != null) out.print(parent.getKey().getId()); %>"/>
			</div>
			<div class="rating_header">
				<input type="button" value="Cancel" class="submitButton" id="cancel"/>
		    	<input type="submit" value="Update Tag" class="submitButton"/>
			</div>
		</form>
</div><!--div2-->
<div id="messageId" class="editFooter_1col"></div>