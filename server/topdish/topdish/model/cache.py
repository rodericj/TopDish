import logging
import sqlalchemy as sa

from common.lib.memcacheutils import CacheBase
from common.mixin import DictORMMixin

from topdish import model

log = logging.getLogger(__name__)

class _UserTagBaseCache(CacheBase):
    """
    Stores a list of UserTag dicts.
    """
    __usertag_cls__ = None

    if __usertag_cls__ and \
       not issubclass(__usertag_cls__, commonmixin.DictORMMixin):
        raise Exception('__usertag_cls__ must be a subclass of DictORMMixin')

    def __init__(self, obj_id, type):
        if type not in self.__usertag_cls__.TYPES:
            raise Exception('invalid type: %r' % type)

        super(_UserTagBaseCache, self).__init__(model.mc, timeout=86400)
        self.obj_id = obj_id
        self.type = self.__usertag_cls__.TYPES[type]

    def build_key(self):
        return '%s_%s_%s' % (self.__usertag_cls__.__name__,
                             self.type, 
                             self.obj_id)

    def build_data(self):
        print '__usertag_cls__.find START'
        orm_data = self.__usertag_cls__.find(type=self.type, obj_id=self.obj_id)
        print '__usertag_cls__.find END'
        print 'to_dict START'
        cache_data = [obj.to_dict() for obj in orm_data]
        print 'to_dict END'
        return cache_data

    def add(self, user_id):
        data = self.get_data()
        data.append(user_id)
        self.save(data)

class _UniqueUserTagBaseCache(_UserTagBaseCache):
    """
    Builds a cache that stores a mapping of user_id to UserTag dict.
    """
    __usertag_cls__ = None

    def process_cached_data(self, key, data):
        return dict((obj.get('user_id'), obj) for obj in (data or []) if obj)

    def add(self, user_id, obj):
        data = self.get_data() or {}
        data[user_id] = obj.to_dict()
        self.save(data)

