<%@ page import="com.topdish.jdo.Source" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>

<% 
	String summary = "";
	if(null != (summary = request.getParameter("summary")))
		out.println(summary);
	%>

<form action="/uploadBulk" method="post" enctype="multipart/form-data">
    &nbsp; Choose a Source from the Drop Down, or enter a new one below:
    <select name="sourceDrop" id="sourceDrop">
    <% Set<Source> sources = TDQueryUtils.getAllSources();
	
	//Traverse sources
	for(Source source : sources) {
		//print options selector
		out.print("<option value=\""+source.getKey().getId()+"\">"+source.getName()+"</option>");
	} 
	out.print("<option selected value=\"Other\" >"+"Enter a New One Below"+"</option>");
	%>
    </select>
    <br />
   	&nbsp; Source Name: <input type="text" name="sourceName" id="sourceName"  />     <br />
    &nbsp; Source URL: <input type="text" name="sourceURL" id="sourceURL"  />  &nbsp; Note: Please make sure to start with http://  <br />
	&nbsp; File: <input type="file" name="dishes_csv" id="dishes_csv">     <br />
	<br>
	<input type="submit" value="Upload CSV" />
</form>