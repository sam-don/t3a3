from main import db
from flask import Blueprint
from datetime import datetime

db_commands = Blueprint("db-custom", __name__)

@db_commands.cli.command("drop")
def drop_db():
    db.drop_all()
    db.engine.execute("DROP TABLE IF EXISTS alembic_version;")
    print("Tables deleted")

@db_commands.cli.command("seed")
def seed_db():
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