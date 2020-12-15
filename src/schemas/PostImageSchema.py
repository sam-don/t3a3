from main import ma
from models.PostImage import PostImage
from marshmallow.validate import Length

class PostImageSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = PostImage

    filename = ma.String(required=True, validate=Length(min=1))

post_image_schema = PostImageSchema()