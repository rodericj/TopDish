import hashlib
import time

from topdish.lib.exceptions import *
from topdish.lib import helpers as h

def generate_api_access_token(user, type='email'):
    """
    Api access tokens have the following format:
    type.user_id.md5(user_id + fb_access_token + secret_key)
    """
    user_id = user.user_id
    if type == 'email':
        access_token = user.email_access_token
        access_token_expiry = user.email_access_token_expiry
        secret = h.site_secret()
    elif type == 'facebook':
        access_token = user.fb_access_token
        access_token_expiry = user.fb_access_token_expiry
        secret = h.fb_secret()
    else:
        raise ApiSecurityException('Unknown access token type: %r' % type)

    print access_token, access_token_expiry, secret
    if access_token is None:
        raise UserNotLoggedInException()
    elif access_token_expiry <= int(time.time()):
        raise AccessTokenExpiredException(type)

    token = generate_security_token(user_id, access_token, secret)
    return '%s.%s.%s' % (type, user_id, token)


def generate_security_token(user_id, access_token, secret):
    hash = hashlib.md5(''.join((str(user_id), 
                                access_token, 
                                secret))).hexdigest()
    return hash


def parse_api_access_token(api_access_token):
    """
    See generate_api_access_token()
    """
    parts = api_access_token.split('.')
    if not parts or len(parts) != 3:
        raise ApiSecurityException('Invalid API access token: %s' % api_access_token)
    return parts[0], h.to_i(parts[1]), parts[2]


def verify_security_token(type, user, security_token):
    """
    Verify that the security token is for the specified user and type
    """
    access_token = None
    if type == 'facebook':
        access_token = user.fb_access_token
        secret = h.fb_secret()
    elif type == 'email':
        access_token = user.email_access_token
        secret = h.site_secret()
    else:
        raise ApiSecurityException('Unknown access token type: %r' % type)

    if access_token is None:
        raise UserNotLoggedInException()

    expected = generate_security_token(user.user_id, access_token, secret)
    return expected == security_token

def hash(string, salt=None):
    if salt:
        return hashlib.md5('%s%s' % (string, salt)).hexdigest()
    else:
        return hashlib.md5('%s' % string).hexdigest()

