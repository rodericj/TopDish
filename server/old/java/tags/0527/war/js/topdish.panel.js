$(document).ready(function()
{
	$("#submitadish_main_panel").slideUp(0);	
	$("div.contextBox").hide();
	$("#category_id").val("");
	$("#price_id").val("");
	$("#dish_name").attr('disabled', true);
	$("#describe").attr('disabled', true);
	
	$("#dish_name").keyup(function()
	{
		if($(this).val() == "")
		{
			enableDropdowns();
			$("#dish_id").val("");
			$("#describe").val($("#describe").attr("placeholder"));
			$("#describe").attr('disabled', true);
		}else{
			$("#describe").attr('disabled', false);
		}
	});
	
	$("#rest_name").keyup(function()
	{
		if($(this).val() == "")
		{
			$("#dish_name").attr('disabled', true);
		}
	});
	
	$("span.submitadish_close").click(function()
	{
		$("#submitadish_main_panel").slideUp(500);
		$("div.header").animate({height: "162px"}, 500);
	});

	$("input.text").each(function()
	{
		$(this).val($(this).attr("placeholder"));
	});
	
	$("input.text").focus(function()
	{
		if($(this).val() == $(this).attr("placeholder")) $(this).val("");
	});
	
	$("input.text").blur(function()
	{
		if($(this).val() == "") $(this).val($(this).attr("placeholder"));
	});
	
	$(".textbox").each(function()
	{
		$(this).val($(this).attr("placeholder"));
	});
			
	$(".textbox").focus(function()
	{
		if($(this).val() == $(this).attr("placeholder")) $(this).val("");
	});
			
	$(".textbox").blur(function()
	{
		if($(this).val() == "")
		{
			$(this).val($(this).attr("placeholder"));
			$(this).prev().html("240");
		}
	});
	
	$(".textbox").keyup(function()
	{
		value = $(this).val().toString().length;
		$(this).prev().html(240 - value);
		
		if(value > 240)
		{
			doPanelError($(this).prev(), "");
		}
		else
		{
			removePanelError($(this).prev());
		}
	});
	
	$("#submit_panel").click(function()
	{
		$("div.header").animate({height: "479px"}, 500);
		$("#submitadish_main_panel").slideDown(500);
		return false;
	});
	
	$(".fakeRadio").click(function()
	{
		if($(this).attr("id") == "ratingYes")
		{
			$("#ratingYes").attr("src", "/img/panel/submitadish_yes.png");
			$("#ratingNo").attr("src", "/img/panel/submitadish_no.png");
			$("#dishRating").val("1");
		}
		else
		{
			$("#ratingYes").attr("src", "/img/panel/submitadish_no.png");
			$("#ratingNo").attr("src", "/img/panel/submitadish_yes.png");
			$("#dishRating").val("-1");
		}
	});
	
	$(".fakeDropDown").click(function()
	{
		if($(this).hasClass("down")){
			$(this).find(".contextBox").slideUp(200);
			$(this).removeClass("down");
		}else{
			$(this).find(".contextBox").slideDown(200);
			$(this).addClass("down");
		}
	});
	
	$(".contextBox ul li").click(function()
	{
		$(this).parent().find("li.selected").each(function()
		{
			$(this).removeClass("selected");
		});
		
		if($(this).parent().parent().parent().attr("id") == "categoryDown")
		{
			$("#category_ID").val($(this).attr("rel"));
		}
		else
		{
			$("#price_ID").val($(this).attr("rel"));
		}
		
		$(this).parent().parent().parent().find("span.fakeDropDownLabel").html($(this).html());
		$(this).addClass("selected");
		$(this).parent().parent().slideUp(200);
	});
	
	$("#submit").click(function()
	{
		if(validatePanel())
		{
			if ($("#describe").val() == $("#describe").attr("placeholder"))
			{
				$("#describe").val("");
			}
			
			if ($("#comments").val() == $("#comments").attr("placeholder"))
			{
				$("#comments").val("");
			}
			
			$("#rateDishForm").submit();
		}
		
		return false;
	});
	
	/*****************************************************************************/
	$("div.upVotePanel .submit").click(function()
	{
		var form = $(this).parent();
		
		if(form.find(".textVote").val() != "")
		{
			form.submit();
		}
		else
		{
			form.find(".textVote").focus();
			form.find(".textVote").addClass("voteError");
		}
		
		return false;
	});
	
	$(".upVotePanel").hide();
	$(".downVotePanel").hide();
	
	$(".activateUp").click(function()
	{
		var dishListing = $(this).parent().parent().parent().parent();
		if(dishListing.prev().css("display") != "none"){
			dishListing.prev().slideUp();
		}else{
			dishListing.prev().slideDown();
		}
		if(dishListing.next().css("display") != "none") dishListing.next().slideUp();
		return false;
	});
	
	$(".activateDown").click(function()
	{
		var dishListing = $(this).parent().parent().parent().parent();
		if(dishListing.next().css("display") != "none"){
			dishListing.next().slideUp();
		}else{
			dishListing.next().slideDown();
		}
		if(dishListing.prev().css("display") != "none") dishListing.prev().slideUp();
		return false;
	});
});

