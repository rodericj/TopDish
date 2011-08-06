<%@ page import="java.util.List"%>
<%@ page import="com.topdish.util.PMF"%>
<%@ page import="com.topdish.util.Datastore"%>
<%@ page import="com.topdish.jdo.*"%>
<%@ page import="com.google.appengine.api.datastore.Key"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>

<jsp:include page="header.jsp" />

<script type="text/javascript" src="/js/topdish.autocomplete.js"></script>

<%
	long tagID = Long.valueOf(request.getParameter("tagID"));
	Tag t = Datastore.get(KeyFactory.createKey(
			Tag.class.getSimpleName(), tagID));
	Tag parent = null;
	if (t.getParentTag() != null) {
		parent = Datastore.get(t.getParentTag());
	}
	int type = t.getType();
%>

<h2>Edit Tag</h2>
<form action="updateTag" method="post">
	<label>Name: <input type="text" name="name"
		value="<%out.print(t.getName());%>"></input>
	</label><br /> <label>Description: <input type="text"
		name="description" value="<%out.print(t.getDescription());%>"></input>
	</label><br /> <input type="hidden" name="id"
		value="<%out.print(t.getKey().getId());%>"></input> <label>Type:
		<select name="type">
			<option <%if (type == Tag.TYPE_GENERAL)
				out.print("selected");%>
				value="<%out.print(Tag.TYPE_GENERAL);%>">General</option>
			<option <%if (type == Tag.TYPE_CUISINE)
				out.print("selected");%>
				value="<%out.print(Tag.TYPE_CUISINE);%>">Cuisine</option>
			<option <%if (type == Tag.TYPE_LIFESTYLE)
				out.print("selected");%>
				value="<%out.print(Tag.TYPE_LIFESTYLE);%>">Lifestyle</option>
			<option <%if (type == Tag.TYPE_PRICE)
				out.print("selected");%>
				value="<%out.print(Tag.TYPE_PRICE);%>">Price</option>
			<option <%if (type == Tag.TYPE_LIFESTYLE)
				out.print("selected");%>
				value="<%out.print(Tag.TYPE_ALLERGEN);%>">Allergen</option>
			<option <%if (type == Tag.TYPE_MEALTYPE)
				out.print("selected");%>
				value="<%out.print(Tag.TYPE_MEALTYPE);%>">Meal Type</option>
			<option <%if (type == Tag.TYPE_INGREDIENT)
				out.print("selected");%>
				value="<%out.print(Tag.TYPE_INGREDIENT);%>">Ingredient</option>
	</select> </label><br /> <label>Parent Tag: <input type="text" name="parent"
		id="tag_parent"
		value="<%if (parent != null)
				out.print(parent.getName());%>"></input>
	</label><br /> <label>Manual Order: <input type="text"
		name="manual_order" value="<%=t.getManualOrder()%>"></input>
	</label><br /> <input type="hidden" name="parentID" id="tag_parent_id"
		value="<%if (parent != null)
				out.print(parent.getKey().getId());%>"></input>
	<input type="submit" value="Update Tag"></input>
</form>
<jsp:include page="footer.jsp" />