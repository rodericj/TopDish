// Set default location to Civic Center in San Francisco, CA.
var userLat = "37.78245";
var userLng = "-122.420687";

// Initalize global variables.
var tdmap = null;
var bounds = null;
var boundCenterLat = null;
var boundCenterLng = null;
var dialogLoc = null;
var geocoder = null;

function replaceAll(txt, replace, with_this) {
    return txt.replace(new RegExp(replace, 'g'),with_this);
}

function setLocation(lat, lng, city, state) {
	// Set global vars.
	userLat = lat;
	userLng = lng;
	
	// Update the location provided by TopDish.
	$("#loc").val(city + ", " + state);
    $("#user_lat").val(userLat);
    $("#user_lng").val(userLng);
    
    // TODO(randy): is this still used?
    $("#locHidden").val(city + ", " + state);
}

function refreshLocation() {
	// Get user's location from Google's Javascript API.
	if(google.loader.ClientLocation)
	{
		lat = google.loader.ClientLocation.latitude;
		lng = google.loader.ClientLocation.longitude;
		city = google.loader.ClientLocation.address.city;
		state = google.loader.ClientLocation.address.region;
		
		//Currently unused.
		visitor_country = google.loader.ClientLocation.address.country;
		visitor_countrycode = google.loader.ClientLocation.address.country_code;
		
		// Update location in the search bar.
		setLocation(lat, lng, city, state);	
	}
	
	// Center gMap on the user's location.
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
	// Initialize gMap if not already done so.
	if(undefined == tdmap || null == tdmap) {
		mapInit();
	}
	
	// Refesh user's location data.
	//refreshLocation();
	
	// Center gMap on the user's location.
	centerMap();
	
	// Add dishes from the front page on the gMap.
	addDishesToMap();
});