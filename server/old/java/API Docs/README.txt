TOPDISH API V.1 BETA README

This is the V.1 Beta Release of the TopDish API.

Contacts:
	randy@topdish.com
	salil@topdish.com
----------------------

-This API only responds in JSON
-Some Requests are GET and some are POST (next version will likely be pure POST).
-All Responses will have one of the following:
"rc" : 0 <-- this indicates success, if additional information is required or requested it will be tagged inside the JSON
"rc" : 1 <-- this indicates failure, if an error message is provided it will be sent along
-Tip for building your initial comms handler: in the future, the any number greater than 0, will have a predefined error message (as servlet to get these messages will be provided)
-Overall this API is growing

