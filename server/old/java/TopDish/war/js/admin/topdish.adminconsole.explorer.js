function showData() {
	$(".dtable").show();
}

function showEditContent(id, type, mesg) {
	var reqData = "", reqUrl = "";

	if (type == "DISH") {
		reqData = "dishID=" + id;
		reqUrl = "../../admin/explorer/dish.jsp";
	} else if (type == "REST") {
		reqData = "restID=" + id;
		reqUrl = "../../admin/explorer/restaurant.jsp";
	} else if (type == "TAG") {
		reqData = "tagID=" + id;
		reqUrl = "../../admin/explorer/tag.jsp";
	} else if (type == "REV") {
		reqData = "reviewID=" + id;
		reqUrl = "../../admin/explorer/review.jsp";
	}

	reqData += "&callType=NAJAX";
	console.log("reqUrl: " + reqUrl);
	console.log("reqData: " + reqData);

	$.ajax({
		type : "POST",
		url : reqUrl,
		data : reqData,
		dataType : "html",
		cache : false,
		success : function(response, status, xhr) {
			$("#editCont").html("");
			$("#editCont").show();
			$("#editCont").html(response);
			$("#alert_info").html("");
		}
	});
}

function deleteEntity(type, id){
	var urlStr = "";
	var dataStr = "";
	
	if(type == "dish"){
		urlStr = "/deleteDish";
		dataStr = "dishID=" + id;
	}else if(type == "restaurant"){
		urlStr = "/deleteRestaurant";
		dataStr = "restID=" + id;
	}else if(type == "tag"){
		urlStr = "/deleteTag";
		dataStr = "tagID=" + id;
	}else if(type == "review"){
		urlStr = "/deleteReview";
		dataStr = "reviewID=" + id;
	}
	dataStr += "&ajax=true";
	
	var answer = confirm("Are you sure you want to delete? Click on OK if yes.");
	if (answer) {
		$.ajax({
			type : "POST",
			url : urlStr,
			data : dataStr,
			dataType : "json",
			cache : false,
			success : function(json) {
				if(json.rc == 0){
					showInfo(json.message);
				}else{
					showError(json.message);
				}
				$("#editCont").html("");
			}
		});
	}
}

function validateTagEditPanel()
{
	var firstErr, result;
	var err = false;
	//check dishname
	result = ($("#name").val()=="" || $("#name").val() == $("#name").attr("placeholder")) ? doPanelError($("#name"), "'Name' cannot be blank") : removePanelError($("#name"));
	(!result && !firstErr) ? firstErr = $("#name") : "";
	if (!result) err = true;
	
	
	if(err)
	{
		firstErr.focus();
		$("#messageId").html(''); 
		return false;
	}
	else
		{
		return true;
		}
		
}

function validateDishEditPanel() {
	var firstErr, result;
	var err = false;
	// check dishname
	result = ($("#dish_name").val() == "" || $("#dish_name").val() == $(
			"#dish_name").attr("placeholder")) ? doPanelError($("#dish_name"),
			"'Dish Name' cannot be blank") : removePanelError($("#dish_name"));
	(!result && !firstErr) ? firstErr = $("#dish_name") : "";
	if (!result)
		err = true;

	// Check Catagory
	result = ($("#category_ID").val() == "") ? doPanelError($("#category_ID"),
			"Please select a 'Category' from the drop down")
			: removePanelError($("#category_ID"));
	(!result && !firstErr) ? firstErr = $("#category_ID") : "";
	if (!result)
		err = true;

	// Check Price
	result = ($("#price_ID").val() == "") ? doPanelError($("#price_ID"),
			"Please select a 'Price' from the drop down")
			: removePanelError($("#price_ID"));
	(!result && !firstErr) ? firstErr = $("#price_ID") : "";
	if (!result)
		err = true;

	value = $("#describe").val().length;
	result = (value > 240) ? doPanelError($("#describe"), "Too much text")
			: removePanelError($("#describe"));
	(!result && !firstErr) ? firstErr = $("#describe") : "";
	if (!result)
		err = true;

	result = (value <= 0) ? doPanelError($("#describe"),
			"'Description' cannot be blank") : removePanelError($("#describe"));
	(!result && !firstErr) ? firstErr = $("#describe") : "";
	if (!result)
		err = true;

	if (err) {
		firstErr.focus();
		$("#messageId").html('');
		return false;
	} else {
		return true;
	}
}

function validateRestaurantEditPanel()
{
	var firstErr, result;
	var err = false;
	//check dishname
	result = ($("#name").val()=="" || $("#name").val() == $("#name").attr("placeholder")) ? doPanelError($("#name"), "'Restaurant Name' cannot be blank") : removePanelError($("#name"));
	(!result && !firstErr) ? firstErr = $("#name") : "";
	if (!result) err = true;
	
	//Check Catagory
	result = ($("#city").val()=="") ? doPanelError($("#city"), "'City' cannot be blank") : removePanelError($("#city"));
	(!result && !firstErr) ? firstErr = $("#category_ID") : "";
	if (!result) err = true;
	
	//Check Price
	result = ($("#state").val()=="") ? doPanelError($("#state"), "'State' cannot be blank") : removePanelError($("#state"));
	(!result && !firstErr) ? firstErr = $("#price_ID") : "";
	if (!result) err = true;
	
	if(err)
	{
		firstErr.focus();
		$("#messageId").html(''); 
		return false;
	}
	else
	{
		return true;
	}
}

