<%@ page import="com.topdish.jdo.Source" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.topdish.util.TDQueryUtils" %>
<%@page import="com.topdish.util.TDUserService"%>
<jsp:include page="header.jsp" />
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>

<%
	if(!TDUserService.isUserLoggedIn(request.getSession(false))){
%>
		<jsp:forward page="index.jsp" />
<%
	}

    BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	long dishID = 0;
	long restID = 0;
	long userID = 0;
	String blobUploadURL = blobstoreService.createUploadUrl("/addPhoto");
%>
<h2>Add Photo</h2>
<form action="<%= blobUploadURL %>" method="post" enctype="multipart/form-data">
	<label>&nbsp; Photo:<input type="file" name="myFile"></input></label> <br  />
    <br  />
	<label>&nbsp; Description:<input type="text" name="description"></input></label> <br  />
<%
	if(request.getParameter("dishID") != null){
		dishID = Long.valueOf(request.getParameter("dishID"));
%>
		<input type="hidden" name="dishID" value="<%=dishID%>">
<%
	}else if(request.getParameter("restID") != null){
		restID = Long.valueOf(request.getParameter("restID"));
%>
		<input type="hidden" name="restID" value="<%=restID%>">
<%
	}else if(request.getParameter("userID") != null){
		userID = Long.valueOf(request.getParameter("userID"));
%>
		<input type="hidden" name="userID" value="<%=userID%>">
<%
	}
%>
<br  />
	<label>&nbsp; Choose a Source from the Drop Down, or enter a new one below:
    <select name="sourceDrop" id="sourceDrop">
    <% Set<Source> sources = TDQueryUtils.getAllSources();
	
	//Traverse sources
	for(Source source : sources) {
		//print options selector
		out.print("<option value=\""+source.getKey().getId()+"\">"+source.getName()+"</option>");
	} 
	out.print("<option selected value=\"Other\" >"+"Enter a New One Below"+"</option>");
	%>
    </select> </label>
<br  />
<br  />
   	<label>&nbsp; Source Name: <input type="text" name="sourceName" id="sourceName"  /></label>
<br  />
<br  />
    <label>&nbsp; Source URL: <input type="text" name="sourceURL" id="sourceURL"  /></label>  &nbsp; Note: This is the Source's main url, please make sure to start with http:// 
<br  />
<br  />
        <label>&nbsp; Source's Photo URL: <input type="text" name="sourcePhotoURL" id="sourcePhotoURL"  /></label>  &nbsp; Note: This is the direct url to the Photo on the Source's site. Please make sure to start with http://
<br  />
<br  />
	<input type="submit" value="Add Photo">
</form>
<jsp:include page="footer.jsp" />