<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:if test="${not empty requestScope.flagViewObj}">
<c:set var="flag" value="${requestScope.flagViewObj}"/>
	<td>
	<strong>User</strong><br>${flag.creatorUsername } <br><br>
	<strong>Flag ID</strong><br>${flag.key.id } <br><br>
	<strong>Flag Type</strong><br>${flag.typeStringValue }<br><br>
	<strong>Comment</strong><br><c:out value="${flag.comment}"/><br><br>
	<hr> 
	<strong>Add comment</strong><br>
	<textarea rows="5" cols="32" id="adminCommentBox"></textarea><br><br>
	<input type="button" id="btnMarkResolved" value="Mark as Resolved" onClick="javascript:takeFlagAction(${flag.key.id})" class="btn"><br><br>
	</td>
</c:if>