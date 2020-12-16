from main import db
from datetime import datetime
from models.PostImage import PostImage
from models.PostLike import PostLike
from models.PostDislike import PostDislike

class Post(db.Model):
    __tablename__ = "posts"

    id = db.Column(db.Integer, primary_key=True)
    caption = db.Column(db.String())
    created_at = db.Column(db.DateTime(), nullable=False, default=datetime.now())
    updated_at = db.Column(db.DateTime(), nullable=False)
    total_likes = db.Column(db.Integer, nullable=False, default=0)
    total_dislikes = db.Column(db.Integer, nullable=False, default=0)
    total_comments = db.Column(db.Integer)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    post_image = db.relationship("PostImage", backref="posts", uselist=False)
    post_like = db.relationship("PostLike", backref="posts")
    post_dislike = db.relationship("PostDislike", backref="posts")

    def __repr__(self):
        return f"<Post {self.id}>"