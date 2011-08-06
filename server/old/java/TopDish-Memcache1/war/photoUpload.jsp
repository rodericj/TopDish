<jsp:include page="header.jsp" />
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>

<%
    BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	long dishID = 0;
	long restID = 0;
	long userID = 0;
	String blobUploadURL = blobstoreService.createUploadUrl("/addPhoto");
%>
<h2>Add Photo</h2>
<form action="<%= blobUploadURL %>" method="post" enctype="multipart/form-data">
	<label>Photo:<input type="file" name="myFile"></input></label>
	<label>Description:<input type="text" name="description"></input></label>
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
	<input type="submit" value="Add Photo">
</form>
<jsp:include page="footer.jsp" />