from common.lib import *

from topdish.lib.base import h

class BaseApiException(Exception):
    pass

class DocException(BaseApiException):
    def __init__(self, doc_str):
        super(DocException, self).__init__(doc_str)

class InvalidUserException(BaseApiException):
    def __init__(self, invalid_user_id, *args):
        if invalid_user_id:
            message = 'Invalid user id: %s' % h.to_str(invalid_user_id)
        else:
            message = 'Missing user id'

        super(InvalidUserException, self).__init__(message, *args)

class InvalidFBUserException(BaseApiException):
    def __init__(self, invalid_user_id, *args):
        if invalid_user_id:
            message = 'Invalid facebook user id: %s' % h.to_str(invalid_user_id)
        else:
            message = 'Missing facebook user id'

        super(InvalidFBUserException, self).__init__(message, *args)

class InvalidEmailException(BaseApiException):
    def __init__(self, invalid_email, *args):
        if invalid_email:
            message = 'Invalid email address: %s' % h.to_str(invalid_email)
        else:
            message = 'Missing email address'

        super(InvalidEmailException, self).__init__(message, *args)

class InvalidCommentException(BaseApiException):
    def __init__(self, invalid_id, *args):
        if invalid_id:
            message = 'Invalid comment id: %s' % h.to_i(invalid_id)
        else:
            message = 'Missing comment id'

        super(InvalidCommentException, self).__init__(message, *args)

class InvalidLikeException(BaseApiException):
    def __init__(self, invalid_id, *args):
        if invalid_id:
            message = 'Invalid like id: %s' % h.to_i(invalid_id)
        else:
            message = 'Missing like id'

        super(InvalidLikeException, self).__init__(message, *args)

class InvalidSignatureException(BaseApiException):
    def __init__(self, sig, *args):
        if sig:
            message = 'Invalid signature: %s' % h.to_s(sig)
        else:
            message = 'Missing signature'

        super(InvalidSignatureException, self).__init__(message, *args)

class InvalidParamException(BaseApiException):
    def __init__(self, param_name, value, *args):
        if value:
            message = 'Invalid parameter value for %s: %s' % \
                      (param_name, h.to_str(value))
        else:
            message = 'Missing parameter: %s' % param_name

        super(InvalidParamException, self).__init__(message, *args)

class UserNotLoggedInException(BaseApiException):
    def __init__(self, *args):
        super(UserNotLoggedInException, self).__init__('User not logged in', *args)

class ApiSecurityException(BaseApiException):
    def __init__(self, message, *args):
        super(ApiSecurityException, self).__init__(message, *args)

class AccessTokenExpiredException(ApiSecurityException):
    def __init__(self, access_token_type, *args):
        message = '%s access token expired' % access_token_type
        super(AccessTokenExpiredException, self).__init__(message, *args)
