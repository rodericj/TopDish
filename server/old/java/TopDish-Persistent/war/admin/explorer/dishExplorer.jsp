<%@page import="com.topdish.adminconsole.TopDishConstants"%>
<%@ page import="java.util.List" %>
<%@ page import="com.topdish.jdo.*" %>
<html>
<head>
<%@include file="/includes/userTagIncludes.jsp" %>
<link href="../../style/admin/topdish-adminconsole-explorer.css" media="screen" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../../js/jquery-1.4.2.min.js"> </script>
<script type="text/javascript" src="../../js/jquery-ui-1.8.1.custom.min.js"></script>
<script type="text/javascript" src="../../js/admin/topdish.adminconsole.explorer.js"></script>
<link href="../../style/admin/topdish-adminconsole-textboxList.css" media="screen" rel="stylesheet" type="text/css" />
<link href="../../style/displaytag.css" media="screen" rel="stylesheet" type="text/css" />
</head>
<body >
<div id="header">
	<h1>TopDish Explorer</h1>
	<ul border="1">
		<li ><a href="../../admin/explorer/restaurantExplorer.jsp">Restaurants</a></li>
		<li  class="selected">Dishes</li>
		<li ><a href="../../admin/explorer/reviewExplorer.jsp">Reviews</a></li>
		<li ><a href="../../admin/explorer/tagExplorer.jsp">Tags</a></li>
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
							  String dishName="",dishDescription="",restID="";
								try{
									restID = (String)request.getParameter("restID");
								}
								catch(Exception e)
								{
									System.err.println("null restId");
								}
                              try{
                            	 // dishName = (String)request.getSession().getAttribute("dishName");
                            	 
                            	 String action=(String)request.getParameter("action");

                            		if(action!=null && !action.equals(TopDishConstants.ACTION_RSTRDISHES) && !action.equals(TopDishConstants.ACTION_VIEWDISHES) && !action.equals(TopDishConstants.ACTION_VIEWPHOTO))
                            			restID=null;

		                            if(null==restID || (null!=restID && restID.length()==0))
		                            {
		                            	
			                            if(null==action || (!action.equals(TopDishConstants.ACTION_RSTRDISHES) && !action.equals(TopDishConstants.ACTION_VIEWDISHES) && !action.equals(TopDishConstants.ACTION_VIEWPHOTO)) )
			                            {
			                            	restID="";
			                            	  dishName = (String)request.getParameter("dishName");
										  if(null == dishName || dishName.equalsIgnoreCase("null")) {
											  dishName = "";
											  request.getSession(true).removeAttribute("dishList");
										  }
			                            }
		                            }
                            		if(action.equals(TopDishConstants.ACTION_VIEWDISHES) || action.equals(TopDishConstants.ACTION_VIEWPHOTO))
                            		{
                            			restID="";
                            		}


							  	
                              }
                              catch(Exception e)
                              {
                            	 // toShow="";
                            	  //callType="search";
                              }
							  %>
				<td>Dish Name
					<input name="dishName" type="text" value="<%= dishName %>" id="dishName_id"/>
					<input type="hidden" name="callType" value="<%= TopDishConstants.CALL_TYPE_NONAJAX %>" id="callType"/>
					<input type="hidden" name="action" id="action" value="${ACTION_SEARCH}"/>
					<input type="hidden" name="entity" value="<%= TopDishConstants.ENTITY_DISH %>"/>
					<input type="hidden" id="restWDId"  name="restID" value="<%=restID %>"/>
					<input type="submit" id="submit" value="Search" onclick="showData();" class="submitButton" />
				</td>
			</tr>
		</tbody>
	</table>
</form>
</div>
<div id="tableDiv">
<table>
<c:set var="displaySize" value="${sessionScope.displaySize}"/>
<display:table id="dish" name="${dishList}" pagesize="${displaySize}"  
     export="true" sort="list" class="dtable"  >  
     <c:set var="dishID" value="${dish.key.id}"/>
     <display:column  title="Name"  
         sortable="true" headerClass="sortable" sortProperty="name">
         <div id="name${dishID}">${dish.name} </div>
         </display:column>

     <display:column  title="Description"  
         sortable="true" headerClass="sortable" sortProperty="description"> 
         <div id="description${dishID}">${dish.description} </div>
         </display:column> 
         
     <display:column  title="Restaurant Name"  
         sortable="true" headerClass="sortable" sortProperty="restaurantName"> 
         <div id="restaurantName${dishID}">${dish.restaurantName} </div>
         </display:column> 
     <display:column  title="Tags"  
          headerClass="sortable" > 
         <div id="tagString${dishID}">${dish.tagString} </div>
         </display:column>
             
   <display:column  title="Creator"  
         sortable="true" headerClass="sortable" sortProperty="creatorName"> 
         <div id="creatorName${dishID}">${dish.creatorName} </div>
         </display:column> 
         
     <display:column  title="No of Reviews"  
          headerClass="sortable" sortable="true" sortProperty="totalReviews"> 
         <div id="totalReviews${dishID}">
         <c:choose><c:when test="${dish.totalReviews gt 0}"><a href="/admin/topDishExplorer?action=<%= TopDishConstants.ACTION_DISHREVIEWS %>&dishID=${dishID}">${dish.totalReviews}</a></c:when><c:otherwise>${dish.totalReviews}</c:otherwise></c:choose>
          </div>
        </display:column>
        
		<display:column title="Action" headerClass="sortable" >
         <a href="#" onclick="javascript:showEditContent('${dishID}','<%= TopDishConstants.ENTITY_DISH %>',null)" >[edit]</a>
         <a href="#" onclick="javascript:deleteEntity('dish', '${dishID}')">[delete]</a>
         </display:column>
</display:table>
</table>
</div>
</div>

<div id="editCont" class="col2">

</div><!-- editCont -->

</body>
</html>