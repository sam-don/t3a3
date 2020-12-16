from main import db
from models.PostImage import PostImage
from models.PostLike import PostLike

class Post(db.Model):
    __tablename__ = "posts"

    id = db.Column(db.Integer, primary_key=True)
    caption = db.Column(db.String())
    created_at = db.Column(db.DateTime(), nullable=False)
    updated_at = db.Column(db.DateTime(), nullable=False)
    total_likes = db.Column(db.Integer)
    total_comments = db.Column(db.Integer)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    post_image = db.relationship("PostImage", backref="posts", uselist=False)
    post_like = db.relationship("PostLike", backref="posts")

    def __repr__(self):
        return f"<Post {self.id}>"