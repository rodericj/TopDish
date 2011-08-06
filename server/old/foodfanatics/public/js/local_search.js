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
    
    // Second, we set up our function, OnLoad
    function OnLoad() {
      // Get the content div and clear it's current contents.
      var contentDiv = $('content');
      contentDiv.innerHTML = ''; // Clear any content currently in the Div
    
      var controlContainer = document.createElement('div'); // build the control div
      controlContainer.id = "control";
    
      var mapContainer = $('map')
      // Now we have to add these divs to the content div in the document body
      contentDiv.appendChild(controlContainer);
    
      // We're ready to build our map...
      map = new google.maps.Map2(mapContainer);
    
      // ...and add a couple of controls.
      map.addControl(new google.maps.SmallMapControl()); // Add a small map control
      //map.addControl(new google.maps.MapTypeControl()); // Add the map type control
    
      // We'll wait to the end to actually initialize the map
      // So let's build the search control
      var searchControl = new google.search.SearchControl();
    
      // Initialize a LocalSearch instance
      searcher = new google.search.LocalSearch(); // create the object
      searcher.setCenterPoint(map); // bind the searcher to the map
    
      // Create a SearcherOptions object to ensure we can see all results
      var options = new google.search.SearcherOptions(); // create the object
      options.setExpandMode(google.search.SearchControl.EXPAND_MODE_OPEN);
    
      // Add the searcher to the SearchControl
      searchControl.addSearcher(searcher , options);
    
     // And second, we need is a search complete callback!
      searchControl.setSearchCompleteCallback(searcher , function() {
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
          //extractMarkerHTML(result.html.cloneNode(true));
          result.marker = marker; // bind the marker to the result
          map.addOverlay(marker); // add the marker to the map
        }
    
        // Store where the map should be centered
        var center = searcher.resultViewport.center;
    
        // Calculate what the zoom level should be
        var ne = new google.maps.LatLng(searcher.resultViewport.ne.lat,
                                        searcher.resultViewport.ne.lng);
        var sw = new google.maps.LatLng(searcher.resultViewport.sw.lat,
                                        searcher.resultViewport.sw.lng);
        var bounds = new google.maps.LatLngBounds(sw, ne);
        var zoom = map.getBoundsZoomLevel(bounds, new google.maps.Size(350, 350));
    
        // Set the new center of the map
        // parseFloat converts the lat/lng from a string to a float, which is what
        // the LatLng constructor takes.
        map.setCenter(new google.maps.LatLng(parseFloat(center.lat),
                                             parseFloat(center.lng)),
                                             zoom);
        getGIDs();
      });
    
      // Draw the control
      searchControl.draw(controlContainer);
	  
		var user_latlng;
		if(navigator.geolocation) {
		  browserSupportFlag = true;
		  navigator.geolocation.getCurrentPosition(function(position) {
			user_latlng = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);			
		  }, function() {
			//handleNoGeolocation(browserSupportFlag);
		  });
		}
    
      // Set the map's center point and finish!
      map.setCenter(new google.maps.LatLng(user_latlng), 11);
    
     // Execute an initial search
      searchControl.execute('restaurants');
    }

	function getGIDs(){
		//clear debug div
		$('debug').update("");
		
		//pull GIDs out of search results
		var test = $('control').select('div');
		var results = test[3].select('.gs-localResult');
		var br = new Element('br');
		//for each result, check if gid is in DB
			//display "add" button or "select" button
		for(var i = 0; i < results.length; i++){
			var ahref = results[i].select('a.gs-title');
			var url = ahref[0].readAttribute('href');
			var start = url.indexOf("cid") + 4;
			var end = url.length;
			var uid = url.substring(start,end);

			//print urls to debug div
			var span = new Element('span');
			span.update(uid + "<br />");
			$('debug').insert({'bottom':span});
		}
	}
    
    google.setOnLoadCallback(OnLoad);