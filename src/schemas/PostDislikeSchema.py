from main import ma
from models.PostDislike import PostDislike
from schemas.PostSchema import PostSchema
from schemas.UserSchema import UserSchema

class PostDislikeSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = PostDislike

    post = ma.Nested(PostSchema)
    user = ma.Nested(UserSchema)
    created_at = ma.DateTime()

post_dislike_schema = PostDislikeSchema()
post_dislikes_schema = PostDislikeSchema(many=True)