function enableDropdowns()
{
	//Dish Category
	//Select a price
	
	$("#categoryDown").find("span.fakeDropDownLabel").html("Dish Category");
	$("#priceDown").find("span.fakeDropDownLabel").html("Select a price");
	
	$("#categoryDown").find("li.selected").each(function()
	{
		$(this).removeClass("selected");
	});
	
	$("#priceDown").find("li.selected").each(function()
	{
		$(this).removeClass("selected");
	});
	
	$(".fakeDropDown").click(function()
	{
		$(this).unbind("click");
		$(this).find(".contextBox").slideDown(200);
	});
}

function disableDropdowns()
{
	$(".fakeDropDown").each(function()
	{
		$(this).unbind("click");
	});
}

function validatePanel()
{
	var firstErr, result;
	var err = false;
	
	result = ($("#dishRating").val()=="") ? doPanelError($(".fakeRadioLabel"), "'Location' cannot be blank") : removePanelError($(".fakeRadioLabel"));
	(!result && !firstErr) ? firstErr = $("#chooseRating") : "";
	if (!result) err = true;
	
	//check location
	result = ($("#rest_name").val()=="" || $("#rest_name").val() == $("#rest_name").attr("placeholder")) ? doPanelError($("#rest_name"), "'Location' cannot be blank") : removePanelError($("#rest_name"));
	(!result && !firstErr) ? firstErr = $("#rest_name") : "";
	if (!result) err = true;
	
	//check dishname
	result = ($("#dish_name").val()=="" || $("#dish_name").val() == $("#dish_name").attr("placeholder")) ? doPanelError($("#dish_name"), "'Dish Name' cannot be blank") : removePanelError($("#dish_name"));
	(!result && !firstErr) ? firstErr = $("#dish_name") : "";
	if (!result) err = true;
	
	//Check Catagory
	result = ($("#category_ID").val()=="") ? doPanelError($("#categoryDown"), "Please select a 'Category' from the drop down") : removePanelError($("#categoryDown"));
	(!result && !firstErr) ? firstErr = $("#category_ID") : "";
	if (!result) err = true;
	
	//Check Price
	result = ($("#price_ID").val()=="") ? doPanelError($("#priceDown"), "Please select a 'Price' from the drop down") : removePanelError($("#priceDown"));
	(!result && !firstErr) ? firstErr = $("#price_ID") : "";
	if (!result) err = true;
	
	value = $("#describe").val().toString().length;
	result = (value > 240) ? doPanelError($("#describe").prev(), "Too much text") : removePanelError($("#describe").prev());
	(!result && !firstErr) ? firstErr = $("#describe") : "";
	if (!result) err = true;
	
	value = $("#comments").val().toString().length;
	result = (value > 240) ? doPanelError($("#comments").prev(), "Too much text") : removePanelError($("#comments").prev());
	(!result && !firstErr) ? firstErr = $("#comments") : "";
	if (!result) err = true;
	
	if(err)
	{
		firstErr.focus();
		return false;
	}
	else
		return true;
}

function doPanelError(obj, msg)
{
	obj.addClass("panelError");
	
	obj.keydown(function(){removePanelError(obj)});
	obj.click(function(){removePanelError(obj)});
	
	//(!obj.next().hasClass('addDishErrorMsg')) ? obj.after("<div class='addDishErrorMsg'>"+msg+"</div>") : "";
	return false;
}

function removePanelError(obj)
{
	$(this).unbind("keydown", removePanelError);
	$(this).unbind("click", removePanelError);
	
	obj.removeClass("panelError");
	//(obj.next().hasClass('addDishErrorMsg')) ? obj.next().remove() : "";
	return true;
}

/*****************************************************************************/

