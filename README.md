# T3A3 

## Implement a System with Data and Application Layers

For this assessment I have chosen to implement an Instagram-like app with and update to add some revolutionary new features. Users are now able to create posts that don't necessarily have to have some form of media such as a photo or video attached! Plain text is perfectly acceptable, and images can still be added to a post after if the user wishes to. 

The next feature which was added was to give users the ability to either like OR dislike a post! This new feature may also be used in the future to gather data and develop better algorithms to show users content that they really want to see. 

### Dependencies

- Python 3.8+
- SQLAlchemy
- Marshmallow
- PyJWT
- Flask-Migrate
- Faker
- Boto3
- Bcrypt

### Installation

1. Install Python 3.8, python3-pip and python3.8-venv

    `sudo apt install python3.8, python3.8-venv, python3-pip`

2. Clone GitHub repo to local project folder

    `git clone https://github.com/sam-don/t3a3.git`

3. Create and activate virtual environment

    `python3.8 -m venv venv`
    
    `source venv/bin/activate`

4. Install dependencies

    `pip install -r requirements.txt`

#### Setting up PostgreSQL database

1. Install PostgreSQL on database host machine
   
2. Open PostgreSQL logged in as admin/superuser (generally postgresql)
   
3. Create new database
   
    `CREATE DATABASE t3a3`

4. Create new user

    `CREATE ROLE flask`

5. Grant all privileges on new database to the new user

    `GRANT ALL PRIVILEGES ON DATABASE t3a3 TO flask`

6. Add password for new user

    `ALTER USER flask WITH ENCRYPTED PASSWORD '<PASSWORD>'`

#### Running the app

1. Create a .env file in the root directory and add the necessary variables (follow env_example.txt)

2. Export the environment variables `FLASK_APP` and `FLASK_ENV` if not done through the .env file

3. Initialise database migrations

    `flask db init`

4. Run migrations to update database

    `flask db upgrade`

5. Run flask app

    `flask run`