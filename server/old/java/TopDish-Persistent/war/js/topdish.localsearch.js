/*
*  How to build a Google Map and bind a SearchControl to it and put markers
*  on the map for each result we receive.
*/

// First, we have to load the APIs.
google.load('maps' , '2');
google.load('search' , '1');

// Global variables we will set in OnLoad
var map;
var searcher;

//////////////
var names;
var addresses;
var cities;
var states;
var phones;
var lats;
var lngs;
var urls;
var gids;
//////////////

function localSearch(lat, lng){
  // Get the content div and clear it's current contents.
  var contentDiv = document.getElementById('content');
  //contentDiv.innerHTML = ''; // Clear any content currently in the Div
  $("#content").empty();

  // Next thing we have to do is build two divs to hold our stuff
  var mapContainer = document.createElement('div'); // build the map div
  mapContainer.id = "map"; //set the div id

  var controlContainer = document.createElement('div'); // build the control div
  controlContainer.id = "control"; //set the control div id

  // Now we have to add these divs to the content div in the document body
  $("#content").append(controlContainer);
  $("#content").append(mapContainer);
//  contentDiv.appendChild(controlContainer);
//  contentDiv.appendChild(mapContainer);

  // We're ready to build our map...
  map = new google.maps.Map2(mapContainer);

  // ...and add a couple of controls.
  map.addControl(new google.maps.SmallMapControl()); // Add a small map control
  //map.addControl(new google.maps.MapTypeControl()); // Add the map type control
 
  //map.setCenter(new google.maps.LatLng(position.coords.latitude, position.coords.longitude));
  
  // We'll wait to the end to actually initialize the map
  // So let's build the search control
  var searchControl = new google.search.SearchControl();

  // Initialize a LocalSearch instance
  searcher = new google.search.LocalSearch(); // create the object
  searcher.setCenterPoint(new google.maps.LatLng(lat, lng)); // start at user location

  // Create a SearcherOptions object to ensure we can see all results
  var options = new google.search.SearcherOptions(); // create the object
  options.setExpandMode(google.search.SearchControl.EXPAND_MODE_OPEN);

  // Add the searcher to the SearchControl
  searchControl.addSearcher(searcher , options);

 // And second, we need is a search complete callback!
  searchControl.setSearchCompleteCallback(searcher , function() {
	  
	////////////////////////////
	    names = new Array();
		addresses = new Array();
		cities = new Array();
		states = new Array();
		phones = new Array();
		lats = new Array();
		lngs = new Array();
		urls = new Array();
		gids = new Array();
  	////////////////////////////
		
    map.clearOverlays();
    var results = searcher.results; // Grab the results array
    // We loop through to get the points
    for (var i = 0; i < results.length; i++) {
      var result = results[i]; // Get the specific result
      var markerLatLng = new google.maps.LatLng(parseFloat(result.lat),
                                                parseFloat(result.lng));
      var marker = new google.maps.Marker(markerLatLng); // Create the marker

      // Bind information for the infoWindow aka the map marker popup
      marker.bindInfoWindow(result.html.cloneNode(true));
      result.marker = marker; // bind the marker to the result
      map.addOverlay(marker); // add the marker to the map
      
      /////////////////
      //console.dir(result);
      skimInfo(result);
      /////////////////
      
    }

    // Store where the map should be centered
    var center = searcher.resultViewport.center;

    // Calculate what the zoom level should be
    var ne = new google.maps.LatLng(searcher.resultViewport.ne.lat,
                                    searcher.resultViewport.ne.lng);
    var sw = new google.maps.LatLng(searcher.resultViewport.sw.lat,
                                    searcher.resultViewport.sw.lng);
    var bounds = new google.maps.LatLngBounds(sw, ne);
    var zoom = map.getBoundsZoomLevel(bounds, new google.maps.Size(300, 300));

    // Set the new center of the map
    // parseFloat converts the lat/lng from a string to a float, which is what
    // the LatLng constructor takes.
    map.setCenter(new google.maps.LatLng(parseFloat(center.lat),
                                         parseFloat(center.lng)),
                                         zoom);
    ///////////////
    addForms();
    ///////////////    
  });
  
  // Draw the control
  searchControl.draw(controlContainer);

  // Set the map's center point and finish!
  //map.setCenter(new google.maps.LatLng(position.coords.latitude, position.coords.longitude));
  
  // Execute an initial search
  searchControl.execute('restaurants');
}

function skimInfo(result){
	names.push(removeHTMLTags(result.title));
	addresses.push(result.streetAddress);
	cities.push(result.city);
	states.push(result.region);
	phones.push(result.phoneNumbers[0].number)
	lats.push(result.lat);
	lngs.push(result.lng);
	urls.push(result.url);
	var start = result.url.indexOf("cid") + 4;
	var end = result.url.length;
	gids.push(result.url.substring(start,end));
}

function addForms(){    	
	var gResults = new Array();
	gResults = $('.gsc-localResult .gsc-result');
	var i = 0;
	gResults.each(function(){
		var formString = "<form action=\"addRestaurantGID\" method=\"POST\">";
		formString += "<input type=\"hidden\" name=\"name\" value=\"" + names[i] + "\"/>";
		formString += "<input type=\"hidden\" name=\"address\" value=\"" + addresses[i] + "\"/>";
		formString += "<input type=\"hidden\" name=\"city\" value=\"" + cities[i] + "\"/>";
    	formString += "<input type=\"hidden\" name=\"state\" value=\"" + states[i] + "\"/>";
    	formString += "<input type=\"hidden\" name=\"phone\" value=\"" + phones[i] + "\"/>";
    	formString += "<input type=\"hidden\" name=\"lat\" value=\"" + lats[i] + "\"/>";
    	formString += "<input type=\"hidden\" name=\"lng\" value=\"" + lngs[i] + "\"/>";
    	formString += "<input type=\"hidden\" name=\"url\" value=\"" + urls[i] + "\"/>";
    	formString += "<input type=\"hidden\" name=\"gid\" value=\"" + gids[i] + "\"/>";
    	formString += "<input type=\"submit\" value=\"Choose This\" />";
    	formString += "</form><br />";
    	$(this).after(formString);
		i++;
	})    	
}

function removeHTMLTags(htmlString){
    if(htmlString){
      var mydiv = document.createElement("div");
       mydiv.innerHTML = htmlString;

        if (document.all) // IE Stuff
        {
            return mydiv.innerText;
           
        }   
        else // Mozilla does not work with innerText
        {
            return mydiv.textContent;
        }                           
  }
}