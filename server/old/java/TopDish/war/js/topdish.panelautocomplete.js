$(function() {
	var lat = $('#user_lat').val();
	var lng = $('#user_lng').val();
	var dbresult = false;
	
	$("#rest_name").autocomplete('/api/restaurantSearch?limit=10&lat=' + lat + "&lng=" + lng, {
		multiple: false,
		dataType: 'json',
		parse: function(data) {
			return $.map(data["restaurants"], function(row) 
			{
				return {
					data: row,
					value: decodeURI(row.name),
					result: decodeURI(row.name)
				}
			});
		},
		formatItem: function(rest) {
			var name = decodeURI(rest.name);
			var address = rest.addressLine1;
			var city = rest.city;
			return name + "<br />"+ address + ", " + city;
		},
	}).result(function(e, rest) {
		$("#rest_id").val(rest.id);
		$("#dish_name").attr('disabled', false);
		$("#dish_name").focus();
				
		$("#dish_name").autocomplete('/dishAutoComplete?restID=' + rest.id, {
			multiple: false,
			dataType: 'json',
			parse: function(data){
				if(data){
					return $.map(data["dishes"], function(row){
						return{
							data: row,
							value: decodeURI(row.name),
							result: decodeURI(row.name)
						}
					});
				}
			},
			formatItem: function(dish){
				return decodeURI(dish.name);
			}
		}).result(function(e, dish)
		{
			console.log(dish.tags);
			$("#dish_id").val(dish.id);
			$("#describe").val(dish.description);
			$("#describe").attr('disabled', true);
			$("#comments").focus();
			
			var category = 0;
			var price = 0;
			
			for(i in dish.tags){
				console.log(dish.tags[i]);
				
				switch(dish.tags[i].type){
				case "Price":
					price = dish.tags[i];
					break;
				case "Meal Type":
					category = dish.tags[i];
					break;
				}
			}
			
			console.log("cateogry: " + category);
			console.log("price: " + price);
			
			var catOpt = $("#categoryDown ul li[rel="+ category.id +"]");
			catOpt.addClass("selected");
			$("#categoryDown").find("span.fakeDropDownLabel").html(catOpt.html());
			
			var priceOpt = $("#priceDown ul li[rel="+ price.id +"]");
			priceOpt.addClass("selected");
			$("#priceDown").find("span.fakeDropDownLabel").html(priceOpt.html());
			
			$("#category_ID").val(catOpt.attr("rel"));
			$("#price_ID").val(priceOpt.attr("rel"));
			
			disableDropdowns();
			removePanelError($("#priceDown"));
			removePanelError($("#categoryDown"));
		});
// }
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