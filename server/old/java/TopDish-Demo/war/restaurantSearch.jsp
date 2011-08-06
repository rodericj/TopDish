<jsp:include page="header.jsp" />
<div class="colleft">
<%
/*
	Google API Key for topdish1.appspot.com: 
	ABQIAAAAsoBjCec6IhiVrq0OfYiQ4hRanrF-Qy72Ck9MCUApnD3ZiaRFfhRNvZZ5rZTYdNc6hbC70aPTmBu8ZA
	
	Localhost:
	ABQIAAAAsoBjCec6IhiVrq0OfYiQ4hT2yXp_ZAY8_ufC3CFXhHIE1NvwkxR2l8I0Mhf8MZ0xTGIuyITFePLAew
*/
%>
<script type="text/javascript" src="http://www.google.com/uds/api?file=uds.js&amp;v=1.0&amp;key=ABQIAAAAsoBjCec6IhiVrq0OfYiQ4hT2yXp_ZAY8_ufC3CFXhHIE1NvwkxR2l8I0Mhf8MZ0xTGIuyITFePLAew"></script>

     <link href="http://www.google.com/uds/css/gsearch.css" rel="stylesheet" type="text/css"/>
     <script type="text/javascript">
    //<![CDATA[

    // Our global state
    var gLocalSearch;
    var gMap;
    var gInfoWindow;
    var gSelectedResults = [];
    var gCurrentResults = [];
    var gSearchForm;

    // Create our "tiny" marker icon
    var gYellowIcon = new google.maps.MarkerImage(
      "http://labs.google.com/ridefinder/images/mm_20_yellow.png",
      new google.maps.Size(12, 20),
      new google.maps.Point(0, 0),
      new google.maps.Point(6, 20));
    var gRedIcon = new google.maps.MarkerImage(
      "http://labs.google.com/ridefinder/images/mm_20_red.png",
      new google.maps.Size(12, 20),
      new google.maps.Point(0, 0),
      new google.maps.Point(6, 20));
    var gSmallShadow = new google.maps.MarkerImage(
      "http://labs.google.com/ridefinder/images/mm_20_shadow.png",
      new google.maps.Size(22, 20),
      new google.maps.Point(0, 0),
      new google.maps.Point(6, 20));

     // Set up the map and the local searcher.
    function OnLoad() {

      // Initialize the map with default UI.
      gMap = new google.maps.Map(document.getElementById("map"), {
        center: new google.maps.LatLng(userLat, userLng),
        zoom: 13,
	      mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
	      scrollwheel: false,
	      streetViewControl: false,
        mapTypeId: 'roadmap'
      });
      // Create one InfoWindow to open when a marker is clicked.
      gInfoWindow = new google.maps.InfoWindow;
      google.maps.event.addListener(gInfoWindow, 'closeclick', function() {
        unselectMarkers();
      });

      // Initialize the local searcher
      gLocalSearch = new GlocalSearch();
      gLocalSearch.setSearchCompleteCallback(null, OnLocalSearch);
    }

    function unselectMarkers() {
      for (var i = 0; i < gCurrentResults.length; i++) {
        gCurrentResults[i].unselect();
      }
    }

    function doSearch() {
      var query = document.getElementById("queryInput").value;
      gLocalSearch.setCenterPoint(gMap.getCenter());
      gLocalSearch.execute(query);
    }

    // Called when Local Search results are returned, we clear the old
    // results and load the new ones.
    function OnLocalSearch() {
      if (!gLocalSearch.results) return;
      var searchWell = document.getElementById("searchwell");

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
      
      // Clear the map and the old search well
      searchWell.innerHTML = "";
      for (var i = 0; i < gCurrentResults.length; i++) {
        gCurrentResults[i].marker().setMap(null);
      }
      // Close the infowindow
      gInfoWindow.close();

      gCurrentResults = [];
      for (var i = 0; i < gLocalSearch.results.length; i++) {
		/////////////////
      	skimInfo(gLocalSearch.results[i]);
		/////////////////
        gCurrentResults.push(new LocalResult(gLocalSearch.results[i]));
      }

      var attribution = gLocalSearch.getAttribution();
      if (attribution) {
        document.getElementById("searchwell").appendChild(attribution);
      }

      // Move the map to the first result
      var first = gLocalSearch.results[0];
      gMap.setCenter(new google.maps.LatLng(parseFloat(first.lat),
                                            parseFloat(first.lng)));

      ///////////////
      addForms();
      ///////////////    
    }

    function skimInfo(result){
    	names.push(result.titleNoFormatting);
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
    	gResults = $('div.gs-result');
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
        	formString += "<input type=\"submit\" value=\"Add to TopDish!\" />";
        	formString += "</form><br />";
        	$(this).after(formString);
    		i++;
    	})    	
    }
    
    // Cancel the form submission, executing an AJAX Search API search.
    function CaptureForm(searchForm) {
      gLocalSearch.execute(searchForm.input.value);
      return false;
    }

    // A class representing a single Local Search result returned by the
    // Google AJAX Search API.
    function LocalResult(result) {
      var me = this;
      me.result_ = result;
      me.resultNode_ = me.node();
      me.marker_ = me.marker();
      google.maps.event.addDomListener(me.resultNode_, 'mouseover', function() {
        // Highlight the marker and result icon when the result is
        // mouseovered.  Do not remove any other highlighting at this time.
        me.highlight(true);
      });
      google.maps.event.addDomListener(me.resultNode_, 'mouseout', function() {
        // Remove highlighting unless this marker is selected (the info
        // window is open).
        if (!me.selected_) me.highlight(false);
      });
      google.maps.event.addDomListener(me.resultNode_, 'click', function() {
        me.select();
      });
      document.getElementById("searchwell").appendChild(me.resultNode_);
    }

    LocalResult.prototype.node = function() {
      if (this.resultNode_) return this.resultNode_;
      return this.html();
    };

    // Returns the GMap marker for this result, creating it with the given
    // icon if it has not already been created.
    LocalResult.prototype.marker = function() {
      var me = this;
      if (me.marker_) return me.marker_;
      var marker = me.marker_ = new google.maps.Marker({
        position: new google.maps.LatLng(parseFloat(me.result_.lat),
                                         parseFloat(me.result_.lng)),
        icon: gYellowIcon, shadow: gSmallShadow, map: gMap});
      google.maps.event.addListener(marker, "click", function() {
        me.select();
      });
      return marker;
    };

    // Unselect any selected markers and then highlight this result and
    // display the info window on it.
    LocalResult.prototype.select = function() {
      unselectMarkers();
      this.selected_ = true;
      this.highlight(true);
      gInfoWindow.setContent(this.html(true));
      gInfoWindow.open(gMap, this.marker());
    };

    LocalResult.prototype.isSelected = function() {
      return this.selected_;
    };

    // Remove any highlighting on this result.
    LocalResult.prototype.unselect = function() {
      this.selected_ = false;
      this.highlight(false);
    };

    // Returns the HTML we display for a result before it has been "saved"
    LocalResult.prototype.html = function() {
      var me = this;
      var container = document.createElement("div");
      container.className = "unselected";
      container.appendChild(me.result_.html.cloneNode(true));
      return container;
    }

    LocalResult.prototype.highlight = function(highlight) {
      this.marker().setOptions({icon: highlight ? gRedIcon : gYellowIcon});
      this.node().className = "unselected" + (highlight ? " red" : "");
    }

    GSearch.setOnLoadCallback(OnLoad);
    //]]>
    </script>
 
	<div class="rating_header">
    	<h1>Search for a place:</h1>
    </div>
    <div style="margin-bottom: 5px;">
	    <div>
	      <input type="text" id="queryInput" value="food" style="width: 250px;"/>
	      <input type="button" value="Find" onclick="doSearch()"/>
	    </div>
    </div>
	<div id="map" style="height: 350px; width:350px; border: 1px solid #979797; float:left;"></div>
	<div style="float:left; margin-left:2em;">
		<div id="searchwell"></div>
	</div>


</div>
<jsp:include page="footer.jsp" />