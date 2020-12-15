from main import ma
from models.Post import Post
from marshmallow.validate import Length
from schemas.UserSchema import UserSchema

class PostSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Post
    
    caption = ma.String()
    created_at = ma.DateTime()
    updated_at = ma.DateTime()
    total_likes = ma.Integer()
    total_comments = ma.Integer()
    user = ma.Nested(UserSchema)

post_schema = PostSchema()
posts_schema = PostSchema(many=True)
