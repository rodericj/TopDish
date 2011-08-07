import logging

log = logging.getLogger(__name__)

class Likeable(object):
    def num_likes_attr(self):
        raise NotImplementedError()

    def like_type(self):
        raise NotImplementedError()

    def like_obj_id(self):
        raise NotImplementedError()

    def like_cache(self):
        raise NotImplementedError()

    def like(self, user_id):
        from topdish import model

        like = model.UserLike.factory(user_id, self.like_type(), self.like_obj_id())

        if like.newly_created():
            num_likes_name = self.num_likes_attr()
            setattr(self, num_likes_name, getattr(self, num_likes_name) + 1)

        self.get_session().commit()

        cache = self.like_cache()
        return like

    def likes(self):
        return self.like_cache().get_data()


class Commentable(object):
    def num_comments_attr(self):
        raise NotImplementedError()

    def comment_type(self):
        raise NotImplementedError()

    def comment_obj_id(self):
        raise NotImplementedError()

    def comment_cache(self):
        raise NotImplementedError()

    def comment(self, user_id, data):
        from topdish import model

        comment = model.UserComment.factory(user_id, self.comment_type(), self.comment_obj_id())
        if comment.newly_created():
            num_comments_name = self.num_comments_attr()
            setattr(self, num_comments_name, getattr(self, num_comments_name) + 1)

        self.get_session().commit()

        cache = self.comment_cache()
        cache.add(user_id)

        return comment

    def comments(self):
        return self.comment_cache().get_data()


class Followable(object):
    def num_follows_attr(self):
        raise NotImplementedError()

    def follow_type(self):
        raise NotImplementedError()

    def follow_obj_id(self):
        raise NotImplementedError()

    def follow_cache(self):
        raise NotImplementedError()

    def follow(self, user_id):
        from topdish import model

        follow = model.UserFollow.factory(user_id, 
                                          self.follow_type(), 
                                          self.follow_obj_id())
        if not follow:
            raise Exception('could not create follow object, check foreign keys')

        if follow.newly_created():
            num_follow_name = self.num_follows_attr()
            setattr(self, num_follow_name, getattr(self, num_follow_name) + 1)

            self.get_session().commit()

        cache = self.follow_cache()
        cache.add(user_id, self)

        return follow

    def followers(self):
        return self.follow_cache().get_data()

class Flaggable(object):
    def num_flags_attr(self):
        raise NotImplementedError()

    def flag_type(self):
        raise NotImplementedError()

    def flag_obj_id(self):
        raise NotImplementedError()

    def flag_cache(self):
        raise NotImplementedError()

    def flag(self, user_id):
        from topdish import model

        flag = model.UserFlag.factory(user_id, self.flag_type(), self.flag_obj_id())

        if flag.newly_created():
            num_flags_name = self.num_flags_attr()
            setattr(self, num_flags_name, getattr(self, num_flags_name) + 1)

        self.get_session().commit()

        cache = self.flag_cache()
        return flag

    def flags(self):
        return self.flag_cache().get_data()
