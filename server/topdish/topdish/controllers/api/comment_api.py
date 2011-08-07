import hashlib
import logging
import mimetypes

from voyer.controllers.api import *

log = logging.getLogger(__name__)

class CommentApiController(BaseApiController):

    LIMIT = 10

    def __before__(self):
        super(CommentApiController, self).__before__()
        h.comment_id = lambda: h.to_i(request.environ['pylons.routes_dict'].get('id'))
        h.obj_id = lambda: h.to_i(request.environ['pylons.routes_dict'].get('obj_id'))
        h.obj_type = lambda: h.to_str(request.environ['pylons.routes_dict'].get('obj_type'))

    @request_debug
    def index(self):
        """
        UNTESTED!!!!!

        GET:
            Returns a list containing dictionaries with data for all 
            comments on the requested object.

            Request parameters:
            List view:
                1. obj_id - int, the id of the object commented on
                2. obj_type - string, choices: 'media' or 'listing'

                Returns each associated comment in a JSON array:
                e.g. [{"status": 0, 
                       "user_id": 2, 
                       "obj_id": 1, 
                       "data": "oh hello listing 1!", 
                       "comment_id": 1, 
                       "date_created": 0, 
                       "type": 1}]

            Detail view:
                1. id - int, the comment id of an individual comment

                Returns the comment data in a JSON array:
                e.g. [{"status": 0, 
                       "user_id": 2, 
                       "obj_id": 1, 
                       "data": "oh hello listing 1!", 
                       "comment_id": 1, 
                       "date_created": 0, 
                       "type": 1}]

        POST:
            Creates a new comment

            Request parameters:
            1. user_id - int
            2. type - string, choices: 'media' or 'listing'
            3. obj_id - int, id of the object the user is commenting on
            4. data - string, the content of the comment. Keep it short, please.

            Returns the newly created comment in a JSON array.
            e.g. [{"comment_id": 12345,
                   "status": 0,
                   "user_id": 43,
                   "type": 1,
                   "obj_id": 122,
                   "date_created": 1310796796,
                   "data": "OMG what an awesome app!"}]

        DELETE:
            Deletes the specified comment forever
        """
        return {'GET': self._index_get,
                'POST': self._index_post,
                'DELETE': self._index_delete}.get(request.method, lambda x: abort(404))()

    @api
    def _index_get(self):
        if h.comment_id() is not None:
            return self._index_detail_get()
        else:
            return self._index_list_get()

    def _index_list_get(self):
        obj_type = h.obj_type()
        obj_id = h.obj_id()

        obj = self._resolve_obj(obj_type, obj_id)
        return obj.comments()

    def _index_detail_get(self):
        comment = self._resolve_comment(h.comment_id())
        return [comment.to_dict()]

    @secure_api
    def _index_delete(self):
        comment = self._resolve_comment(h.comment_id())
        if comment.user_id != h.user_id():
            raise ApiSecurityException('user does not own comment')

        comment.delete()
        return {}

    @secure_api
    def _index_post(self):
        obj_id = h.obj_id()
        obj_type = h.obj_type()
        data = request.params.get('data')

        obj = self._resolve_obj(obj_type, obj_id)
        comment = obj.comment(h.user_id(), data)
        return [comment.to_dict()]

    def _resolve_obj(self, obj_type, obj_id):
        if obj_type not in model.UserComment.TYPES:
            raise InvalidParamException('obj_type', obj_type)
        if not obj_id:
            raise InvalidParamException('obj_id', obj_id)

        getter = model.UserComment.TYPE_ACCESSORS[obj_type]
        obj = getter(obj_id)
        if not obj:
            if obj_type == 'media':
                raise InvalidMediaException(obj_id)
            elif obj_type == 'listing':
                raise InvalidListingException(obj_id)
            else:
                raise InvalidParamException('obj_id', obj_id)

        return obj

    def _resolve_comment(self, comment_id):
        comment_id = h.comment_id()
        if not comment_id:
            raise InvalidCommentException(comment_id)

        comment = model.UserComment.get(comment_id)
        if not comment:
            raise InvalidCommentException(comment_id)

        return comment
