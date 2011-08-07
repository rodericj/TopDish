import logging

from decorator import decorator

from pylons import request
from pylons.decorators import jsonify

from voyer.lib import security as securitylib
from voyer.lib.exceptions import *

from voyer import model

log = logging.getLogger(__name__)

@jsonify
def api(fn, *args, **kw):
    error = 0
    error_message = None

    try:
        payload = fn(*args, **kw)
    except BaseApiException, e:
        log.warning('API exception', exc_info=True)
        error = 1
        error_message = str(e)
        payload = {}

    if not isinstance(payload, dict) and not isinstance(payload, list):
        exc = Exception('payload must be a list or dictionary not %s' % type(payload))
        error = 1
        error_message = str(exc)
        payload = {}

    payload['rc'] = error
    ret = payload
    if error_message:
        ret['error_message'] = error_message

    return ret

api = decorator(api)

@api
def secure_api(fn, *args, **kw):
    api_access_token = request.params.get('apiKey')

    if not api_access_token:
        raise ApiSecurityException('Missing API access token')

    type, user_id, security_token = securitylib.parse_api_access_token(api_access_token)
    print 'type, user_id, security_token', type, user_id, security_token
    if None in (user_id, security_token):
        raise ApiSecurityException('Invalid API access token')

    user = model.User.get(user_id)
    if not user or not securitylib.verify_security_token(type, 
                                                         user, 
                                                         security_token):
        raise ApiSecurityException('Invalid API access token')

    h.user_id = lambda: user_id
    h.user = lambda: user
    h.security_token = lambda: security_token
    h.api_access_token = lambda: api_access_token
    h.api_access_type = lambda: type

    return fn(*args, **kw)

secure_api = decorator(secure_api)


def request_debug(fn, *args, **kw):
    log.debug('Content type: %s', request.headers['Content-Type'])
    log.debug('%s %s %s, request params: %s', 
              request.method,
              h.controller(), 
              h.action(), 
              request.params)
    log.debug('Body: %s', request.body)
    return fn(*args, **kw)

request_debug = decorator(request_debug)
