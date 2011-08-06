var sortOrderGlobalVar = 'asc';
var oldRoleValue = '';

function showRoleBasedUser(){
	document.getElementById('namesearch').value='';
	var selectedRole = document.getElementById('userType').value;
	if(selectedRole!='-'){
		$("#userList").html('<tr><td colspan="7" align="center"><img src="/img/admin/loading.gif"/></td></tr>')
	
		jQuery.ajax({
			type: "POST",
			url: "/admin/users",
			data: "action=show&userType="+selectedRole,
			dataType:"html",
			cache: false,
			success: function(response){
				$("#userList").html(response);
			},
			error: function(xhr, textStatus, thrownError){
			}
		});
	}
}

function gotoPage(){
	var pgNo = document.getElementById('txtGoto').value;
	if(pgNo>0){
		showPage(pgNo);
	}
}

/*
 * Funtion used for pagination - gets and displays page data
 */
function showPage(pageNo){
	$("#userList").html('<tr><td colspan="7" align="center"><img src="/img/admin/loading.gif"/></td></tr>');
	
	jQuery.ajax({
		type: "POST",
		url: "/admin/users",
		data: "action=goto&pg="+pageNo,
		dataType:"html",
		cache: false,
		success: function(response){
			$("#userList").html(response);
		},
		error: function(xhr, textStatus, thrownError){
		}
	});
}

function sort(col){
	$("#userList").html('<tr><td colspan="7" align="center"><img src="/img/admin/loading.gif"/></td></tr>');
	if(sortOrderGlobalVar=='asc')
		sortOrderGlobalVar = 'desc';
	else
		sortOrderGlobalVar = 'asc';
	
	jQuery.ajax({
		type: "POST",
		url: "/admin/users",
		data: "action=sort&col="+col+"&ord="+sortOrderGlobalVar,
		dataType:"html",
		cache: false,
		success: function(response){
			$("#userList").html(response);
		},
		error: function(xhr, textStatus, thrownError){
		}
	});
}
function changeUserRole(id){
	if(confirm('Are you sure you want to change this user\'s role from \''+oldRoleValue+'\' to \''+document.getElementById('roleChange'+id).value+'\'')){
		document.getElementById('processingImg'+id).style.display='block';
		jQuery.ajax({
			type: "POST",
			url: "/admin/users",
			data: "action=changeRole&id="+id+"&role="+document.getElementById('roleChange'+id).value,
			dataType:"html",
			cache: false,
			success: function(response){
				document.getElementById('processingImg'+id).style.display='none';
				document.getElementById('doneImg'+id).style.display='block';
			},
			error: function(xhr, textStatus, thrownError){
			}
		});
	}
	else{	
		document.getElementById('roleChange'+id).value=oldRoleValue;
	}
	
}
function setOldRoleValue(val){
	oldRoleValue = val;
}

function search(searchBy){
	document.getElementById('userType').value='-';
	if(searchBy == 'username'){
		var searchKeyword = document.getElementById('namesearch').value;
		if(searchKeyword.length > 0){
			$("#userList").html('<tr><td colspan="7" align="center"><img src="/img/admin/loading.gif"/></td></tr>');
			
			jQuery.ajax({
				type: "POST",
				url: "/admin/users",
				data: "action=search&searchby=username&keyword="+searchKeyword,
				dataType:"html",
				cache: false,
				success: function(response){
					$("#userList").html(response);
				},
				error: function(xhr, textStatus, thrownError){
				}
			});
		}
	}
}