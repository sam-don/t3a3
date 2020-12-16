from flask import Blueprint, request, jsonify, abort, current_app, Response
from flask_jwt_extended import jwt_required
from flask_migrate import current
from services.auth_service import verify_user
from models.PostLike import PostLike
from models.Post import Post
from schemas.PostLikeSchema import post_like_schema
from main import db
from datetime import datetime


post_likes = Blueprint('post_likes', __name__, url_prefix="/posts/<int:post_id>/like")

@post_likes.route("/", methods=["POST"])
@jwt_required
@verify_user
def post_like_create(user, post_id):
    post = Post.query.filter_by(id=post_id).first()

    if not post:
        return abort(401, description="Invalid post")

    already_liked = PostLike.query.filter_by(user_id=user.id, post_id=post_id)
    
    if already_liked.count() > 0:
        abort(401, description="User has already liked this post")

    new_post_like = PostLike()
    new_post_like.created_at = datetime.now()
    # new_post_like.post_id = post_id
    user.post_like.append(new_post_like)
    post.post_like.append(new_post_like)
    post.total_likes = post.total_likes + 1
    db.session.commit()

    return jsonify(post_like_schema.dump(new_post_like))
