from controllers.auth_controller  import auth
from controllers.posts_controller import posts
from controllers.post_images_controller import post_images
from controllers.post_likes_controller import post_likes
from controllers.post_dislikes_controller import post_dislikes

registerable_controllers = [
    auth,
    posts,
    post_images,
    post_likes,
    post_dislikes
]