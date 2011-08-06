<html>
<head>
<%@include file="/includes/userTagIncludes.jsp" %>
<link href="../../style/admin/topdish-adminconsole-explorer.css" media="screen" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../../js/jquery-1.4.2.min.js"> </script>
<script type="text/javascript" src="../../js/jquery-ui-1.8.1.custom.min.js"></script>
<script type="text/javascript" src="../../js/admin/topdish.adminconsole.explorer.js"></script>
<link href="../../style/admin/topdish-adminconsole-textboxList.css" media="screen" rel="stylesheet" type="text/css" />
<link href="../../style/displaytag.css" media="screen" rel="stylesheet" type="text/css" />
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ page import="com.topdish.adminconsole.TopDishConstants"%> 
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="com.topdish.jdo.Tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

</head>
<body>
<div id="header">
	<h1>TopDish Explorer</h1>
	<ul border="1">
		<li ><a href="../../admin/explorer/restaurantExplorer.jsp">Restaurants</a></li>
		<li ><a href="../../admin/explorer/dishExplorer.jsp" >Dishes</a></li>
		<li ><a href="../../admin/explorer/reviewExplorer.jsp">Reviews</a></li>
		<li class="selected">Tags</li>
	</ul>
	<div id="alert_info" class="alert info"></div>
	<div id="alert_error" class="alert error"></div>
	<div id="ajax_status">
		<img src="/img/progress.gif">
	</div>
</div>
<div id="content">
<div class="searchContent">
<form action="/admin/topDishExplorer" method="POST" id="topDishExplorerId">
	<table>
		<tbody>
			<tr>
			<%
				String tagName="",type="";
				int typeInt=-1;
				try{
					// dishName = (String)request.getSession().getAttribute("dishName");
					tagName = (String)request.getParameter("tagName");
					type = (String)request.getParameter("type");
					if((null == tagName || tagName.equalsIgnoreCase("null")) && (null == type || type.equalsIgnoreCase("null"))) {
						request.getSession(true).removeAttribute("tagList");
					}
					if(null == tagName || tagName.equalsIgnoreCase("null")) {
					tagName = "";
					}
				 
					if(null == type || type.equalsIgnoreCase("null")) {
						type = "";
					}
					else
					{
						typeInt=Integer.parseInt(type);
					}
				} catch(Exception e) {
					// toShow="";
					//callType="search";
				}
			%>
				<td>Tag Name <input name="tagName" type="text" value="<%= tagName%>" id="tagName_id"/></td>
				<td>Type 
					<select name="type" id="typeId">
						<option value="">Select Type</option>
						<option <% if(typeInt == Tag.TYPE_GENERAL) out.print("selected"); %> value="<% out.print(Tag.TYPE_GENERAL); %>">General</option>
						<option <% if(typeInt == Tag.TYPE_CUISINE) out.print("selected"); %> value="<% out.print(Tag.TYPE_CUISINE); %>">Cuisine</option>
						<option <% if(typeInt == Tag.TYPE_LIFESTYLE) out.print("selected"); %> value="<% out.print(Tag.TYPE_LIFESTYLE); %>">Lifestyle</option>
						<option <% if(typeInt == Tag.TYPE_PRICE) out.print("selected"); %> value="<% out.print(Tag.TYPE_PRICE); %>">Price</option>
						<option <% if(typeInt == Tag.TYPE_ALLERGEN) out.print("selected"); %> value="<% out.print(Tag.TYPE_ALLERGEN); %>">Allergen</option>
						<option <% if(typeInt == Tag.TYPE_MEALTYPE) out.print("selected"); %> value="<% out.print(Tag.TYPE_MEALTYPE); %>">Meal Type</option>
						<option <% if(typeInt == Tag.TYPE_INGREDIENT) out.print("selected"); %> value="<% out.print(Tag.TYPE_INGREDIENT); %>">Ingredient</option>
					</select>
				</td>
				
				<td><input type="submit" value="Search" onclick="showData();" class="submitButton" /></td>
				<td><input type="hidden" name="callType" id="callType" value="<%= TopDishConstants.CALL_TYPE_NONAJAX %>" id="callType"/></td><td><input type="hidden" name="action" id="action" value="${ACTION_SEARCH}"/></td>
				<td><input type="hidden" name="entity" value="<%= TopDishConstants.ENTITY_TAGS %>"/></td>
				
			</tr>
		</tbody>
	</table>
</form>
</div>
<div id="tableDiv">

<table  >
<c:set var="displaySize" value="${sessionScope.displaySize}"/>
<display:table id="tag" name="${tagList}" pagesize="${displaySize}"  
     export="true" sort="list"  class="dtable" >  
     <c:set var="tagID" value="${tag.key.id}"/>
     <display:column  title="Name"  
         sortable="true" headerClass="sortable" sortProperty="name">
         <div id="name${tagID}">${tag.name} </div>
         </display:column>

     <display:column title="Description"  
         sortable="true" headerClass="sortable" sortProperty="description"> 
         <div id="description${tagID}">${tag.description} </div>
         </display:column> 
         
     <display:column  title="Type"  
         sortable="true" headerClass="sortable" sortProperty="typeString"> 
         <div id="type${tagID}" >
	         <c:choose>
	         	<c:when test="<%= ((Tag)tag).getType() == Tag.TYPE_CUISINE %>">
	         		Cuisine
	         	</c:when>
	         	<c:when test="<%= ((Tag)tag).getType() == Tag.TYPE_LIFESTYLE %>">
	         		Lifestyle
	         	</c:when>
	         	<c:when test="<%= ((Tag)tag).getType() == Tag.TYPE_PRICE %>">
	         		Price
	         	</c:when>
	         	<c:when test="<%= ((Tag)tag).getType() == Tag.TYPE_ALLERGEN %>">
	         		Allergen
	         	</c:when>
	         	<c:when test="<%= ((Tag)tag).getType() == Tag.TYPE_MEALTYPE %>">
	         		Meal Type
	         	</c:when>
	         	<c:when test="<%= ((Tag)tag).getType() == Tag.TYPE_INGREDIENT %>">
	         		Ingredient
	         	</c:when>
	         	<c:otherwise>
	         		General
	         	</c:otherwise>
	         </c:choose>
         </div>
         </display:column> 
         
   <display:column  title="Creator"  
         sortable="true" headerClass="sortable" sortProperty="creatorName"> 
         <div id="creatorName${tagID}">${tag.creatorName} </div>
         </display:column> 
         
   <display:column  title="Created Date"  
         sortable="true" headerClass="sortable" sortProperty="dateCreated"> 
         <div id="dateCreated${tagID}"><fmt:formatDate pattern="dd-MMM-yyyy" value="${tag.dateCreated}" /></div>
         </display:column> 

		 <display:column title="Action"   
         headerClass="sortable" ><a href="#" onclick="javascript:showEditContent('${tagID}','<%=TopDishConstants.ENTITY_TAGS %>',null)" >[edit]</a> <a href="#" onclick="javascript:deleteEntity('tag', '${tagID}')">[delete]</a>
         </display:column>
 </display:table>
</table>
</div>
</div>

<div id="editCont" class="col2">

</div><!-- editCont -->

</body>
</html>