function doPanelError(obj, msg) {
	obj.addClass("panelError");
	var addErrMesg = "";
	if (obj.parent().hasClass('detailBox')) {
		(!obj.next().hasClass('addErrorMsg')) ? obj
				.after("<div class='addErrorMsg' style='float:left;margin-left:-60px;' >"
						+ msg + "</div><br/>")
				: "";
	} else {
		(!obj.next().hasClass('addErrorMsg')) ? obj
				.after("<div class='addErrorMsg' >" + msg + "</div>") : "";
	}
	return false;
}

function removePanelError(obj) {
	(obj.next().hasClass('addErrorMsg')) ? obj.next().remove() : "";
	obj.removeClass("panelError");
	return true;
}

$(document).ready(function() {
	$("#action").val("S");

	
	$("#ulPhotoAId").click(function() {
		$("#uploadPhotoDiv").show();
	});

	$("#ajax_status").ajaxStart(function(){
		$(this).show();
	});

	$("#ajax_status").ajaxStop(function(){
		$(this).hide();
	});
	
	$('#updateRestForm').submit(function() {
		console.log("updating restaurant");
		var options = {
			// Set up ajax call params.
			beforeSubmit:  function(){
				//return validateEditPanel();
				return true;
			},
			dataType:"json",
			cache: false,
			success:  function(json){
				//console.log(json);
				var rest = $.parseJSON(json.restaurant);
				//name, address1, address2, city, state
				$("#name" + rest.id).html(decodeURI(rest.name));
				$("#addressLine1" + rest.id).html(decodeURI(rest.addressLine1));
				$("#addressLine2" + rest.id).html(decodeURI(rest.addressLine2));
				$("#city" + rest.id).html(decodeURI(rest.city));
				$("#state" + rest.id).html(decodeURI(rest.state));
				
				//TODO(randy): set success/failure message!
				if(json.rc == 0){
					showInfo(json.message);
				}else{
					showError(json.message);
				}
				$("#editCont").html("");
			}
		};
		// Send update request to server.
	    $(this).ajaxSubmit(options);
	    // Remove edit box.
	    $("#editCont").html("");
	    return false; 
	});
	
	
	$('#updateDishForm').submit(function() {
		// Set up ajax call params.
		var options = {
			beforeSubmit : function() {
				//return validateEditPanel();
				return true;
			},
			dataType : "json",
			cache : false,
			success : function(json) {
				var dish = $.parseJSON(json.dish);
				var tagNames = "";
				//console.log(dish);
				//console.log(dish.tags);
				
				for(i in dish.tags){
					//console.log(dish.tags[i]);
					if(i == 0){
						tagNames += dish.tags[i].name;
					}else{
						tagNames += ", " + dish.tags[i].name;
					}
				}

				$("#name" + dish.id).html(decodeURI(dish.name));
				$("#description" + dish.id).html(dish.description);
				$("#tagString" + dish.id).html(tagNames);
				//TODO(randy): set success/failure message!
				if(json.rc == 0){
					showInfo(json.message);
				}else{
					showError(json.message);
				}
			}
		};
		// Send update request to server.
		$(this).ajaxSubmit(options);
		// Remove edit box.
		$("#editCont").html("");
		return false;
	});
		
	$('#updateTagForm').submit(function() {
		// Set up ajax call params.
		var options = {
			beforeSubmit : function() {
				//return validateEditPanel();
				return true;
			},
			dataType : "json",
			cache : false,
			success : function(json) {
				var tag = $.parseJSON(json.tag);
				console.log(tag);

				$("#name" + tag.id).html(tag.name);
				$("#description" + tag.id).html(tag.description);
				$("#type" + tag.id).html(tag.type);

				if(json.rc == 0){
					showInfo(json.message);
				}else{
					showError(json.message);
				}
			}
		};
		// Send update request to server.
		$(this).ajaxSubmit(options);
		// Remove edit box.
		$("#editCont").html("");
		return false;
	});

	$('.delPhtFrm').submit(function() {
		var photoUploadOptions = {
			beforeSubmit : function() {
				return true;
			},
			dataType : "xml",
			cache : false,
			success : function(xml) {
				var mesg = $(xml).find("mesg").text();
				if (mesg == '')
					mesg = "Photo added successfully!!!";
				showEditContent($('#dish_id').val(), 'DISH', mesg);

				$("#messageId").html($(xml).find("mesg").text());
			}
		};
		
		var answer = confirm(" Are you sure you want to delete? Click on OK if yes.");
		if (answer) {
			$(this).ajaxSubmit(
					photoUploadOptions);
			return false;
		}
		return false;
	});

	$('.rotatFrm').submit(function() {
		$(this).ajaxSubmit(photoUploadOptions);
		return false;
	});

	$("#cancel").click(function() {
		$("#editCont").html('');
	});
});

function showError(msg){
	clearAlerts();
	$("#alert_error").html(msg);
	$("#alert_error").show();
	
	setTimeout(function(){
		$("#alert_error").fadeOut("slow", function () {
			$("#alert_error").hide();
			});
		}, 5000
	);
}

function showInfo(msg){
	clearAlerts();
	$("#alert_info").html(msg);
	$("#alert_info").show();
	
	setTimeout(function(){
		$("#alert_info").fadeOut("slow", function () {
			$("#alert_info").hide();
			});
		}, 5000
	);
}

function clearAlerts(){
	$("#alert_info").html("");
	$("#alert_info").hide();
	
	$("#alert_error").html("");
	$("#alert_error").hide();
}