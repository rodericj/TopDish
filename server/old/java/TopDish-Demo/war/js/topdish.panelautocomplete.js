$(function() {
	var lat = $.cookie('lat');
	var lng = $.cookie('lng');
	var dbresult = false;
	
	$("#rest_name").autocomplete('/restaurantAutoComplete?lat=' + lat + "&lng=" + lng, {
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
			$("#is_yelp").val("true");

			//update restaurant info below search box
			$("#rest_ac_dishes").hide();
			$("#rest_finder").hide();
			$("#rest_ac_address").html(rest.address1 + ', ' + rest.city + ', ' + rest.state);
			$("#dish_name").attr('disabled', false);
			
			//set the hidden fields so that we can use them to add the restaurant
			$("#yelp_name").val(rest.name);
			$("#yelp_id").val(rest.id);
			$("#yelp_address1").val(rest.address1);
			$("#yelp_address2").val(rest.address2);
			$("#yelp_city").val(rest.city);
			$("#yelp_state").val(rest.state);
			$("#yelp_latitude").val(rest.latitude);
			$("#yelp_longitude").val(rest.longitude);
			$("#yelp_phone").val(rest.phone);
			$("#yelp_url1").val(rest.url);

			$("#dish_name").focus();
			return false;
		}else{
			$("#rest_id").val(rest.key.id);
			$("#dish_name").attr('disabled', false);
			$("#dish_name").focus();
			
			$("#dish_name").autocomplete('/dishAutoComplete?restID=' + rest.key.id, {
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
			}).result(function(e, dish)
			{
				$("#dish_id").val(dish.key.id);
				$("#describe").val(dish.description);
				$("#describe").attr('disabled', true);
				$("#comments").focus();
				
				var catOpt = $("#categoryDown ul li[rel="+ dish.category.id +"]");
				catOpt.addClass("selected");
				$("#categoryDown").find("span.fakeDropDownLabel").html(catOpt.html());
				
				var priceOpt = $("#priceDown ul li[rel="+ dish.price.id +"]");
				priceOpt.addClass("selected");
				$("#priceDown").find("span.fakeDropDownLabel").html(priceOpt.html());
				
				$("#category_ID").val(catOpt.attr("rel"));
				$("#price_ID").val(priceOpt.attr("rel"));
				
				disableDropdowns();
				removePanelError($("#priceDown"));
				removePanelError($("#categoryDown"));
			});
		}
	});
	
	$('#submitdish_tag_list').textboxlist({
		unique: true, 
		bitsOptions:{editable:{addKeys: 188}},
		plugins: {
			autocomplete: {
				queryRemote: true,
				remote: {url: '/tagAutoComplete', param: 'q'},
				minLength: 1,
			}
		}
	});
});