<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@include file="/includes/userTagIncludes.jsp" %>

<c:choose>
	<c:when test="${param.flagFor eq 'dish'}" >
		<c:if test="${not empty requestScope.displayList}">
			
			<c:set var="rowClass" value="row-even"/>
			<c:set var="cols" value="4"/>
			
			<c:forEach items="${requestScope.displayList}" var="dish">
				<c:choose>
				<c:when test="${rowClass eq 'row-odd' }"><c:set var="rowClass" value="row-even"/></c:when>
				<c:when test="${rowClass eq 'row-even' }"><c:set var="rowClass" value="row-odd"/></c:when>
				</c:choose>
				
				<tr class="${rowClass }">
					<td><a href="/admin/topDishExplorer?action=${ACTION_VIEWDISHES}&dishID=${dish.key.id}">${dish.key.id }</a></td>
					<td><c:out value="${dish.name }"/></td>
					<td>${dish.numFlagsTotal }</td>
					<td><a onClick="javascript:showFlagsForSelectedItem('dish',${dish.key.id });" href="#">View Flags</a></td>
				</tr>
			</c:forEach>
		</c:if>
		
	</c:when>
	<c:when test="${param.flagFor eq 'restaurant'}">
		
		<c:if test="${not empty requestScope.displayList}">
			
			<c:set var="rowClass" value="row-even"/>
			<c:set var="cols" value="4"/>
			
			<c:forEach items="${requestScope.displayList}" var="restaurant">
				<c:choose>
				<c:when test="${rowClass eq 'row-odd' }"><c:set var="rowClass" value="row-even"/></c:when>
				<c:when test="${rowClass eq 'row-even' }"><c:set var="rowClass" value="row-odd"/></c:when>
				</c:choose>
				
				<tr class="${rowClass }">
					<td><a href="/admin/topDishExplorer?action=${ACTION_VIEWRESTAURANT}&restID=${restaurant.key.id}">${restaurant.key.id }</a></td>
					<td><c:out value="${restaurant.name }"/></td>
					<td>${restaurant.numFlagsTotal }</td>
					<td><a onClick="javascript:showFlagsForSelectedItem('restaurant',${restaurant.key.id });" href="#">View Flags</a></td>
				</tr>
			</c:forEach>
		</c:if>
	</c:when>
	<c:when test="${param.flagFor eq 'review'}">
		<c:if test="${not empty requestScope.displayList}">
			
			<c:set var="rowClass" value="row-even"/>
			<c:set var="cols" value="5"/>
			
			<c:forEach items="${requestScope.displayList}" var="review">
				<c:choose>
				<c:when test="${rowClass eq 'row-odd' }"><c:set var="rowClass" value="row-even"/></c:when>
				<c:when test="${rowClass eq 'row-even' }"><c:set var="rowClass" value="row-odd"/></c:when>
				</c:choose>
				
				<tr class="${rowClass }">
					<td><a href="/admin/topDishExplorer?action=${ACTION_VIEWREVIEW}&reviewID=${review.key.id}">${review.key.id}</a></td>
					<td><c:out value="${fn:substring(review.comment,0,80)}"/></td>
					<td><c:out value="${fn:substring(review.dishName,0,30)}"/></td>
					<td>${review.numFlagsTotal }</td>
					<td><a onClick="javascript:showFlagsForSelectedItem('review',${review.key.id });" href="#">View Flags</a></td>
				</tr>
			</c:forEach>
		</c:if>
	</c:when>
	<c:when test="${param.flagFor eq 'photo'}">
		<c:if test="${not empty requestScope.displayList}">
			
			<c:set var="rowClass" value="row-even"/>
			<c:set var="cols" value="6"/>
			
			<c:forEach items="${requestScope.displayList}" var="photo">
				<c:choose>
				<c:when test="${rowClass eq 'row-odd' }"><c:set var="rowClass" value="row-even"/></c:when>
				<c:when test="${rowClass eq 'row-even' }"><c:set var="rowClass" value="row-odd"/></c:when>
				</c:choose>
				
				<tr class="${rowClass }">
					<td><a href="/admin/topDishExplorer?action=${ACTION_VIEWPHOTO}&photoID=${photo.key.id}">${photo.key.id}</a></td>
					<td>
						<img src="${photo.photoUrl}" width="50" height="50" border="0" onmouseover="javascript: showEnlargedImg(${photo.key.id});" onmouseout="javascript: hideEnlargedImg(${photo.key.id});"/>
						<div style="position: absolute; display: none;" id="enlargedImg${photo.key.id}">
							<img src="${photo.photoUrl}"/>
						</div>
					</td>
					<td><c:out value="${fn:substring(photo.description,0,60)}"/></td>
					<td>${photo.creatorName}</td>
					<td>${photo.numFlagsTotal }</td>
					<td><a onClick="javascript:showFlagsForSelectedItem('photo',${photo.key.id });" href="#">View Flags</a></td>
				</tr>
			</c:forEach>
		</c:if>
	</c:when>
</c:choose>

<c:if test="${not empty requestScope.displayList}">
	<!-- code for paging -->
	<c:set var="displaySize" value="${requestScope.displaySize}"/>
	<c:set var="listSize" value="${fn:length(sessionScope.displayListSessionData)}"/>
	<c:set var="pageNo" value="${requestScope.pageNo}"/>
	<c:set var="noOfPagesApprox" value="${listSize/displaySize}"/>
	<c:set var="noOfPages" value="${noOfPagesApprox + (1 - (noOfPagesApprox % 1)) % 1}"/>
	
	<c:if test="${pageNo gt noOfPages}"><c:set var="pageNo" value="1"/></c:if>
	
	<tr class="paging">
		<td colspan="7" >
			<table width="100%" style="text-align: center; border: 0px;" cellspacing="0" cellpadding="0" class="paging">
			<tr>
				<td width="33%" style="text-align: left;">
					<c:if test="${pageNo gt 1}">
						<a href="#" onclick="javascript:showPage(${pageNo - 1},'${param.flagFor}')">[Prev]</a> &nbsp;&nbsp;
					</c:if>
				</td>
				<td width="33%" style="text-align: center;" class="pagingRecordCount">
					${listSize} records found
					<%--Page: ${pageNo} of <fmt:formatNumber type="number" maxFractionDigits="0" value="${noOfPages}" />
					<c:if test="${noOfPages gt 1}">
						&nbsp;&nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;&nbsp;Goto Page: <input type="text" id="txtGoto" value="" class="edit-txt" size="2" maxlength="3" /><input type="button" class="btn" onclick="javascript:gotoPage('${param.flagFor}');" value="Go"/>
					</c:if>--%>
				</td>
				<td width="33%" style="text-align: right;">
					<c:if test="${pageNo lt noOfPages}">
						<a href="#" onclick="javascript:showPage(${pageNo + 1},'${param.flagFor}')">[Next]</a>
					</c:if>
				</td>
			</tr>
			</table>
		</td>
	</tr>	
</c:if>
