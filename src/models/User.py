from main import db
from models.Post import Post

class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(), nullable=False)
    email = db.Column(db.String(), nullable=False, unique=True)
    password = db.Column(db.String(), nullable=False)
    created_at = db.Column(db.DateTime(), nullable=False)
    posts = db.relationship("Post", backref="user", lazy="dynamic")
    post_like = db.relationship("PostLike", backref="user")
    post_dislike = db.relationship("PostDislike", backref="user")


    def __repr__(self):
        return f"<User {self.email}>"