<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html>
<head>
<title>Flagging Queue</title>
<link href="/style/admin/topdish-adminconsole-flaggingqueue.css" media="screen" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/js/jquery-1.4.2.min.js"> </script>
<script src="/js/admin/topdish.adminconsole.flaggingqueue.js" language="javascript"> </script>

</head>

<body>
<br>

<c:choose>
	<c:when test="${requestScope.flagFor eq 'dish'}" >
		<c:set var="dishSelected" value="selected=\"selected\""/>
	</c:when>
	<c:when test="${requestScope.flagFor eq 'restaurant'}">
		<c:set var="restaurantSelected" value="selected=\"selected\""/>
	</c:when>
	<c:when test="${requestScope.flagFor eq 'review'}">
		<c:set var="reviewSelected" value="selected=\"selected\""/>
	</c:when>
	<c:when test="${requestScope.flagFor eq 'photo'}">
		<c:set var="photoSelected" value="selected=\"selected\""/>
	</c:when>
	<c:otherwise>
		<c:set var="noneSelected" value="selected=\"selected\""/>
	</c:otherwise>
</c:choose>

<table class="dtable">
	<caption class="table-caption">
		<strong>Flagging Queue </strong>- Select an Item:  
		<select class="select-box" name="flagFor" id="flagFor" onchange="javascript:showFlaggedItems();">
			<option value="-" ${noneSelected}>--Select--</option>
			<option value="dish" ${dishSelected}>Dish</option>
			<option value="restaurant" ${restaurantSelected}>Restaurant</option>
			<option value="review" ${reviewSelected}>Review</option>
			<option value="photo" ${photoSelected}>Photo</option>
		</select>
	</caption>
	<thead>
	<tr id="theader">
		
	</tr>
	</thead>
	<tbody id="flaggedItemTBody">
		
	</tbody>
</table>
<br><br>

<div>
<div  style="width: 66%; float: left; display: none;" id="flagsList">
<table class="dtable" id="flagsTable">
	<caption class="table-caption" id="flagsTableCap"></caption>
	<thead>
		<tr id="flagsTHeader">
			
		</tr>
	</thead>
	<tbody id="flagsTableBody">
		
	</tbody>
</table>
</div>

<div style="width: 33%; float: right; display:none;" id="actionPanel">
<table class="dtable"> 
	<caption class="table-caption"><strong>Take Action</strong></caption>
	<tbody>
		<tr id="flagActionBody">
			
		</tr>
	</tbody>
</table>
</div>
</div>
</body>
</html>