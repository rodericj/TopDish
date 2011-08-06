<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="javax.jdo.Query" %>
<%@include file="/includes/userTagIncludes.jsp" %>
<title>Top Dish | All Tags</title>
</head>
<body>
<h2>All Tags</h2>
<table border="1px">
	<tr>
		<th>Parent Tag</th>
		<th>Tag Name</th>
		<th>Tag Type</th>
		<th>Description</th>
		<th>Order</th>
		<th># Dishes</th>
		<user:isUserInRole roles="${administrator},${standard},${advanced}" >
			<th>Edit</th>
		</user:isUserInRole>
		<user:isUserInRole roles="${administrator}" >
			<th>Delete</th>
		</user:isUserInRole>
	</tr>
<%
	int oddEven = 0;
	PersistenceManager pm = PMF.get().getPersistenceManager();
	//show all tags
	Query q = pm.newQuery(Tag.class);
	q.setOrdering("type desc");
	List<Tag> tags = (List<Tag>) q.execute();
	
	for (Tag t : tags) {
		Tag parent = null;
		if(t.getParentTag() != null){
			parent = pm.getObjectById(Tag.class, t.getParentTag());
		}
		
		Query q2 = pm.newQuery(Dish.class);
		q2.setFilter("tags.contains(:tagParam)");
		List<Dish> dishes = (List<Dish>) q2.execute(t.getKey());
		int numUses = dishes.size();
%>
		<tr style="text-align:center">
			<td><% if(parent != null) out.print(parent.getName()); else out.print("&nbsp;"); %></td>
			<td><% out.print(t.getName()); %></td>
			<td><% out.print(t.getTagTypeName()); %></td>
			<td><% out.print(t.getDescription()); %></td>
			<td><% out.print(t.getManualOrder()); %></td>
			<td><%=numUses%></td>
			<user:isUserInRole roles="${administrator},${standard},${advanced}" tagId="<%=t.getKey().getId() %>">
			<td>
				<a href="editTag.jsp?tagID=<%out.print(t.getKey().getId());%>">[Edit]</a>
			</td>
			</user:isUserInRole>
			<user:isUserInRole roles="${administrator}" >
			<td>
				<form action="/deleteTag" method="post">
					<input type="hidden" name="tagID" value="<%=t.getKey().getId()%>"></input>
					<input type="submit" value="Delete"></input>
				</form>
			</td>
			</user:isUserInRole>
		</tr>
<%
	}
	pm.close();
%>
</table>
</body>
</html>