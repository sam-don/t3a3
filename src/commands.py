from main import db
from flask import Blueprint
from datetime import datetime
from models.Post import Post
from schemas.PostSchema import posts_schema
from schemas.UserSchema import users_schema
from schemas.PostLikeSchema import post_likes_schema
from schemas.PostDislikeSchema import post_dislikes_schema
from schemas.PostImageSchema import post_images_schema
import json

db_commands = Blueprint("db-custom", __name__)

@db_commands.cli.command("drop")
def drop_db():
    # Drop all tables from database
    
    db.drop_all()
    db.engine.execute("DROP TABLE IF EXISTS alembic_version;")
    print("Tables deleted")

@db_commands.cli.command("seed")
def seed_db():
    # Seed database with example data

    from models.Post import Post
    from models.User import User
    from main import bcrypt
    from faker import Faker
    import random

    faker = Faker()
    users = []

    for i in range(5):
        user = User()
        user.email =  f"test{i}@test.com"
        user.name = faker.name()
        user.password = bcrypt.generate_password_hash("123456").decode("utf-8")
        user.created_at = datetime.now()
        db.session.add(user)
        users.append(user)
    
    db.session.commit()

    for i in range(20):
        post = Post()
        post.caption = faker.catch_phrase()
        post.created_at = datetime.now()
        post.updated_at = datetime.now()
        post.total_likes = 0
        post.total_comments = 0
        post.user_id = random.choice(users).id
        db.session.add(post)        
    
    db.session.commit()
    print("Tables seeded")

@db_commands.cli.command("dump")
def dump_db():

    # Exports all tables in the database as a dbdump.json file in the projects root directory

    tables = ['posts', 'users', 'post_likes', 'post_dislikes', 'post_images']
    schemas = [posts_schema, users_schema, post_likes_schema, post_dislikes_schema, post_images_schema]

    file = open('dbdump.json', 'w')
    file.close()

    for index, table in enumerate(tables):
        query = db.engine.execute(f'SELECT * FROM {table}')
        data = schemas[index].dump(query)

        data = json.dumps(data)

        file = open('dbdump.json', 'a')
        file.write(data)
        file.close()

