<%@ page import="java.util.List" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="com.topdish.jdo.Dish" %>
<%@ page import="com.topdish.jdo.TDUser" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.TDUserService" %>


<script type="text/javascript" src="/js/topdish.autocomplete.js"></script>

<div class="colleft">
	<div class="col1">
 		<jsp:include page="/blocks/newDish.jsp"/>
		<jsp:include page="/blocks/topUsers.jsp"/>
		<jsp:include page="/blocks/top10Dishes.jsp"/>
	</div>
	<div class="col2">
<%
	if(TDUserService.getUserLoggedIn()){
		//user is logged in
%>
		<form action="/uploadCSVServlet" method="post" enctype="multipart/form-data">
			Choose restaurant:<br>
			<input type="text" class="grey_input_box grey_input_box_none" name="restName" id="rest_name1"></input>
			<br><input type="hidden" id="rest_id1" name="restID"></input>
			<br>
			<input type="file" name="dishes_csv" size="40">
			<br>
			<input type="submit" value="Upload CSV" />
		</form>
		All Dishes:<br>
<%
	}else{
		//not logged in
		response.sendRedirect("index.jsp");
	}

	String query = "select from " + Dish.class.getName();
	List<Dish> dishes = (List<Dish>) PMF.get().getPersistenceManager().newQuery(query).execute();
	for (Dish d : dishes) {
		TDUser creator = PMF.get().getPersistenceManager().getObjectById(TDUser.class, d.getCreator());
%>
		Dish: <%= d.getName() %><br>
		Desc: <%= d.getDescription() %><br>
		Where: <%= d.getRestaurant() %><br>
		Who: <%= creator.getNickname() %><br>
		Tags: <%= d.getTags() %> <br>
		<hr>
<%
	}
%>

	</div> <!--  col2 -->
</div> <!--  colleft -->

