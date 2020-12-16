from main import db

class PostImage(db.Model):
    __tablename__ = "post_images"

    id = db.Column(db.Integer, primary_key=True)
    filename = db.Column(db.String(), nullable=False, unique=True)
    post_id = db.Column(db.Integer, db.ForeignKey("posts.id"), nullable=False)

    def __repr__(self):
        return f"<PostImage {self.id}>"
