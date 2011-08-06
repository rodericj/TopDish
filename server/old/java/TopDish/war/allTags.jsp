<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%@page import="com.topdish.comparator.TagNameComparator"%>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Collection" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TagUtils" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>

<title>Top Dish | All Tags</title>
</head>
<body>

<h2>All Tags</h2>
<table border="1px">
	<tr>
		<th>Parent Tag</th>
    	<th>Tag Id </th>
		<th>Tag Name</th>
		<th>Tag Type</th>
		<th>Description</th>
		<th>Order</th>
		<th># Dishes</th>
		<th>Edit</th>
		<th>Delete</th>
	</tr>
<%
	//TODO(randy): To speed this up further, store the dish count in each tag. Ideally run a cron to update these numbers.

	final Integer[] desiredTags = new Integer[] { Tag.TYPE_MEALTYPE, Tag.TYPE_INGREDIENT,
		Tag.TYPE_PRICE, Tag.TYPE_LIFESTYLE, Tag.TYPE_ALLERGEN, Tag.TYPE_CUISINE, Tag.TYPE_GENERAL };	
	final Set<Tag> tagSet = TagUtils.getTagsByType(desiredTags);
	final List<Tag> tags = new ArrayList<Tag>(tagSet);
	Collections.sort(tags, new TagNameComparator());
	
	for (Tag t : tags) {
		Tag parent = null;
		if(t.getParentTag() != null){
			try{
				parent = Datastore.get(t.getParentTag());
			}catch(Exception e){
				t.setParentTag(null);
			}
		}
		
		final String queryString = "SELECT key FROM " + Dish.class.getName();
		final Query q2 = PMF.get().getPersistenceManager().newQuery(queryString);
		q2.setFilter("tags.contains(:tagParam)");
		final Set<Key> dishKeys = new HashSet<Key>((Collection<Key>) q2.execute(t.getKey()));
		int numUses = dishKeys.size();
%>
		<tr style="text-align:center">
			<td><% if(parent != null) out.print(parent.getName()); else out.print("&nbsp;"); %></td>
           	<td><% out.print(t.getKey().getId()); %></td>
			<td><% out.print(t.getName()); %></td>
			<td><% out.print(t.getTagTypeName()); %></td>
			<td><% out.print(t.getDescription()); %></td>
			<td><% out.print(t.getManualOrder()); %></td>
			<td><%=numUses%></td>
			<td>
				<a href="editTag.jsp?tagID=<%out.print(t.getKey().getId());%>">[Edit]</a>
			</td>
			<td>
				<form action="deleteTag" method="post">
					<input type="hidden" name="tagID" value="<%=t.getKey().getId()%>"/>
					<input type="submit" value="Delete"/>
				</form>
			</td>
		</tr>
<%
	}
%>
</table>
</body>
</html>