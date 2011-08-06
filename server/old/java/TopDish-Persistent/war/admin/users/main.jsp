<html>
<head>
<title>Users</title>
<link href="/style/admin/topdish-adminconsole-users.css" media="screen" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/js/jquery-1.4.2.min.js"> </script>
<script src="/js/admin/topdish.adminconsole.users.js" language="javascript"> </script>

</head>
<body>
<br>
<c:choose>
	<c:when test="${requestScope.userType eq 'all'}" >
		<c:set var="allSelected" value="selected=\"selected\""/>
	</c:when>
	<c:when test="${requestScope.userType eq 'admin'}" >
		<c:set var="adminSelected" value="selected=\"selected\""/>
	</c:when>
	<c:when test="${requestScope.flagFor eq 'advanced'}">
		<c:set var="advancedSelected" value="selected=\"selected\""/>
	</c:when>
	<c:when test="${requestScope.flagFor eq 'standard'}">
		<c:set var="standardSelected" value="selected=\"selected\""/>
	</c:when>
	<c:otherwise>
		<c:set var="noneSelected" value="selected=\"selected\""/>
	</c:otherwise>
</c:choose>

<div id="usersList">
<table class="dtable">
	<caption class="table-caption">
		<div style="height: 23px;">
		
		<div style="float: left;">
		<strong>Users </strong>-
		<select class="select-box" name="userType" id="userType" onchange="javascript:showRoleBasedUser();">
			<option value="-" ${noneSelected}>--Select--</option>
			<option value="admin" ${adminSelected}>Administrator</option>
			<option value="advanced" ${advancedSelected}>Advanced</option>
			<option value="standard" ${standardSelected}>Standard</option>
			<option value="all" ${allSelected}>All</option>
		</select>
		</div>
		<div style="float: right;">
			Search By Name: <input type="text" id="namesearch" name="namesearch" class="txt" size="25" />
			<input type="button" class="btn" value="Go" onclick="javascript:search('username');"/>
		</div>
		</div>
	</caption>
	<thead id="userListHdr">
		<tr >
			<th title="User ID" width="5%">ID</th>
			<th title="Name of the user" width="20%"><a class="sortHeader" href="#" onclick="javascript:sort('username');">Name</a></th>
			<th title="User's Email ID" width="30%">Email</th>
			<th title="Total no. of reviews submitted by the user" width="10%"><a class="sortHeader" href="#" onclick="javascript:sort('review');">Reviews</a></th>
			<th title="Total no. of dishes submitted by the user" width="10%"><a class="sortHeader" href="#" onclick="javascript:sort('dish');">Dishes</a></th>
			<th title="Total no. of restaurants added by the user" width="10%"><a class="sortHeader" href="#" onclick="javascript:sort('restaurant');">Restaurants</a></th>
			<th title="Role of the user (determins the level of access to various sections of the application)" width="15%">Role</th>
		</tr>
	</thead>
	<tbody id="userList">
		
	</tbody>
</table>
</div>

<br><br>
<div style="display: none;" id="editUser">
<table class="dtable" style="width: 40%;" align="center">
	<caption class="table-caption"><strong>Edit User</strong></caption>
	<thead>
		<tr>
			<th></th>
			<th></th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="lbl"><strong>User ID </strong></td>
			
			<td>564</td>
		</tr>
		<tr>
			<td class="lbl"><strong>Name </strong></td>
			
			<td class="lbl1"><input type="text" size="40" maxlength="70" class="edit-txt" value="Charles"></td>
		</tr>
		<tr>
			<td class="lbl"><strong>Email ID </strong></td>
			
			<td class="lbl1">charles@xyz.com</td>
		</tr>
		<tr>
			<td class="lbl"><strong>Reviews </strong></td>
			
			<td class="lbl1">35</td>
		</tr>
		<tr>
			<td class="lbl"><strong>Dishes </strong></td>
			
			<td class="lbl1">8</td>
		</tr>
		<tr>
			<td class="lbl"><strong>Restaurants </strong></td>
			
			<td class="lbl1">8</td>
		</tr>
		<tr>
			<td class="lbl"><strong>Role </strong></td>
			
			<td class="lbl1"><select class="edit-select-box" name="urole">
					<option value="advanced" selected="selected">Advanced</option>
					<option value="standard">Standard</option>
				</select>
			</td>
		</tr>
		<tr>
			<td class="lbl" colspan="2"></td>
		</tr>
		<tr>
			<td colspan="2">
			<input type="button" value="Cancel" onClick="javascript:document.getElementById('editUser').style.display='none';" class="btn">&nbsp;&nbsp;
			<input type="button" value="Save Changes" onClick="javascript:document.getElementById('editUser').style.display='none';" class="btn">&nbsp;&nbsp;
			</td>
		</tr>
	</tbody>
</table>
</div>


</body>
</html>