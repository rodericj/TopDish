$(function() {
	$("#welcome_dialog").dialog({
		autoOpen: false,
		height: 'auto',
		width: '500',
		position: 'center',
		closeOnEscape: false,
		modal: true,
		resizable: false,
		draggable: false,
		dialogClass: 'welcome_dialog_jq',
		title: 'Welcome to TopDish!',
		buttons: {
			"Join TopDish": function() {
				$( this ).dialog( "close" );
				$("#welcome_choose_path").dialog("open");
			},
			Cancel: function() {
				window.location = 'index.jsp';
				$( this ).dialog( "close" );
			}
		}
	});
	
	$("#welcome_choose_path").dialog({
		autoOpen: false,
		height: 'auto',
		width: '500',
		position: 'center',
		closeOnEscape: false,
		modal: true,
		resizable: false,
		draggable: false,
		dialogClass: 'welcome_dialog_jq',
		title: 'Get started:',
		buttons: {
			"Personalize my Profile" : function() {
				$("#welcome_form input[name=redirect]").val("editProfile.jsp");
				$("#welcome_form").submit();
				$(this).dialog("close");
			},
			"Start using TopDish" : function() {
				$("#welcome_form input[name=redirect]").val("index.jsp");
				$("#welcome_form").submit();
				$(this).dialog("close");
			},
			"See a TopDish Tutorial Video" : function() {
				$("#welcome_form input[name=redirect]").val("howTo.jsp");
				$("#welcome_form").submit();
				$(this).dialog("close");
			}
		}
	});
});