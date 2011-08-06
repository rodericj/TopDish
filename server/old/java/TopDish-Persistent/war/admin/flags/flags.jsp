<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:if test="${not empty requestScope.flagsDisplayList}">
<c:set var="rowClass" value="row-even"/>

<c:forEach items="${requestScope.flagsDisplayList}" var="flag">
	<c:choose>
	<c:when test="${rowClass eq 'row-odd' }"><c:set var="rowClass" value="row-even"/></c:when>
	<c:when test="${rowClass eq 'row-even' }"><c:set var="rowClass" value="row-odd"/></c:when>
	</c:choose>
	
	<tr class="${rowClass }">
		<td>${flag.key.id}</td>
		<td>${flag.typeStringValue}</td>
		<td><c:out value="${fn:substring(flag.comment,0,70)}"/></td>
		<td><c:out value="${fn:substring(flag.creatorUsername,0,30)}"/></td>
		<td><a onClick="javascript:showFlagAction(${flag.key.id });" href="#">View</a></td>
	</tr>
</c:forEach>
</c:if>