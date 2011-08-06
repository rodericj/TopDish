$(document).ready(function(){
	/*
	 * Dish Photo Deletion Confirmation
	 */
	$("#delete-photo-dialog").dialog({
		autoOpen: false,
		closeOnEscape: true,
		modal: true,
		resizable: false,
		draggable:false,
		buttons: {
			Cancel: function(){
				$(this).dialog("close");
			},
			"OK": function(){
				$("#delete-photo-form").submit();
			},
		}
	});
	
	$("#delete-photo-button").click(function(){
		$("#delete-photo-dialog").dialog("open");
		return false;
	});
	
	
	/*
	 * Dish Deletion Confirmation
	 */
	$("#delete-dish-dialog").dialog({
		autoOpen: false,
		modal: true,
		resizable: false,
		draggable: false,
		modal:true,
		buttons: {
			Cancel: function(){
				$(this).dialog("close");
			},
			"OK": function(){
				$("#delete-dish-form").submit();
			},
		}
	});
	
	$("#delete-dish-button").click(function(){
		$("#delete-dish-dialog").dialog("open");
		return false;
	});	
});