$(function() {
	var lat = $.cookie('lat');
	var lng = $.cookie('lng');
	var dbresult = false;
	
	if($("#rest_name1").length){
		if($("#rest_name1").val().length == 0){
			$("#dish_name1").attr('disabled', true);
		}else{
			$("#rest_name1").attr('disabled', true);
		}
		$("#rest_name1").focus();
	}
	
	$("#rest_name1").autocomplete('/restaurantAutoComplete?lat=' + lat + "&lng=" + lng, {
		multiple: false,
		dataType: 'json',
		parse: function(data) 
		{
			return $.map(data, function(row) 
			{
				return {
					data: row,
					value: row.name,
					result: row.name
				}
			});
		},
		formatItem: function(rest) {
			if(rest.gid){
				if(rest.addressLine1 != "")
					return rest.name + "\n(" + rest.addressLine1 + ", " + rest.city + ")";
				else
					return rest.name;
			}
			else {
				if(rest.addressLine1 != "")
					return rest.name + "\n(" + rest.address1 + ", " + rest.city + ") <img src='"+ rest.rating_img_url_small +"' alt='YELP RATING' />";
				else
					return rest.name + "<img src='"+ rest.rating_img_url_small +"' alt='YELP RATING' />";
			}
		},
	}).result(function(e, rest) {
		if(!rest.gid){	
			$("#is_yelp1").val("true");

			//update restaurant info below search box
			$("#rest_ac_dishes").hide();
			$("#rest_finder").hide();
			$("#rest_ac_address").html(rest.address1 + ', ' + rest.city + ', ' + rest.state);
			$("#dish_name1").attr('disabled', false);
			
			//set the hidden fields so that we can use them to add the restaurant
			$("#yelp_name1").val(rest.name);
			$("#yelp_id1").val(rest.id);
			$("#yelp_address1a").val(rest.address1);
			$("#yelp_address2a").val(rest.address2);
			$("#yelp_city1").val(rest.city);
			$("#yelp_state1").val(rest.state);
			$("#yelp_latitude1").val(rest.latitude);
			$("#yelp_longitude1").val(rest.longitude);
			$("#yelp_phone1").val(rest.phone);
			$("#yelp_url1").val(rest.url);

			$("#dish_name1").focus();
			return false;
		}else{
			$("#rest_id1").val(rest.key.id);
			$("#dish_name1").attr('disabled', false);
			
			//update restaurant info below search box
			$("#rest_ac_address").html(rest.addressLine1 + ', ' + rest.city + ', ' + rest.state);
			$("#rest_ac_dishes").html(rest.numDishes + ' dishes listed');
			$("#rest_finder").hide();
			
			$("#dish_name1").focus();
			
			$("#dish_name1").autocomplete('/dishAutoComplete?restID=' + rest.key.id, {
				multiple: false,
				dataType: 'json',
				parse: function(data){
					return $.map(data, function(row){
						return{
							data: row,
							value: row.name,
							result: row.name
						}
					});
				},
				formatItem: function(dish){
					return dish.name;
				}
			}).result(function(e, dish){
				$("#dish_id1").val(dish.key.id);
				$("#description1").val(dish.description);
				$("#description1").attr('disabled', true);
				$("#like_radio").focus();
				$("#price_id1").val(dish.price.id);
				$("#category_id1").val(dish.category.id);
				$("#price_id1").attr('disabled', true);
				$("#category_id1").attr('disabled', true);
			});
		}
	});
	
	$("#rest_name1").blur(function(){
		if($("#rest_name1").val().length == 0){
			$("#dish_name1").attr('disabled', true);
			$("#rest_ac_address").html("");
		    $("#rest_ac_dishes").html("");
		    $("#rest_ac_photos").html("");
		    $("#rest_finder").show();
		    $("#rest_name1").focus();
        }
	});
	
	$("#dish_name1").blur(function(){
		if($("#dish_name1").val().length == 0){
			$("#dish_id1").val("");
			$("#price_id1").attr('disabled', false);
			$("#price_id1 option:eq(0)").attr('selected', 'selected');
			$("#category_id1").attr('disabled', false);
			$("#category_id1 option:eq(0)").attr('selected', 'selected');
			$("#description1").attr('disabled', false);
			$("#description1").val("");
		}
	});
	
	$("#tag_parent").autocomplete('/tagAutoComplete', {
		multiple: false,
		dataType: 'json',
		parse: function(data) {
			return $.map(data, function(row) {
				return {
					data: row,
					value: row.name,
					result: row.name
				}
			});
		},
		formatItem: function(item) {
			return getTagName(item);
		}
	}).result(function(e, item) {
		$("#tag_parent_id").val(getTagID(item));
	});
	
	$("#rest_name").val("Find the Restaurant");
	
	$("#tag_parent").bind("change", function(e){
		if($("#tag_parent").val() == ''){
			$("#tag_parent_id").val('');
		}
	});
});