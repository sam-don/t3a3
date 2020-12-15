from types import ClassMethodDescriptorType
from models.Post import Post
from models.User import User
from main import db
from schemas.PostSchema import post_schema, posts_schema
from flask import Blueprint, request, jsonify, abort
from flask_jwt_extended import jwt_required, get_jwt_identity
from services.auth_service import verify_user
from sqlalchemy.orm import joinedload
from datetime import datetime

posts = Blueprint('posts', __name__, url_prefix="/posts")

@posts.route("/", methods=["GET"])
def post_index():
    # Retrieve all posts
    posts = Post.query.options(joinedload("user")).all()
    return jsonify(posts_schema.dump(posts))

@posts.route("/", methods=["POST"])
@jwt_required
@verify_user
def post_create(user):
    #Create a new post
    post_fields = post_schema.load(request.json)

    new_post = Post()
    new_post.caption = post_fields["caption"]
    new_post.created_at = datetime.now()
    new_post.updated_at = datetime.now()
    new_post.total_comments = 0
    new_post.total_likes = 0

    user.posts.append(new_post)

    db.session.commit()
    
    return jsonify(post_schema.dump(new_post))

@posts.route("/<int:id>", methods=["GET"])
def post_show(id):
    # Return a single post
    post = Post.query.get(id)
    return jsonify(post_schema.dump(post))

@posts.route("/<int:id>", methods=["PUT", "PATCH"])
@jwt_required
@verify_user
def post_update(user, id):
    # Update a post
    post_fields = post_schema.load(request.json)

    post = Post.query.filter_by(id=id, user_id=user.id)

    if post.count() != 1:
        return abort(401, description="Unauthorized to update this post")

    post_fields['updated_at'] = datetime.now()
    post.update(post_fields)
    db.session.commit()

    return jsonify(post_schema.dump(post[0]))

@posts.route("/<int:id>", methods=["DELETE"])
@jwt_required
@verify_user
def post_delete(user, id):
    # Delete a post
    post = Post.query.filter_by(id=id, user_id=user.id).first()

    if not post:
        return abort(400, description="Unauthorized to update this post")
    
    db.session.delete(post)
    db.session.commit()
    return jsonify(post_schema.dump(post))