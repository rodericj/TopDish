from voyer.lib.base import *
from voyer.lib import security as securitylib
from voyer.controllers.api import BaseApiController

class CredentialsApiController(BaseApiController):

    @request_debug
    def email(self):
        """
        POST/GET:
            Returns the site-specific access token given a valid email/password

            Request parameters:
            1. email - string
            2. password - string

        DELETE:
            Invalidate all access tokens and returns an empty dict on success.
        """

        return {'GET': self._email_post,
                'POST': self._email_post,
                'DELETE': self._credentials_delete}.get(request.method, lambda: abort(404))()

    @request_debug
    def facebook(self):
        """
        POST/GET:
            Returns the site-specific access token given a set of valid
            Facebook access parameters.

            Request parameters:
            1. fb_user_id - int
            2. access_token - string, Facebook token received after logging into
                              Facebook from the caller app.
            3. expiry - int, the unix timestamp of the expiration of the Facebook
                        access_token.

        DELETE:
            Invalidate all access tokens and returns an empty dict on success.
        """

        return {'GET': self._facebook_post,
                'POST': self._facebook_post,
                'DELETE': self._credentials_delete}.get(request.method, lambda: abort(404))()

    @api
    def _email_post(self):
        email = h.to_str(h.request_param('email'))
        password = h.to_str(h.request_param('password'))

        if not email:
            raise InvalidParamException('email', email)
        elif not password:
            raise InvalidParamException('password', password)

        user = model.User.find(email=email).first()
        if not user:
            raise InvalidEmailException(email)

        if not user.check_password(password):
            raise InvalidEmailException(email)

        user.generate_email_access_token()
        access_token = securitylib.generate_api_access_token(user, type='email')
        return {'api_access_token': access_token,
                'user_id': user.user_id,
                'api_access_token_expires': user.email_access_token_expiry,
                'api_access_token_type': 'email'}

    @api
    def _facebook_post(self):
        fb_user_id = h.to_i(h.request_param('fb_user_id'))
        access_token = h.request_param('access_token')
        expiry = h.to_i(h.request_param('expiry'))

        if not fb_user_id:
            raise InvalidParamException('fb_user_id', fb_user_id)
        elif not access_token:
            raise InvalidParamException('access_token', access_token)
        elif not expiry:
            raise InvalidParamException('expiry', expiry)

        # Get the facebook /me object to verify the user is who they
        # claim to be. Use this to create a new user row or resolve
        # a current user.

        api = fblib.GraphAPI(access_token)
        try:
            me = api.get_object('me')
        except Exception, e:
            raise ApiSecurityException(str(e))
        else:
            if h.to_str(fb_user_id) != me['id']:
                raise ApiSecurityException('Invalid access_token')
            else:
                user = process_fb_user_data(me, access_token, expiry)

            access_token = securitylib.generate_api_access_token(user, 
                                                                 type='facebook')
            return {'api_access_token': access_token,
                    'user_id': user.user_id,
                    'api_access_token_expires': user.fb_access_token_expiry,
                    'api_access_token_type': 'facebook'}

    @secure_api
    def _credentials_delete(self):
        user = h.user()
        user.clear_fb_access_token(commit=False)
        user.clear_email_access_token()
        return {}
