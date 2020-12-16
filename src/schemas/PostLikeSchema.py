from main import ma
from models.PostLike import PostLike
from schemas.PostSchema import Post, PostSchema
from schemas.UserSchema import UserSchema

class PostLikeSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = PostLike

    post = ma.Nested(PostSchema)
    user = ma.Nested(UserSchema)
    created_at = ma.DateTime()

post_like_schema = PostLikeSchema()