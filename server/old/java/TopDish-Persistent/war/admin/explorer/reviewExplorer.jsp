<html>
<head>
<%@include file="/includes/userTagIncludes.jsp" %>
<%@page import="com.topdish.adminconsole.TopDishConstants"%>
<link href="../../style/admin/topdish-adminconsole-explorer.css" media="screen" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../../js/jquery-1.4.2.min.js"> </script>
<script type="text/javascript" src="../../js/jquery-ui-1.8.1.custom.min.js"></script>
<script type="text/javascript" src="../../js/admin/topdish.adminconsole.explorer.js"></script>
<link href="../../style/admin/topdish-adminconsole-textboxList.css" media="screen" rel="stylesheet" type="text/css" />
<link href="../../style/displaytag.css" media="screen" rel="stylesheet" type="text/css" />
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%> 
<%@ page import="com.topdish.jdo.*" %>
</head>
<body>
<div id="header">
	<h1>TopDish Explorer</h1>
	<ul border="1">
		<li ><a href="../../admin/explorer/restaurantExplorer.jsp">Restaurants</a></li>
		<li ><a href="../../admin/explorer/dishExplorer.jsp" >Dishes</a></li>
		<li class="selected">Reviews</li>
		<li ><a href="../../admin/explorer/tagExplorer.jsp" >Tags</a></li>
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
							  String creatorName="",type="",dishID="";
								int typeInt=-1;

                              try{
                            	 // dishName = (String)request.getSession().getAttribute("dishName");
                            	 
                            	  dishID = (String)request.getParameter("dishID");
                            	  String action=(String)request.getParameter("action");

                            	  if(action!=null && !action.equals(TopDishConstants.ACTION_DISHREVIEWS) && !action.equals(TopDishConstants.ACTION_VIEWREVIEW) )
                            		  dishID=null;
                            	  if(null==dishID || (null!=dishID && dishID.length()==0))
		                            {
                            		  
                            		  if(null==action || (!action.equals(TopDishConstants.ACTION_DISHREVIEWS) && !action.equals(TopDishConstants.ACTION_VIEWREVIEW)))
                            		  {
	                             		  creatorName = (String)request.getParameter("creatorName");
										  if(null == creatorName || creatorName.equalsIgnoreCase("null")) {
											  creatorName = "";
											  request.getSession(true).removeAttribute("reviewList");
										  }
                            		  }
									  
		                            }
                            	  if(action.equals(TopDishConstants.ACTION_VIEWREVIEW))
	                          		{
                            		  dishID="";
	                          		}
							  
                              }
                              catch(Exception e)
                              {
                            	 // toShow="";
                            	  //callType="search";
                              }
							  %>
				<td>Creator <input name="creatorName" type="text" value="<%= creatorName%>" id="creatorName_id"/> <input type="submit" value="Search" onclick="showData();" class="submitButton" /></td>
				<td><input type="hidden" name="callType" id="callType" value="<%= TopDishConstants.CALL_TYPE_NONAJAX %>" id="callType"/></td><td><input type="hidden" name="action" id="action" value="${ACTION_SEARCH}"/></td>
				<td><input type="hidden" name="entity" value="<%= TopDishConstants.ENTITY_REVIEWS %>"/><input type="hidden" id="dishWDId"  name="dishID" value="<%=dishID %>"/></td>
				
			</tr>
		</tbody>
	</table>
</form>
</div>
<div id="tableDiv">

<table  >
<c:set var="displaySize" value="${sessionScope.displaySize}"/>
<display:table id="review" name="${reviewList}" pagesize="${displaySize}"  
     export="true" sort="list"  class="dtable" >  
     <c:set var="reviewID" value="${review.key.id}"/>
     <display:column  title="Dish Name"  
         sortable="true" headerClass="sortable" sortProperty="dishName">
         <div id="dishName${reviewID}">${review.dishName} </div>
         </display:column>

     <display:column  title="Direction"  
         sortable="true" headerClass="sortable" sortProperty="direction"> 
         <div id="direction${reviewID}">${review.direction} </div>
         </display:column> 

     <display:column  title="Comment"  
         sortable="true" headerClass="sortable" sortProperty="comment"> 
         <div id="comment${reviewID}">${review.comment} </div>
         </display:column> 
         
   <display:column  title="Creator"  
         sortable="true" headerClass="sortable" sortProperty="creatorName"> 
         <div id="creatorName${reviewID}">${review.creatorName} </div>
         </display:column> 
         
   <display:column  title="Created Date"  
         sortable="true" headerClass="sortable" sortProperty="dateCreated"> 
         <div id="dateCreated${reviewID}"><fmt:formatDate pattern="dd-MMM-yyyy" value="${review.dateCreated}" /> </div>
         </display:column> 
         
    
	<display:column title="Action"   
         headerClass="sortable" ><a href="#" onclick="javascript:showEditContent('${reviewID}','<%= TopDishConstants.ENTITY_REVIEWS %>',null);" >[view]</a> <a href="#" onclick="javascript:deleteEntity('review', '${reviewID}')">[delete]</a>
     </display:column>
 </display:table>

	
</table>
</div>
</div>

<div id="editCont" class="col2">

</div><!-- editCont -->

</body>
</html>