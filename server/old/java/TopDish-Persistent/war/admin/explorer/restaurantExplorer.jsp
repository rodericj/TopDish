<html>
<head>
<%@include file="/includes/userTagIncludes.jsp"%>
<%@page import="com.topdish.adminconsole.TopDishConstants"%>
<link href="../../style/admin/topdish-adminconsole-explorer.css"
	media="screen" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../../js/jquery-1.4.2.min.js"> </script>
<script type="text/javascript"
	src="../../js/jquery-ui-1.8.1.custom.min.js"></script>
<script type="text/javascript"
	src="../../js/admin/topdish.adminconsole.explorer.js"></script>
<link href="../../style/admin/topdish-adminconsole-textboxList.css"
	media="screen" rel="stylesheet" type="text/css" />
<link href="../../style/displaytag.css" media="screen" rel="stylesheet"
	type="text/css" />
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
</head>
<body>
	<div id="header">
		<h1>TopDish Explorer</h1>
		<ul border="1">
			<li class="selected">Restaurants</li>
			<li><a href="../../admin/explorer/dishExplorer.jsp">Dishes</a>
			</li>
			<li><a href="../../admin/explorer/reviewExplorer.jsp">Reviews</a>
			</li>
			<li><a href="../../admin/explorer/tagExplorer.jsp">Tags</a>
			</li>
		</ul>
		<div id="alert_info" class="alert info"></div>
		<div id="alert_error" class="alert error"></div>
		<div id="ajax_status">
			<img src="/img/progress.gif">
		</div>
	</div>
	<div id="content">
		<div class="searchContent">
			<form action="/admin/topDishExplorer" method="POST"
				id="topDishExplorerId">
				<table>
					<tbody>
						<tr>
							<%
								String restName = "";
								try {
									String action = (String) request.getParameter("action");

									if (action != null && !action.equals(TopDishConstants.ACTION_VIEWRESTAURANT)) {

										// dishName = (String)request.getSession().getAttribute("dishName");
										restName = (String) request.getParameter("restName");
										if (null == restName || restName.equalsIgnoreCase("null")) {
											restName = "";
											request.getSession(true).removeAttribute("restList");
										}
									} else if (null == action) {
										restName = "";
										request.getSession(true).removeAttribute("restList");
									}

								} catch (Exception e) {
									e.printStackTrace();
								}
							%>
							<td>Restaurant Name
							<input name="restName" type="text" value="<%=restName%>" id="restName_id" />
							<input type="hidden" name="callType" value="<%= TopDishConstants.CALL_TYPE_NONAJAX %>" id="callType"/>
							<input type="hidden" name="action" id="action" value="${ACTION_SEARCH}" />
							<input type="hidden" name="entity" value="<%= TopDishConstants.ENTITY_RESTAURANT %>"/>
							<input type="submit" value="Search" onclick="showData();" class="submitButton" />
							</td>
						</tr>
					</tbody>
				</table>
			</form>
		</div>
		<div id="tableDiv">
			<table>
				<c:set var="displaySize" value="${sessionScope.displaySize}" />
				<display:table id="rest" name="${restList}"
					pagesize="${displaySize}" export="true" sort="list" class="dtable">
					<c:set var="restID" value="${rest.key.id}" />
					<display:column title="Restaurant Name" sortable="true"
						headerClass="sortable" sortProperty="name">
						<div id="name${restID}">${rest.name}</div>
					</display:column>

					<display:column title="Address Line 1" sortable="true"
						headerClass="sortable" sortProperty="addressLine1">
						<div id="addressLine1${restID}">${rest.addressLine1}</div>
					</display:column>

					<display:column title="Address Line 2" sortable="true"
						headerClass="sortable" sortProperty="addressLine2">
						<div id="addressLine2${restID}">${rest.addressLine2}</div>
					</display:column>

					<display:column title="City" sortable="true" headerClass="sortable"
						sortProperty="city">
						<div id="city${restID}">${rest.city}</div>
					</display:column>

					<display:column title="State" sortable="true"
						headerClass="sortable" sortProperty="state">
						<div id="state${restID}">${rest.state}</div>
					</display:column>

					<display:column title="No of Dishes" sortable="true"
						headerClass="sortable" sortProperty="numDishes">
						<div id="numDishes${restID}">
							<c:choose>
								<c:when test="${rest.numDishes gt 0}">
									<a
										href="/admin/topDishExplorer?action=<%= TopDishConstants.ACTION_RSTRDISHES %>&restID=${restID}">${rest.numDishes}</a>
								</c:when>
								<c:otherwise>${rest.numDishes}</c:otherwise>
							</c:choose>
						</div>
					</display:column>
					<display:column title="Action" headerClass="sortable">
						<a href="#" onclick="javascript:showEditContent('${restID}','<%= TopDishConstants.ENTITY_RESTAURANT %>',null)">[edit]</a>
						<a href="#" onclick="javascript:deleteEntity('restaurant', '${restID}')">[delete]</a>
					</display:column>
				</display:table>
			</table>
		</div>
	</div>
	<div id="editCont" class="col2"></div>
	<!-- editCont -->
</body>
</html>