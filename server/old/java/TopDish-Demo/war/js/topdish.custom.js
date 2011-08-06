$('#header_bottom').corner("bottom");
$('.time_of_week_menu').corner("5px");
$('.time_of_week_menu ul li a').corner("5px");
$('#filter_list').corner("10px");

$(document).ready(function(){
	//TODO: only show gallery when more than 1 photo, scale instead of crop
	$('#gallery').galleryView({
		panel_width: 572,
		panel_height: 384,
		panel_scale: 'nocrop',
		frame_scale: 'crop',
		gallery_width: 548,
		gallery_height: 355,
		frame_width: 109,
		frame_height: 98,
		pause_on_hover: true
	});
});

$(document).ready(function(){
	var ajaxCallType="";
	filterCount=0;
	ajaxCallType=$("#callTypeId").val();
	$('.search_filters').toggle(
		function() 
		{
			var $this = $(this);
			$('#filter_list').stop(true, true).animate({ 'left' : '-120px'}, 300);
			$('.search_filters').removeClass('search_filter_offset');
		},
		function()
		{
			$('#filter_list').stop(true, true).animate({ 'left' : '0'}, 300);
			$('.search_filters').addClass('search_filter_offset');
		}
	);
	
	$("li.closed").each(function()
	{
		$(this).children("ul").hide();
	});
	
		$(".filterDiv").click(function()
			{
			//to expand and close the filter
				if($(this).hasClass('open'))
				{
					hideFilter($(this));
				}
				else
				{
					showFilter($(this));
				}
					
			});
		
		function showFilter(filter)
		{
			$(filter).next().slideDown();
			$(filter).removeClass('closed');
			$(filter).addClass('open');
		}
		
		function hideFilter(filter)
		{
			$(filter).next().slideUp();
			$(filter).removeClass('open');
			$(filter).addClass('closed')
		}

	//$("li.closed ").click(openFilter);
	//$("li.open ").click(closeFilter);
	
	//Filter click functions
	$("li.categoryFilter").click(function()
	{
		
		clearAddFilter($(this));
		loadTopDishesOnFilter();

		//window.location = "/index.jsp?categoryID="+$(this).attr("rel")+"&priceID="+priceFilter;//b4 changes
		
	});
	
	$("li.cuisineFilter").click(function(){
			clearAddFilter($(this));
			loadTopDishesOnFilter();		
	});
	
	//adds/removes filter on click
	function clearAddFilter(filter)
	{
		placeSearchBack();
		if($(filter).hasClass('selected'))
		{
			//on click we will deselect
			$(filter).removeClass('selected');
			filterCount--;
			hideBreadCrumb($(this));
		}
		else 
		{
			
			if($(filter).siblings(".selected").size()>0)
			{
				$(filter).siblings(".selected").removeClass('selected');
				filterCount--;
				hideBreadCrumb($(this));
			}
			//on click we will select
			$(filter).addClass('selected');
			filterCount++;
		}
	}
	
	$("li.priceFilter").click(function()
	{
		//window.location = "/index.jsp?priceID="+$(this).attr("rel");
		clearAddFilter($(this));
		loadTopDishesOnFilter();
	});
	
	//breadcrumb clicks
	$('#bcCatRem').click(function()
	{
		$("li[class^=categoryFilter selected]").each(function(){
			$(this).click();
			});
		hideBreadCrumb($(this));
	});
	
	$('#bcCuisineRem').click(function()
	{
		$("li[class^=cuisineFilter selected]").each(function(){
			$(this).click();
			});
		hideBreadCrumb($(this));
	});
	
	$('#bcLifeRem').click(function()
	{
		$("li[class^=lifestyleFilter selected]").each(function(){
			$(this).click();
			});
		hideBreadCrumb($(this));
	});
	
	$('#bcDistRem').click(function()
	{
		$("li[class^=distanceFilter selected]").each(function(){
			$(this).click();
			});
		hideBreadCrumb($(this));
	});
	
	$("#bcPriceRem").click(function()
	{
		 $("li[class^=priceFilter selected]").each(function(){
				$(this).click();
				});
		hideBreadCrumb($(this));
	});
	
	function hideBreadCrumb(bc)
	{
		//filterCount--;
		if(filterCount>0)
		{
			$(bc).prev().prev().hide();
		}
		else
		{
			clearAndHideBreadCrumb();
		}
	}
	

	$("li.lifestyleFilter").click(function()
	{
				//window.location = "/index.jsp?lifestyleID="+$(this).attr("rel");
		clearAddFilter($(this));
	
		loadTopDishesOnFilter();
	});
	
	$("li.distanceFilter").click(function()
	{
		//window.location = "/index.jsp?distance="+$(this).attr("rel");
		clearAddFilter($(this));

		 loadTopDishesOnFilter();
	});
	
	function placeSearchBack()
	{
		if(ajaxCallType=='search')
		{
			if($('#searchId').val().length==0)
				$('#searchId').val($('#hiddenSearchWordId').val());
		}
		
	}
	
	function clearAndHideBreadCrumb()
	{
		filterCount=0;
		$("#bcCuisine").html("");
		$("#bcCat").html("");
		$("#bcLife").html("");
		$("#bcDist").html("");
		$("#bcPrice").html("");
				
		$("#bcCuisineDiv").hide();
		$("#bcCatDiv").hide();
		$("#bcLifeDiv").hide();
		$("#bcDistDiv").hide();
		$("#bcPriceDiv").hide();
		$("#breadCrumbId").hide();
	}
	

	
	
	$(".pageNumDiv").click(function()
			{
				//window.location = "/index.jsp?distance="+$(this).attr("rel");
				placeSearchBack();
				$(this).addClass('selected');
				 loadTopDishesOnFilter();
				 var pageNumVal="0";
					$("div[class^=pageNumDiv selected]").each(function(){
						pageNumVal = $(this).attr('id');  
						  
						}); 
					var pageNum=parseInt(pageNumVal);
				if($(this).children('a:first').attr('id')=='nextId')
				{
					
					$(this).attr('id',(pageNum+1));
					$(this).prev().attr('id',(pageNum-1));
					if((pageNum+1)>=1)
					{
						$(this).prev().show();
					}
					else
					{
						$(this).prev().hide();
					}
				}
				else
				{
					$(this).attr('id',(pageNum-1));
					$(this).next().attr('id',(pageNum+1));
					if((pageNum-1)<0)
					{
						$(this).hide();
					}
					$(this).next().show();
				}
				 $(this).removeClass('selected');
			});
			
	
	function openFilter()
	{
		/*$("#filter_list ul li.open").each(function(){
			$(this).click(closeFilter);
			$(this).click();
		});*/

				$(this).unbind("click");
				$(this).click(closeFilter);
				$(this).removeClass("hover");
				$(this).addClass("open");
				$(this).css("height", "auto");
				$(this).children("ul").slideDown();

	};
	
	function closeFilter()
	{

				$(this).unbind("click");
				$(this).click(openFilter);
				$(this).addClass("hover");
				$(this).removeClass("open");
				$(this).children("ul").slideUp();

	}
	
	
	
	 function loadTopDishesOnFilter() { 
		
		var priceFilterId="",priceFilter="";
		$("li[class^=priceFilter selected]").each(function(){
			priceFilterId = $(this).attr('rel');  
			priceFilter= $(this).text(); 
			});
		
		var lifestyleFilterId="",lifestyleFilter="";
		$("li[class^=lifestyleFilter selected]").each(function(){
			lifestyleFilterId = $(this).attr('rel');  
			lifestyleFilter= $(this).text(); 
			});
		var distanceFilterId="",distanceFilter="";
		$("li[class^=distanceFilter selected]").each(function(){
			distanceFilterId = $(this).attr('rel');  
			distanceFilter= $(this).text();   
			});
		
		var categoryId="",category="";
		$("li[class^=categoryFilter selected]").each(function(){
			categoryId = $(this).attr('rel');  
			category= $(this).text();   
			});
		
		var cuisineId="", cuisine="";
		$("li[class^=cuisineFilter selected]").each(function(){
			cuisineId = $(this).attr('rel');  
			cuisine= $(this).text();   
			});
		
		var pageNum="0";
		$("div[class^=pageNumDiv selected]").each(function(){
			pageNum = $(this).attr('id');  
			  
			});
		
		var searchWord="";
			searchWord = $("#searchId").val();  
		
		var location="";
		location = $("#loc").val();  
		
		var filterPresent=true;
		if(category.length==0 && distanceFilter.length==0 && lifestyleFilter.length==0 && priceFilter.length==0 && cuisine.length==0)
			{
				filterPresent=false;
			}
		if(filterPresent==true)
			{
				$("#breadCrumbId").show();
				
				if(cuisineId!=''){
					$("#bcCuisineDiv").show();
					$("#bcCuisine").html(cuisine);
				}else{
					$("#bcCuisine").html("");
					$("#bcCuisineDiv").hide();					
				}
				
				if(categoryId!='')
				{
					$("#bcCatDiv").show();
					$("#bcCat").html(category);
					
				}
				else
				{
					$("#bcCat").html("");
					$("#bcCatDiv").hide();
				}
				
				if(lifestyleFilter!='')
				{
					$("#bcLifeDiv").show();
					$("#bcLife").html(lifestyleFilter);
					
				}
				else
				{
					$("#bcLife").html("");
					$("#bcLifeDiv").hide();
				}
				
				if(distanceFilter!='')
				{
					$("#bcDistDiv").show();
					$("#bcDist").html(distanceFilter);
					
				}
				else
				{
					$("#bcDist").html("");
					$("#bcDistDiv").hide();
				}
				
				if(priceFilter!='')
				{
					$("#bcPriceDiv").show();
					$("#bcPrice").html(priceFilter);
					
				}
				else
				{
					$("#bcPrice").html("");
					$("#bcPriceDiv").hide();
				}
				
			}
		$.ajax({
			type: "POST",
			url: "/getTopDishesAjax",
			data: "callType="+ajaxCallType+"&searchWord="+searchWord+"&location="+location+"&cuisineID="+cuisineId+"&categoryID="+categoryId+"&priceID="+priceFilterId+"&lifestyleID="+lifestyleFilterId+"&distance="+distanceFilterId+"&page="+pageNum+"&maxResults=10",
			dataType:"xml",
			cache: true,
			success: function(xml){
				$("#dishResultId").html('');
				//$("#paginationDiv").html('');
				var divCont='';
				var paginationCont='';
				if($(xml).find('Dish').length>0)
				{
					//show next
					$('#nextId').show();
					
					var pageCount=$(xml).find('count').text();
					$(xml).find('Dish').each(function(){
					
					var keyId=$(this).find('keyId').text();
					var dishName=$(this).find('name').text();
					var description=$(this).find('description').text();
					var restId=$(this).find('restId').text();
					var restName=$(this).find('restName').text();
					var blobUploadURL=$(this).find('blobUploadURL').text();
					
					divCont+='<div class="upVotePanel votePanel" style="display:none;">'+
					 '<form action="'+blobUploadURL+'" method="post" id="reviewDishForm" enctype="multipart/form-data">'+
					 '<h2>Additional Food for thought? <span>Tell us why you would recommend this dish.</span></h2>'+
					 '<textarea name="comment" class="textVote"></textarea>'+
					 '<div class="cover"><h3>If you change your mind later <a href="#">revote</a>, or edit from you <a href="#">profile</a>.</h3></div>'+
					 '<img src="/img/panel/voteup_photo.png" alt="Add a Photo" class="photo" />'+
					 '<input type="file" name="myFile" class="browse" />'+
					 '<input name="rating" value="pos" type="hidden" />'+
					 '<input name="dishID" value="'+keyId+'" type="hidden" />'+
					 '<input type="image" src="/img/panel/voteup_submit.png" name="submit" class="submit" />'+
					 '</form>'+
					 '</div>';
			
					var photoExists=$(this).find('photoExist').text();
					var photoDiv='';
					if(photoExists=='E')
						{
							photoDiv+='<img class="dish_image_gold" src="'+$(this).find('blobKey').text()+'" alt="'+dishName+'"></img>';
						}
					else
						{
							photoDiv+='<img class="dish_image_gold" src="style/no_dish_img.jpg" alt="'+dishName+'"></img>';
						}
					
					var userLoggedIn=$(this).find('userLoggedIn').text();
					var logCont='';
					if(userLoggedIn=='L')
						{
							logCont='<span><a href="editDish.jsp?dishID='+keyId+'">[edit]</a></span>';
						}
					
					
					var posReviews=$(this).find('posReviews').text();
					var negReviews=$(this).find('negReviews').text();
					var voteString=$(this).find('voteString').text();
					var userLoggedIn=$(this).find('userLoggedIn').text();
					var restAddrLine1=$(this).find('restAddrLine1').text();
					var restCity=$(this).find('restCity').text();
					var restState=$(this).find('restState').text();
					var restNeighbourhood=$(this).find('restNeighbourhood').text();
					var distance=$(this).find('distance').text();
					var latitude=$(this).find('latitude').text();
					var longitude=$(this).find('longitude').text();
					var userLoggedIn=$(this).find('userLoggedIn').text();
					var allowEdit=$(this).find('allowEdit').text();
								
					divCont+='<div class="dish_listing dish_splitter">'+
			       				'<div class="dish_listing_quick">';
			       	
		           
		           
						           divCont+='<div class="rating_box left">'+
						           		 '<div class="rating_box_upboat">'+
						           		 	'<div>+'+posReviews+'</div>'+
						           		 		'<a href="addReview.jsp?dishID='+keyId+'&amp;dir=1" class="activateUp">';
									              	if(voteString=='GT0') {
									              	divCont+='<img src="img/detailed/button_up_blue.png" alt="Upvote" width="55" height="38" />';
									                } else { 
									               divCont+='<img src="img/detailed/button_up_grey.png" alt="Upvote" width="55" height="38" />';
									               } 
							        divCont+= '</a>'+
						        		  	'</div>';
						        	divCont+='<div class="rating_box_downboat">'+
						        		  		'<a href="addReview.jsp?dishID='+keyId+'&amp;dir=-1" class="activateDown">';
										    	if(voteString=='LT0') {
										           divCont+='<img src="img/detailed/button_down_orange.png" alt="Downvote" width="55" height="38" />';
										           } 
										    	else { 
										           divCont+='<img src="img/detailed/button_down_grey.png" alt="Downvote" width="55" height="38" />';
										           } 
								    divCont+=   '</a>'+
								    			'<div>-'+negReviews+'</div>'+
								    		'</div>'+
								    	'</div>';
								    
								    divCont+='<div class="dish_listing_details">'+
								  		   		'<a href="dishDetail.jsp?dishID='+keyId+'">'+
								  		   			photoDiv +
								  		   		'</a>';
				
								    divCont+= '<div class="dish_listing_text">'+
						          				'<h1><a href="dishDetail.jsp?dishID='+keyId+'" class="dish_name">'+dishName+'</a>';
								    
										if(userLoggedIn=='L')
										{
											if(allowEdit=='T')
												{
													divCont+='<span><a href="editDish.jsp?dishID='+keyId+'">[edit]</a></span>';
												}
										}
									divCont+=       '</h1>'+
												'<p>'+description+' </p>'+
										    '</div>'+
										  '</div>';

									divCont+='<div class="dish_listing_address">'+
									         	'<div class="dish_height_bar"></div>'+
									         	'<h3><a href="restaurantDetail.jsp?restID='+restId+'">'+restName+'</a></h3>'+
									         	'<p>'+restAddrLine1+'</p>'+
									         	'<p>'+restCity + ', '+
									         		 restState+'</p>'+
									         	'<p>'+restNeighbourhood+'</p>'+
									         	'<p>Distance: '+distance +' mi</p>'+
									         	'<div class="dish_lat" style="">'+latitude+'</div>'+
									         	'<div class="dish_lng" style="">'+longitude+'</div>'+                    
									         '</div>'+
								'</div>';
									
								divCont+='<div class="dish_listing_footer">'+
										 	'<div class="dish_status">'+
										 	'</div>';
				

						var tagsEmpty=$(this).find('tagsEmpty').text();
						if(tagsEmpty=='NE')
							{
								divCont+=	'<div class="dish_listing_categories">'+
										 		'<h3>Tags:</h3>'+
										 		'<p>';
								$(this).find('Tags').find('tag').each(function(){
									var tagName=$(this).find('tagName').text();
								divCont+=tagName+'&nbsp;&nbsp;';
								});
								divCont+=		'</p>'+
										 	'</div>';
		
							}

					var lastReviewType=$(this).find('lastReviewType').text();
					var lastReview=$(this).find('lastReview').text();
					var numReview=$(this).find('numReview').text();
									divCont+='<div class="dish_listing_infographics">';
					if(lastReviewType!='E')
						{
							if(lastReviewType=='P')
								{
										divCont+='<img src="img/up_arrow_icon.png" width="12" height="15" /><span>'+lastReview+' ago</span>';
								}
							else
								{
										divCont+='<img src="img/down_arrow_icon.png" width="12" height="15" /><span>'+lastReview+' ago</span>';
								}
						}
	
	
										divCont+=' <img src="img/comment_icon.png" width="16" height="15" /><span><a href="dishDetail.jsp?dishID='+keyId+'">Reviews: '+numReview+'</a></span>'+
											  '</div>'+
										 '</div>'+
					        '<div class="dish_listing_terminator"></div>'+
					 '</div>';
				
						divCont+='<div class="downVotePanel votePanel" style="display:none;">'+
						'<form action="'+blobUploadURL+'" method="post" id="reviewDishForm" enctype="multipart/form-data">'+
							'<h2>Additional Food for thought? <span>Tell us why you would not recommend this dish.</span></h2>'+
							'<textarea name="comment" class="textVote"></textarea>'+
							'<div class="cover"><h3>If you change your mind later <a href="#">revote</a>, or edit from you <a href="#">profile</a>.</h3></div>'+
							'<img src="/img/panel/votedown_photo.png" alt="Add a Photo" class="photo" />'+
							'<input type="file" name="myFile" class="browse" />'+
							'<input name="rating" value="neg" type="hidden" />'+
							'<input name="dishID" value="'+keyId+'" type="hidden" />'+
							'<input type="image" src="/img/panel/votedown_submit.png" name="submit" class="submit" />'+
						'</form>'+
					'</div>';
				
					
				   });// close each 
					if(ajaxCallType=='search')
					{
						$('#dishFoundId').show();
					}
					else
						$('#dishFoundId').hide();
				}
				else
				{
					//hide pagination
					$('#nextId').hide();
					
					divCont=$(xml).find('dishMesg').text();
					$("div[class^=pageNumDiv selected]").each(function(){
						$(this).hide();
					});
				}
				$('#loc').val($(xml).find('loc').text());
				divCont=''+divCont;
				 $('#loc').val($('#locHidden').val());
				$("#dishResultId").html(divCont);
			},
			error: function(xhr, textStatus, thrownError){
			}
			}); 

	}

	$("#ajax_status").ajaxStart(function(){
		$(this).show();
	});
	
	$("#ajax_status").ajaxStop(function(){
		$(this).hide();
	});

});



