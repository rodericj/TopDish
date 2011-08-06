var tdmap = null;
// set default location to civic center, San Francisco
var userLat = "37.78245";
var userLng = "-122.420687";
var bounds = null;
var boundCenterLat = null;
var boundCenterLng = null;
var dialogLoc = null;
var geocoder = null;

function replaceAll(txt, replace, with_this) {
    return txt.replace(new RegExp(replace, 'g'),with_this);
}

function setLocation(lat, lng, city, state) {
	//update page to show current location
	city = replaceAll(city, "\"", "");
	state = replaceAll(state, "\"", "");
    $("#loc").val(city + ", " + state);
    $("#locHidden").val(city + ", " + state);
}

function showAddress(address) {
	geocoder = new google.maps.Geocoder();
	var latlng = null;
	var city = null;
	var state = null;
	var error = false;
	
	geocoder.geocode( {'address': address}, function(results, status) {
	      if (status == google.maps.GeocoderStatus.OK) {
	    	latlng = results[0].geometry.location;
	    	geocoder.geocode({'latLng': latlng}, function(results, status) {
	  	      if (status == google.maps.GeocoderStatus.OK) {
	  	        if (results[1]) {
	  	        	//console.log(results[1]);
	  	        	var add_list = results[1].formatted_address.split(",");
	  	        	
	  	        	//if 4 items, "S.F. Ferry Bldg, San Francisco, CA 94105, USA"
	  	        	//if 3 items, "Danville, CA 94526, USA"
	  	        	if(add_list.length == 4){
	  	        		//discard first and last items
	  	        		add_list = add_list.slice(1,add_list.length-1);
	  	        	}else if(add_list.length == 3){
	  	        		//discard last item only
	  	        		add_list = add_list.slice(0,add_list.length-1);
	  	        	}
	  	        	
	  	        	//console.log(add_list);
	  	        	city = $.trim(add_list[0]);
	  	        	state = $.trim(add_list[1]);
	  	        	state = state.substr(0,2);
	  	        	setLocation(latlng.lat(), latlng.lng(), city, state);
	  	        	
			  	    $.cookie('lat', latlng.lat());
			  	  	$.cookie('lng', latlng.lng());
			  	  	//$.cookie('address', place);
			  	  	$.cookie('city', city);
			  	  	$.cookie('state', state);
			  	  	
			  	  	window.location.reload();
	  	        } else {
	  	          alert("No results found");
	  	        }
	  	      } else {
	  	        alert("Geocoder failed due to: " + status);
	  	      }
	  	    });
	      } else {
	        alert("Geocode was not successful for the following reason: " + status);
	        error = true;
	      }
	});
};


function refreshLocation() {
	userLat = geoplugin_latitude();
	userLng = geoplugin_longitude();
	var city = geoplugin_city();
	var state = geoplugin_region(); 
	var place = city + ", " + state + ", " + geoplugin_countryCode();

	$.cookie('lat', userLat);
	$.cookie('lng', userLng);
	$.cookie('address', place);
	$.cookie('city', city);
	$.cookie('state', state);

	//console.log("cookie set for address, city, and state");
	setLocation(userLat, userLng, city, state);	

	centerMap();
}

function addDishesToMap() {
	if(undefined == tdmap) {
		mapInit();
	}

	if(tdmap){
		//add points to map
		var dishLats = new Array()
		dishLats = $('.dish_lat');
		
		var dishLngs = new Array()
		dishLngs = $('.dish_lng');		
			    
		var dishNames = new Array()
		dishNames = $('.dish_name');
		
		var infoWindowContent = new Array()
		infoWindowContent = $('.map_info_window_content');
		
		var i = 0;
		var infowindow = new google.maps.InfoWindow();	    
		dishNames.each(function() {
			var marker = new google.maps.Marker({
	        	map: tdmap,
	        	title: $(this).text(),
	        	clickable: true,
	        	position: new google.maps.LatLng($(dishLats[i]).text(), $(dishLngs[i]).text())
	    	});
			
			bounds.extend(new google.maps.LatLng($(dishLats[i]).text(), $(dishLngs[i]).text()));
	    	boundCenterLat = bounds.getCenter().lat() + '';
	    	boundCenterLng = bounds.getCenter().lng() + '';
			
			var bubbleContent = $(infoWindowContent[i]).html(); 
			
	    	google.maps.event.addListener(marker, 'click', function() {
	    		infowindow.setContent(bubbleContent);
	    		infowindow.open(tdmap, marker);
			});
			
			i++;
		})
				    
		google.maps.event.addListener(tdmap, "zoom_changed", function() {
			if (tdmap.getZoom() > 17) {
				tdmap.setZoom(17);
			}
		});
		
		centerMap();
	}
}

function centerMap() {
	if(undefined != boundCenterLat && undefined != boundCenterLng) {
		tdmap.setCenter(new google.maps.LatLng(boundCenterLat, boundCenterLng));
		tdmap.fitBounds(bounds);
	} else {
		if(tdmap){
			tdmap.setCenter(new google.maps.LatLng(userLat, userLng));
		}
	}
}

function mapInit() {
	if($("#top_dishes_map").length){
		if(undefined == bounds) {
			bounds = new google.maps.LatLngBounds();
		}
		
		var myOptions = {
			zoom: 11,
		    mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
		    scrollwheel: false,
		    streetViewControl: false,
		    mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		
		tdmap = new google.maps.Map(document.getElementById("top_dishes_map"), myOptions);
    }
}

$(document).ready(function() {
    //firstly, check if location cookies are set
	if($.cookie('lat') && $.cookie('lng') && $.cookie('city') && $.cookie('state')){
		//cookies set, use stored location
		var lat = $.cookie('lat');
		var lng = $.cookie('lng');
		var city = $.cookie('city');
		var state = $.cookie('state');
		userLat = lat;
		userLng = lng;
		//console.log("cookies found, location = " + lat + ", " + lng + " : " + city + ", " + state);
		setLocation(lat,lng,city,state);
		
		if(undefined == tdmap || null == tdmap) {
			mapInit();
		}
	}else{
		mapInit();
		refreshLocation();
	}
	
	centerMap();
	
	addDishesToMap();
});