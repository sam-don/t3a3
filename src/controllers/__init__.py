from controllers.auth_controller  import auth
from controllers.posts_controller import posts
from controllers.post_images_controller import post_images
from controllers.post_likes_controller import post_likes

registerable_controllers = [
    auth,
    posts,
    post_images,
    post_likes
]