<%@ page import="com.topdish.jdo.*" %>
<jsp:include page="header.jsp" />
<div class="colleft">
	<div class="col1">
	</div>
	<div class="col2">
<script type="text/javascript" src="/js/topdish.autocomplete.js"></script>
<% 
	String name = "";
	String description = "";
	String parentName = "";
	String parentID = "";
	String typeS = "";
	int type = 0;
	
	if(request.getParameter("name") != null)
		name = request.getParameter("name");
	if(request.getParameter("description") != null)
		description = request.getParameter("description");
	if(request.getParameter("parentName") != null)
		parentName = request.getParameter("parentName");
	if(request.getParameter("parentID") != null)
		parentID = request.getParameter("parentID");
	if(request.getParameter("type") != null){
		typeS = request.getParameter("type");
		if(!typeS.equals("")){
			type = Integer.parseInt(typeS);
		}
	}

%>
<h2>Add Tag</h2>
<form action="addTag" method="post">
	<label>Name: <input type="text" name="name" value="<% out.print(name); %>"></input></label><br />
	<label>Description: <input type="text" name="description"  value="<% out.print(description); %>"></input></label><br />
	<label>Parent tag: <input type="text" name="parent" id="tag_parent" value="<% out.print(parentName); %>"></input></label><br />
	<input type="hidden" name="parentID" id="tag_parent_id" value="<% out.print(parentID); %>"></input>
	<label>Type: 
		<select name="type">
			<option <% if(type == Tag.TYPE_GENERAL) out.print("selected"); %> value="<% out.print(Tag.TYPE_GENERAL); %>">General</option>
			<option <% if(type == Tag.TYPE_CUISINE) out.print("selected"); %> value="<% out.print(Tag.TYPE_CUISINE); %>">Cuisine</option>
			<option <% if(type == Tag.TYPE_LIFESTYLE) out.print("selected"); %> value="<% out.print(Tag.TYPE_LIFESTYLE); %>">Lifestyle</option>
			<option <% if(type == Tag.TYPE_PRICE) out.print("selected"); %> value="<% out.print(Tag.TYPE_PRICE); %>">Price</option>
			<option <% if(type == Tag.TYPE_ALLERGEN) out.print("selected"); %> value="<% out.print(Tag.TYPE_ALLERGEN); %>">Allergen</option>
			<option <% if(type == Tag.TYPE_MEALTYPE) out.print("selected"); %> value="<% out.print(Tag.TYPE_MEALTYPE); %>">Meal Type</option>
			<option <% if(type == Tag.TYPE_INGREDIENT) out.print("selected"); %> value="<% out.print(Tag.TYPE_INGREDIENT); %>">Ingredient</option>
		</select>
	 </label>
	<input type="submit" value="Add Tag"></input>
</form>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />