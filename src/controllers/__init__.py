from controllers.auth_controller  import auth
from controllers.posts_controller import posts
from controllers.post_images_controller import post_images

registerable_controllers = [
    auth,
    posts,
    post_images
]