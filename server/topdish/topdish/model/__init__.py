"""The application's model objects"""
import logging
import time

from pylons import config

import sqlalchemy as sa
from sqlalchemy import orm
from sqlalchemy import or_
from sqlalchemy.orm import scoped_session, sessionmaker

from common import *
from common import lib as commonlib
from common import orm as commonorm
from common.lib import crypt as libcrypt
from common.lib import facebook as fblib
from common.lib import helpers as commonhelpers
from common.lib import memcacheutils
from common.mixin import AsyncFactoryMixin
from common.mixin import DictORMMixin
from common.mixin import FactoryMixin
from common.mixin import S3ORMMixin
from common.mixin import StatusMixin
from common.mixin import VersionMixin

from topdish.model import meta
from topdish.model import mixin

log = logging.getLogger(__name__)

mc = None

def init_model(engine):
    global mc
    ns = '%s_%s' % (config['memcache.namespace'], config.get('dev_port', 80))
    parsed_config = memcacheutils.parse_memcache_config(config['memcache.server_list'])
    try:
        mc = memcacheutils.NamespacedMemcacheClient(ns, parsed_config)
    except:
        log.error(config)
        raise 
    meta.Session = scoped_session(sessionmaker(query_cls=memcacheutils.MemcacheQuery.factory(mc)))
    meta.Session.configure(bind=engine)
    meta.engine = engine

    context = commonorm.ModelContext(engine=engine, session=meta.Session, mc=mc)

    context.add_orm(User)
    context.add_orm(UserLike)
    context.add_orm(UserComment)
    context.add_orm(UserFollow)
    commonorm.init_model(context, conf=config)

class User(commonorm.ORM, FactoryMixin, StatusMixin):
    __table_name__ = 'user'

    @classmethod
    def factory(cls, fb_user_id, **attrs):
        obj = cls.find(fb_user_id=fb_user_id).first()
        attrs['salt'] = random.randint(0, sys.maxint)
        return obj or super(User, cls).factory(None, fb_user_id=fb_user_id, **attrs)

    @classmethod
    def find_by(cls, **kw):
        from topdish.lib import security as securitylib
        if 'email' in kw:
            email = kw['email']
            del kw['email']
            kw['email_hash'] = securitylib.hash(email)
        return super(User, cls).find_by(**kw)

    def update_fb_access_token(self, fb_access_token, expiry, commit=True):
        if self.fb_access_token != fb_access_token:
            self.fb_access_token = fb_access_token

        self.last_login = commonhelpers.now()
        self.fb_access_token_expiry = expiry
        if commit:
            self.get_session().commit()

    def clear_fb_access_token(self, commit=True):
        self.fb_access_token = None
        self.fb_access_token_expiry = 0
        if commit:
            self.get_session().commit()

    def generate_email_access_token(self, commit=True):
        from topdish.lib import security as securitylib

        expiry = (int(time.time()) / 86400 + 7) * 86400
        token_text = '%s%s%s' % (expiry, self.email_hash, self.password_hash)
        self.email_access_token = securitylib.hash(token_text, salt=self.salt)
        self.email_access_token_expiry = expiry

        if commit:
            self.get_session().commit()

    def clear_email_access_token(self, commit=True):
        self.email_access_token = None
        self.email_access_token_expiry = 0
        if commit:
            self.get_session().commit()

    def update_user_fields(self, field_values={}, commit=True):
        """
        Update any fields we need to get from FB
        """
        fields = {'email': lambda x: x,
                  'gender': lambda x: {'male': 1, 'female': 2}.get(x),
                  'first_name': lambda x: x,
                  'last_name': lambda x: x,}
        if field_values:
            profile = field_values
        else:
            api = fblib.GraphAPI(self.fb_access_token)
            profile = api.get_object("me")

        for field, transform in fields.iteritems():
            val = transform(profile.get(field))
            if field == 'email' and self.email is not None:
                continue
            if val is not None:
                setattr(self, field, val)

        if commit:
            self.get_session().commit()

    @property
    def name(self):
        return self.first_name or self.email or 'Unknown'

    def before_update(self):
        from topdish.lib import security as securitylib
        super(User, self).before_update()
        if self.email:
            self.email_hash = securitylib.hash(self.email)

    def check_password(self, cleartext):
        from topdish.lib import security as securitylib
        return securitylib.hash(cleartext, salt=self.salt) == self.password_hash

    def _set_password(self, password):
        """
        Set the user's password_hash to the hash of the new plaintext
        """
        from topdish.lib import security as securitylib
        self.password_hash = securitylib.hash(password, salt=self.salt)

    def _get_password(self):
        return None

    password = property(_get_password, _set_password)

class UserTag(FactoryMixin, StatusMixin):

    TYPES = {'dish': 0,
             'restaurant': 1}

    TYPE_ACCESSORS = {'dish': None,
                      'restaurant': None}

    TYPES_LOOKUP = dict((v, k) for k, v in TYPES.iteritems())

    @classmethod
    def factory(cls, user_id, type, obj_id, **kw):
        if type not in cls.TYPES:
            raise Exception('unknown type; %r' % type)

        if not any((user_id, obj_id)):
            raise Exception('invalid user_id or obj_id: %r, %r' % user_id, obj_id)

        # verify associated objects are valid
        if False:
            obj = cls.TYPE_ACCESSORS[type](obj_id)
            if not obj:
                raise Exception('invalid obj_id: %r for type: %r' % (obj_id, type))

            user = User.get(user_id)
            if not user:
                raise Exception('invalid user_id: %r' % user_id)

        try:
            return super(UserTag, cls).factory(None, 
                                               user_id=user_id, 
                                               type=cls.TYPES[type], 
                                               obj_id=obj_id,
                                               **kw)
        except sa.exceptions.IntegrityError, e:
            return cls.find(user_id=user_id, type=cls.TYPES[type], obj_id=obj_id).first()

    @property
    def type_name(self):
        return self.TYPES_LOOKUP[self.type]

class UserLike(commonorm.ORM, UserTag, DictORMMixin):
    __table_name__ = 'user_like'

class UserComment(commonorm.ORM, UserTag, DictORMMixin):
    __table_name__ = 'user_comment'

class UserFollow(commonorm.ORM, UserTag, DictORMMixin):
    __table_name__ = 'user_follow'

class UserFlag(commonorm.ORM, UserTag, DictORMMixin):
    __table_name__ = 'user_flag'
