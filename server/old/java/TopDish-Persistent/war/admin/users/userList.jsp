<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:if test="${not empty requestScope.displayList}">
			
	<c:set var="rowClass" value="row-even"/>
	
	<c:forEach items="${requestScope.displayList}" var="user">
		<c:choose>
		<c:when test="${rowClass eq 'row-odd' }"><c:set var="rowClass" value="row-even"/></c:when>
		<c:when test="${rowClass eq 'row-even' }"><c:set var="rowClass" value="row-odd"/></c:when>
		</c:choose>
		
		<tr class="${rowClass}">
			<td>${user.key.id}</td>
			<td>${user.nickname}</td>
			<td>${user.userObj}</td>
			<td>${user.numReviews}</td>
			<td>${user.numDishes}</td>
			<td>${user.numRestaurants}</td>
			<td nowrap="nowrap">
				<c:choose>
					<c:when test="${user.role eq 0}">
						<c:set var="stdSel" value="selected=\"selected\""/>
						<c:set var="advSel" value=""/>
					</c:when>
					<c:when test="${user.role eq 1}">
						<c:set var="advSel" value="selected=\"selected\""/>
						<c:set var="stdSel" value=""/>
					</c:when>
					<c:when test="${user.role eq 2}">
						<c:set var="admSel" value="selected=\"selected\""/>
						<c:set var="stdSel" value=""/>
						<c:set var="advSel" value=""/>
					</c:when>
				</c:choose>
				<div style="float: left;">
				<select id="roleChange${user.key.id}" class="roleChangeSelection" onclick="javascript:setOldRoleValue(this.value);" onchange="javascript:changeUserRole(${user.key.id});">
					<option value="Standard" ${stdSel}>Standard</option>
					<option value="Advanced" ${advSel}>Advanced</option>
					<c:if test="${user.role eq 2}">
						<option value="Administrator" ${admSel}>Administrator</option>
					</c:if>
				</select>
				</div>
				<div style="float: right;">
				<img src="/img/admin/processing.gif" border="0" style="display: none;" id="processingImg${user.key.id}"/>
				<img src="/img/admin/done.png" border="0" style="display: none;" id="doneImg${user.key.id}"/>
				</div>
			</td>
		</tr>
	</c:forEach>
</c:if>

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
						<a href="#" onclick="javascript:showPage(${pageNo - 1})">[Prev]</a> &nbsp;&nbsp;
					</c:if>
				</td>
				<td width="33%" style="text-align: center;" class="pagingRecordCount">
					${listSize} records found
					<%--Page: ${pageNo} of <fmt:formatNumber type="number" maxFractionDigits="0" value="${noOfPages}" />
					<c:if test="${noOfPages gt 1}">
						&nbsp;&nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;&nbsp;Goto Page: <input type="text" id="txtGoto" value="" class="edit-txt" size="2" maxlength="3" /><input type="button" class="btn" onclick="javascript:gotoPage();" value="Go"/>
					</c:if>--%>
				</td>
				<td width="33%" style="text-align: right;">
					<c:if test="${pageNo lt noOfPages}">
						<a href="#" onclick="javascript:showPage(${pageNo + 1})">[Next]</a>
					</c:if>
				</td>
			</tr>
			</table>
		</td>
	</tr>	
</c:if>
