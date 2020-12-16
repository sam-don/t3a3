from flask import Blueprint, request, jsonify, abort, current_app, Response
from flask_jwt_extended import jwt_required
from flask_migrate import current
from services.auth_service import verify_user
from models.PostImage import PostImage
from models.Post import Post
from schemas.PostImageSchema import post_image_schema, post_images_schema
import boto3, uuid
from main import db
from pathlib import Path
from datetime import datetime

post_images = Blueprint("post_images", __name__, url_prefix="/posts/<int:post_id>/image")

@post_images.route("/", methods=["GET"])
def post_image_index(post_id):
    post_images = PostImage.query.filter_by(post_id=post_id)
    return jsonify(post_images_schema.dump(post_images))


@post_images.route("/", methods=["POST"])
@jwt_required
@verify_user
def post_image_create(user, post_id):
    post = Post.query.filter_by(id=post_id, user_id=user.id).first()

    if not post:
        return abort(401, description="Invalid post")

    if "image" not in request.files:
        return abort(400, description="No image")

    image = request.files["image"]

    if Path(image.filename).suffix not in [".png", ".jpeg", ".jpg"]:
        return abort(400, description="Invalid file type")

    filename = f"{uuid.uuid4().hex}{Path(image.filename).suffix}"
    bucket = boto3.resource("s3").Bucket(current_app.config["AWS_S3_BUCKET"])
    key = f"post_images/{filename}"

    bucket.upload_fileobj(image, key)

    if not post.post_image:
        new_image = PostImage()
        new_image.filename = filename
        post.post_image = new_image
        post.updated_at = datetime.now()
        db.session.commit()
    else:
        return abort(401, description="Image already exists")

    return jsonify(post_image_schema.dump(new_image))


@post_images.route("/<string:filename>", methods=["GET"])
def post_image_show(post_id, filename):
    post_image = PostImage.query.filter_by(filename=filename).first()

    if not post_image:
        return abort(401, description="Invalid post")

    bucket = boto3.resource("s3").Bucket(current_app.config["AWS_S3_BUCKET"])
    filename = post_image.filename
    file_obj = bucket.Object(f"post_images/{filename}").get()

    print(file_obj)

    return Response(
        file_obj["Body"].read(),
        mimetype="image/*",
        headers={"Content-Disposition": "attachment;filename=image"}
    )


@post_images.route("/<int:id>", methods=["DELETE"])
@jwt_required
@verify_user
def post_image_delete(user, post_id, id):
    post = Post.query.filter_by(id=post_id, user_id=user.id).first()

    if not post:
        return abort(401, description="Invalid post")
    
    if post.post_image:
        bucket = boto3.resource("s3").Bucket(current_app.config["AWS_S3_BUCKET"])
        filename = post.post_image.filename

        bucket.Object(f"post_images/{filename}").delete()

        db.session.delete(post.post_image)
        db.session.commit()

    return ("", 204)