var flagForGlobalVar = '';
var flaggingEntityIdGlobalVar = '';
var columnCountGlobalVar = '';
var sortOrderGlobalVar = 'asc';

function showFlaggedItems(){
	document.getElementById('flagsList').style.display='none';
	document.getElementById('actionPanel').style.display='none';
	
	var flagFor = document.getElementById('flagFor').value;
	var columnCount= 0;
	
	// add table headers
	if(flagFor=='dish'){
		$("#theader").html('<th width="10%">ID</th><th width="60%"><a class="sortHeader" href="#" onclick="javascript:sort(\'dishname\',\'dish\');">Dish Name</a></th><th width="20%">Total Flags</th><th width="10"></th>');
		columnCount=4;
	}
	else if(flagFor=='restaurant'){
		$("#theader").html('<th width="10%">ID</th><th width="60%"><a class="sortHeader" href="#" onclick="javascript:sort(\'restname\',\'restaurant\');">Restaurant Name</a></th><th width="20%">Total Flags</th><th width="10"></th>');
		columnCount=4;
	}
	else if(flagFor=='photo'){
		$("#theader").html('<th width="10%">ID</th><th width="10%">Photo</th><th width="40%">Description</th><th width="15%"><a class="sortHeader" href="#" onclick="javascript:sort(\'creatorname\',\'photo\');">Creator</a></th><th width="15%">Total Flags</th><th></th>');
		columnCount=6;
	}
	else if(flagFor=='review'){
		$("#theader").html('<th width="10%">ID</th><th width="50%">Review</th><th width="20%">Dish Name</th><th width="10%">Total Flags</th><th width="10%"></th>');
		columnCount=5;
	}
	else{
		$("#theader").html('');
	}
	columnCountGlobalVar= columnCount;
	$("#flaggedItemTBody").html('<tr><td colspan="'+columnCount+'" align="center"><img src="/img/admin/loading.gif"/></td></tr>');
	
	jQuery.ajax({
		type: "POST",
		url: "/admin/flags",
		data: "action=showFlaggedItems&flagFor=" + document.getElementById('flagFor').value,
		dataType:"html",
		cache: false,
		success: function(response){
			
		
			// dynamically create the headers for the flagged items table
			
			
			$("#flaggedItemTBody").html(response);
		},
		error: function(xhr, textStatus, thrownError){
		}
	});
}

function showFlagsForSelectedItem(entity, id){
	flagForGlobalVar = entity;
	flaggingEntityIdGlobalVar = id;
	
	document.getElementById('flagsList').style.display='block';
	document.getElementById('actionPanel').style.display='none';
	
	if(entity=='dish'){	
		$("#flagsTableCap").html('<strong>Flags for Dish ID- '+id+'</strong>');
	}
	else if(entity=='restaurant'){
		$("#flagsTableCap").html('<strong>Flags for Restaurant ID- '+id+'</strong>');
	}
	else if(entity=='review'){
		$("#flagsTableCap").html('<strong>Flags for Review ID- '+id+'</strong>');
	}
	else if(entity=='photo'){
		$("#flagsTableCap").html('<strong>Flags for Photo ID- '+id+'</strong>');
	}
	
	$("#flagsTHeader").html('<th width="10%">Flag ID</th><th width="20%">Flag Type</th><th width="50%">Comments</th><th width="15%">User</th><th width="5%"></th>');
	
	$("#flagsTableBody").html('<tr><td colspan="5" align="center"><img src="/img/admin/loading.gif"/></td></tr>');
	
	jQuery.ajax({
		type: "POST",
		url: "/admin/flags",
		data: "action=showFlags&flagFor=" + entity + "&id="+id,
		dataType:"html",
		cache: false,
		success: function(response){
				
			$("#flagsTableBody").html(response);
		},
		error: function(xhr, textStatus, thrownError){
		}
	});
	
}

function showFlagAction(id){
	document.getElementById('actionPanel').style.display='block';
	$("#flagActionBody").html('<tr><td colspan="5" align="center"><img src="/img/admin/loading.gif"/></td></tr>');

	jQuery.ajax({
		type: "POST",
		url: "/admin/flags",
		data: "action=showFlagAction&id="+id,
		dataType:"html",
		cache: false,
		success: function(response){
				
			$("#flagActionBody").html(response);
		},
		error: function(xhr, textStatus, thrownError){
		}
	});
}

function takeFlagAction(id){
	document.getElementById('btnMarkResolved').value='Please wait...';
	document.getElementById('btnMarkResolved').disabled=true;
	
	// mark flag as resolved
	jQuery.ajax({
		type: "POST",
		url: "/admin/flags",
		data: "action=flagMarkAsResolved&id="+id +"&comment="+document.getElementById('adminCommentBox').value,
		dataType:"html",
		cache: false,
		success: function(response){
			// hide the take action panel
			document.getElementById('actionPanel').style.display='none';
			
			//reload the flags panel
			showFlagsForSelectedItem(flagForGlobalVar, flaggingEntityIdGlobalVar);
		},
		error: function(xhr, textStatus, thrownError){
		}
	});
	
	
}

/*
 * Funtion used for pagination - gets and displays page data
 */
function showPage(pageNo,flagFor){
	$("#flaggedItemTBody").html('<tr><td colspan="'+columnCountGlobalVar+'" align="center"><img src="/img/admin/loading.gif"/></td></tr>');
	
	jQuery.ajax({
		type: "POST",
		url: "/admin/flags",
		data: "action=showPage&pg="+pageNo+"&flagFor="+flagFor,
		dataType:"html",
		cache: false,
		success: function(response){
			$("#flaggedItemTBody").html(response);
		},
		error: function(xhr, textStatus, thrownError){
		}
	});
}

function sort(col,flagFor){
	document.getElementById('flagsList').style.display='none';
	document.getElementById('actionPanel').style.display='none';
	
	$("#flaggedItemTBody").html('<tr><td colspan="'+columnCountGlobalVar+'" align="center"><img src="/img/admin/loading.gif"/></td></tr>');
	if(sortOrderGlobalVar=='asc')
		sortOrderGlobalVar = 'desc';
	else
		sortOrderGlobalVar = 'asc';
	
	jQuery.ajax({
		type: "POST",
		url: "/admin/flags",
		data: "action=sort&flagFor="+flagFor+"&col="+col+"&ord="+sortOrderGlobalVar,
		dataType:"html",
		cache: false,
		success: function(response){
			$("#flaggedItemTBody").html(response);
		},
		error: function(xhr, textStatus, thrownError){
		}
	});
}

function gotoPage(flagFor){
	document.getElementById('flagsList').style.display='none';
	document.getElementById('actionPanel').style.display='none';
	
	var pgNo = document.getElementById('txtGoto').value;
	if(pgNo>0){
		showPage(pgNo,flagFor);
	}
}

function showEnlargedImg(id){
	document.getElementById('enlargedImg'+id).style.display='block';
}

function hideEnlargedImg(id) {
	document.getElementById('enlargedImg'+id).style.display='none';
}