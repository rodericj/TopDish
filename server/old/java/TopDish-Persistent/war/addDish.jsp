<%@ page import="javax.jdo.Query" %>
<%@ page import="java.util.List" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<jsp:include page="header.jsp" />
<div class="colleft">
	<div class="col1">
	</div>
	<div class="col2">
<script type="text/javascript" src="/js/topdish.autocomplete.js"></script>
<%
	String name = "";
	String description = "";
	String restName = "";
	String tagList = "";
	String restID = "";
	if(request.getParameter("name") != null)
		name = request.getParameter("name");
	if(request.getParameter("description") != null)
		description = request.getParameter("description");
	if(request.getParameter("restaurantName") != null)
		restName = request.getParameter("restaurantName");
	if(request.getParameter("tagList") != null)
		tagList = request.getParameter("tagList");
	if(request.getParameter("restID") != null)
		restID = request.getParameter("restID");
	
	PersistenceManager pm = PMF.get().getPersistenceManager();
	
%>
<h2>Add Dish</h2>
<form action="addDish" method="post">
	<label>Name: <input type="text" name="name" value="<% out.print(name); %>"></input></label><br />
	<label>Description: <input type="text" name="description" id="description" value="<% out.print(description); %>"></input></label><br />
	<label>Restaurant: <input type="text" name="restaurantName" id="rest_name" value="<% out.print(restName); %>"></input></label><br />
	Can't find it? <a href="restaurantSearch.jsp">Add a Restaurant</a>
	<br />
	<label>Tags: <input type="text" name="tagList" id="tag_list" value="<% out.print(tagList); %>"></input></label>
	Can't find it? <a href="addTag.jsp">Add a Tag</a>
	<br />
	<input type="hidden" name="restaurantID" id="rest_id" value="<% out.print(restID); %>"></input>
	<br />
	<label>Category:</label>
	<select name="categoryID">
	<%
		Query query = pm.newQuery(Tag.class);
		List<Tag> categories;
		query.setFilter("type == typeParam");
	    query.declareParameters("int typeParam");
	    query.setOrdering("name ASC"); //alpha order
		categories = (List<Tag>) query.execute(Tag.TYPE_MEALTYPE); //only cuisines
		out.print("<option value=\"\">All</option>");
		for (Tag c : categories) {
			out.print("<option value=\"" + c.getKey().getId() + "\">" + c.getName() + "</option>");			
		}
	%>
	</select>
	<br />
	<label>Price:</label>
	<select name="priceID">
	<%
		List<Tag> prices;
		query.setFilter("type == typeParam");
	    query.declareParameters("int typeParam");
	    query.setOrdering("name ASC"); //alpha order
		prices = (List<Tag>) query.execute(Tag.TYPE_PRICE); //only cuisines
		out.print("<option value=\"\">All</option>");
		for (Tag p : prices) {
			out.print("<option value=\"" + p.getKey().getId() + "\">" + p.getName() + "</option>");			
		}
	%>
	</select>
	
	<input type="submit" value="Add Dish"></input>
</form>
	</div> <!--  col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp" />