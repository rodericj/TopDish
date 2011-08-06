<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<jsp:include page="header.jsp" />

<div >
	<div>
		<p><b>Error:</b></p>
		<c:set var="err" value="${param.e}"/>
		<c:choose>
			<c:when test="${err eq 'dishedit'}">
				Sorry. You do not have the permission to edit this dish details
			</c:when>
			<c:when test="${err eq 'restedit'}">
				Sorry. You do not have the permission to edit this restaurant details
			</c:when>
			<c:when test="${err eq 'dishdel'}">
				Sorry. You are not allowed to delete this dish.
			</c:when>
			<c:when test="${err eq 'tagedit'}">
				Sorry. You do not have the permission to edit this tag details
			</c:when>
			<c:when test="${err eq 'photorotat'}">
				Sorry. You do not have the permission to rotate this photo
			</c:when>
			<c:otherwise>
			</c:otherwise>
		</c:choose>
	</div>
</div> <!--  colleft -->
<jsp:include page="footer.jsp"/>

