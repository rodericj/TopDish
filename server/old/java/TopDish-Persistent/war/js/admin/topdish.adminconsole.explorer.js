

function showData()
{
  $(".dtable").show();
}
//dishId='';
function showEditContent(id,type,mesg)
{
	var reqData="",reqUrl="";
	if(type=="DISH")
		{
			reqData="dishID="+id;
			reqUrl="../../admin/explorer/dish.jsp";
		}
	else if(type=="REST")
	{
		reqData="restID="+id;
		reqUrl="../../admin/explorer/restaurant.jsp";
	}
	else if(type=="TAG")
	{
		reqData="tagID="+id;
		reqUrl="../../admin/explorer/tag.jsp";
	}
	else if(type=="REV")
	{
		reqData="reviewID="+id;
		reqUrl="../../admin/explorer/review.jsp";
	}
	$("#editCont").html("<img src='/img/admin/loading.gif'/>");
	$.ajax({
		type: "POST",
		url: reqUrl,
		data: reqData,
		dataType:"html",
		cache: false,
		success: function(response, status, xhr){
			$("#editCont").html('');
			$("#editCont").show();
			$("#editCont").html(response);
			if(mesg!='' && mesg!=null)
				$("#messageId").html(mesg);
		}
	});
}





function deleteDish(dishId)
{
	var onepage=false;
	var path='';
	var hrefPath=window.location.href;
	if($("#searchLink").length>0)
		{
			if($("#searchLink").html().length>0){
				onepage=true;
				path=hrefPath.substring(0,hrefPath.indexOf("/admin/topDishExplorer"))+"/admin/explorer/dishExplorer.jsp?restID="+$("#restWDId").val()+"+&action="+$("#action").val()+"&dishName="+$("#dishName_id").val();
			}
		}
	var pathname = window.location.href;
	var answer = confirm(" Are you sure you want to delete? Click on OK if yes.");
	if (answer){
		var pathname = window.location.pathname;
		
		
		//alert('a:'+${fn:length(disList)});
		$.ajax({
			type: "POST",
			url: "/deleteDish",
			data: "dishID="+dishId+"&callType=AJAX",
			dataType:"html",
			cache: false,
			success: function(response, status, xhr){
				$("#editCont").html('');
				$("#editCont").show();
				if(onepage)
				{
					window.location.href=path;
				 //alert('Refresh the page to view the list with the deleted record');
				}
			else
				{
					window.location.reload();
				}
			}
		});
	}
}

function deleteRest(restID)
{
	var onepage=false;
	var path='';
	var hrefPath=window.location.href;
	if($("#searchLink").length>0)
		{
			if($("#searchLink").html().length>0){
				onepage=true;
				path=hrefPath.substring(0,hrefPath.indexOf("/admin/topDishExplorer"))+"/admin/explorer/restaurantExplorer.jsp?restName="+$("#restName_id").val()+"+&action="+$("#action").val();
			}
		}
	var pathname = window.location.href;
	var answer = confirm(" Are you sure you want to delete? Click on OK if yes.");
	if (answer){
		var pathname = window.location.pathname;
		
		
		$.ajax({
			type: "POST",
			url: "/deleteRestaurant",
			data: "restID="+restID+"&callType=AJAX",
			dataType:"xml",
			cache: false,
			success: function(response, status, xhr){
				$("#editCont").html('');
				$("#editCont").show();
				if(onepage)
				{
					window.location.href=path;
					//alert('Refresh the page to view the list with the deleted record');
				}
			else
				{
					window.location.reload();
				}
			}
		});
	}
}



function deleteTags(tagID)
{
	var pathname = window.location.href;
	var onepage=false;
	var path='';
	var hrefPath=window.location.href;
	if($("#searchLink").length>0)
	{
		if($("#searchLink").html().length>0){
			onepage=true;
			path=hrefPath.substring(0,hrefPath.indexOf("/admin/topDishExplorer"))+"/admin/explorer/tagExplorer.jsp?tagName="+$("#tagName_id").val()+"+&type="+$("#typeId").val();
		}	
	}
	var answer = confirm(" Are you sure you want to delete? Click on OK if yes.");
	if (answer){
		var pathname = window.location.pathname;
		
		
		//alert('a:'+${fn:length(disList)});
		$.ajax({
			type: "POST",
			url: "/deleteTag",
			data: "tagID="+tagID+"&callType=AJAX",
			dataType:"xml",
			cache: false,
			success: function(xml){
				$("#editCont").html('');
				$("#editCont").show();
				if(onepage)
				{
					window.location.href=path;
				 //alert('Refresh the page to view the list with the deleted record');
				}
			else
				{
					window.location.reload();
				}
			}
		});
	}
}


function deleteReview(reviewID)
{
	var onepage=false;
	var path='';
	var hrefPath=window.location.href;
	if($("#searchLink").length>0)
		{
		if($("#searchLink").html().length>0){
			onepage=true;
			path=hrefPath.substring(0,hrefPath.indexOf("/admin/topDishExplorer"))+"/admin/explorer/reviewExplorer.jsp?dishID="+$("#dishWDId").val()+"+&action="+$("#action").val()+"+&creatorName="+$("#creatorName_id").val();
		}
		}
	
	
	
	var answer = confirm(" Are you sure you want to delete? Click on OK if yes.");
	if (answer){
		$.ajax({
			type: "POST",
			url: "/deleteReview",
			data: "reviewID="+reviewID+"&callType=AJAX",
			dataType:"xml",
			cache: false,
			success: function(xml){
				$("#editCont").html('');
				$("#editCont").show();
				
				if(onepage)
					{
						window.location.href=path;
					// alert('Refresh the page to view the list with the deleted record');
					}
				else
					{
						window.location.reload();
					}
				
			}
		});
	}
	
}



$(document).ready(function(){
	$("#action").val("S");
});



