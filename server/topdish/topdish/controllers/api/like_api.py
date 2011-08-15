import hashlib
import logging
import mimetypes

from topdish.controllers.api import *

log = logging.getLogger(__name__)

class LikeApiController(BaseApiController):

    LIMIT = 10

    def __before__(self):
        super(LikeApiController, self).__before__()
        h.like_id = lambda: h.to_i(request.environ['pylons.routes_dict'].get('id'))
        h.obj_id = lambda: h.to_i(request.environ['pylons.routes_dict'].get('obj_id'))
        h.obj_type = lambda: h.to_str(request.environ['pylons.routes_dict'].get('obj_type'))

    @request_debug
    def index(self):
        """
        UNTESTED!!!!!

        GET:
            Returns a list containing dictionaries with data for all 
            likes on the requested object.

            Request parameters:
            1. obj_id - int, the id of the object likeed on
            2. obj_type - string, choices: 'media' or 'listing'

            Returns each associated like in a JSON array:
            e.g. [{"status": 0, 
                   "user_id": 2, 
                   "obj_id": 1, 
                   "like_id": 1, 
                   "date_created": 0, 
                   "type": 1}]

        POST:
            Creates a new like

            Request parameters:
            1. user_id - int
            2. type - string, choices: 'media' or 'listing'
            3. obj_id - int, id of the object the user is likeing

            Returns the newly created like in a JSON array.
            e.g. [{"like_id": 12345,
                   "status": 0,
                   "user_id": 43,
                   "type": 1,
                   "obj_id": 122,
                   "date_created": 1310796796}]

        DELETE:
            Deletes the specified like forever
        """
        return {'GET': self._index_get,
                'POST': self._index_post,
                'DELETE': self._index_delete}.get(request.method, lambda x: abort(404))()

    @api
    def _index_get(self):
        obj_type = h.obj_type()
        obj_id = h.obj_id()

        obj = self._resolve_obj(obj_type, obj_id)
        return obj.likes()

    @secure_api
    def _index_delete(self):
        like = self._resolve_like(h.like_id())
        if like.user_id != h.user_id():
            raise ApiSecurityException('user does not own like')

        like.delete()
        return {}

    @secure_api
    def _index_post(self):
        obj_id = h.obj_id()
        obj_type = h.obj_type()

        obj = self._resolve_obj(obj_type, obj_id)
        like = obj.like(h.user_id())
        return [like.to_dict()]

    def _resolve_obj(self, obj_type, obj_id):
        if obj_type not in model.UserLike.TYPES:
            raise InvalidParamException('obj_type', obj_type)
        if not obj_id:
            raise InvalidParamException('obj_id', obj_id)

        getter = model.UserLike.TYPE_ACCESSORS[obj_type]
        obj = getter(obj_id)
        if not obj:
            if obj_type == 'media':
                raise InvalidMediaException(obj_id)
            elif obj_type == 'listing':
                raise InvalidListingException(obj_id)
            else:
                raise InvalidParamException('obj_id', obj_id)

        return obj

    def _resolve_like(self, like_id):
        like_id = h.like_id()
        if not like_id:
            raise InvalidLikeException(like_id)

        like = model.UserLike.get(like_id)
        if not like:
            raise InvalidLikeException(like_id)

        return like
