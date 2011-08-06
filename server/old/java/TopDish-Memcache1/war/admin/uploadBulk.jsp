<% 
	String summary = "";
	if(null != (summary = request.getParameter("summary")))
		out.println(summary);
	%>

<form action="/uploadBulk" method="post" enctype="multipart/form-data">
	<input type="file" name="dishes_csv" size="40">
	<br>
	<input type="submit" value="Upload CSV" />
</form>