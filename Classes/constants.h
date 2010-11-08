//
//  constants.h
//  TopDish
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define MAXRESTAURANTNAMELENGTH 26
#define DISHDETAILIMAGECELLHEIGHT 72
#define IPHONESCREENWIDTH 320
#define NUMBEROFROWSINDISHDETAILVIEW 4
#define DISHDETAILDEFAULCELLHEIGHT 40
#define COMMENTTABLECELLHEIGHT 72

#define POSITIVE_REVIEW_IMAGE_NAME @"greenup.gif"
#define NEGATIVE_REVIEW_IMAGE_NAME @"reddown.gif"

#pragma mark network constants
#define NETWORKHOST @"http://topdish1.appspot.com"

#define DISH_DETAIL_CELL_IDENTIFIER @"dishdetailimagecell"
#define MIN_PRICE_VALUE_LOCATION @"minpricevaluelocation"
#define MAX_PRICE_VALUE_LOCATION @"maxpricevaluelocation"
#define SORT_VALUE_LOCATION @"sortvaluelocation"
#define RATINGS_SORT @"posReviews"
#define DISTANCE_SORT @"distance"

#pragma tags

#define DISHDETAILIMAGETAG 1
#define ROOTVIEW_DISH_NAME_TAG 1
#define ROOTVIEW_RESTAURANT_NAME_TAG 2
#define ROOTVIEW_COST_TAG 3
#define ROOTVIEW_UPVOTES_TAG 4
#define ROOTVIEW_DOWNVOTES_TAG 6
#define ROOTVIEW_IMAGE_TAG 8

#define COMMENTOR_NAME_TAG 1
#define COMMENT_TEXT_TAG 2