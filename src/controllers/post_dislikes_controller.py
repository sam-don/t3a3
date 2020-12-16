from flask import Blueprint, request, jsonify, abort, current_app, Response
from flask_jwt_extended import jwt_required
from flask_migrate import current
from services.auth_service import verify_user
from models.PostLike import PostLike
from models.PostDislike import PostDislike
from models.Post import Post
from schemas.PostDislikeSchema import post_dislike_schema
from main import db
from datetime import datetime


post_dislikes = Blueprint('post_dislikes', __name__, url_prefix="/posts/<int:post_id>/dislike")

@post_dislikes.route("/", methods=["POST"])
@jwt_required
@verify_user
def post_like_create(user, post_id):
    post = Post.query.filter_by(id=post_id).first()

    if not post:
        return abort(401, description="Invalid post")

    already_liked = PostLike.query.filter_by(user_id=user.id, post_id=post_id)
    
    if already_liked.count() > 0:
        abort(401, description="User has already liked this post")

    already_disliked = PostDislike.query.filter_by(user_id=user.id, post_id=post_id)
    
    if already_disliked.count() > 0:
        abort(401, description="User has already disliked this post")

    new_post_dislike = PostDislike()
    new_post_dislike.created_at = datetime.now()
    new_post_dislike.post_id = post_id
    user.post_dislike.append(new_post_dislike)
    post.post_dislike.append(new_post_dislike)
    post.total_dislikes = post.total_dislikes + 1
    post.updated_at = datetime.now()
    db.session.commit()

    return jsonify(post_dislike_schema.dump(new_post_dislike))
