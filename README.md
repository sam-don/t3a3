# T3A3 

## Implement a System with Data and Application Layers

For this assessment I have chosen to implement an Instagram-like app with and update to add some revolutionary new features. Users are now able to create posts that don't necessarily have to have some form of media such as a photo or video attached! Plain text is perfectly acceptable, and images can still be added to a post after if the user wishes to. 

The next feature which was added was to give users the ability to either like OR dislike a post! This new feature may also be used in the future to gather data and develop better algorithms to show users content that they really want to see. 

### Reports

#### Analysis of privacy and security concerns

Given the social media aspect of this application, there are many important privacy and security concerns that need to be taken into consideration. As it is now, this application does not allow users to choose whether their posts are public or if they should only be accessible to either themselves or to a limited selection of users. Given that anything posted on this platform will be accessible by anyone, it is crucial that users are aware of this. Even better, it would be best to give users the ability to decide who will be allowed to see their posts. This needs to be implemented in such a way that malicious actors would not be able to access any data unless it is explicitly made public by the owner. The best solution for this would be to have all sensitive data stored on a private subnet, with no outside connection available apart from for the application itself. The use of an ORM protects against methods such as SQL injection, and it would also help considerably to validate data on the client side to prevent malicious activity. While passwords are hashed and stored securely, it would be best to instruct users on how to set up a secure password, and encourage or potentially even enforce two factor authentication, to prevent access from anyone that is not the user.

#### Professional, ethical and legal obligations

Given that this application is designed to allow users to share content with others, it is important that users understand what this means. On sign up, or even before that, it should be made clear that when content is made publically available, absolutely anyone can see it and is incredibly difficult and potentially impossible to undo and take out of the hands of anyone that saw and saved it. This should also be stated in the terms and conditions and include a clause that the platform can not be held liable in the event that a user has publically shared content that they wished to keep private. Despite this, the platform should still make best efforts to remove any copies of said content anywhere on the platform for the user. The terms and conditions of using this application should also state clearly that certain types of content are not allowed on the platform. This can include a range of sensitive content including cyber bullying, fake news, and traumatic photos or videos. The platform has an obligation to monitor the content that is shared on it and remove any content that breaches the terms and conditions, and to also warn and potentially remove the accounts that are infringing them. 

### Dependencies

- Python 3.8+
- SQLAlchemy
- Marshmallow
- PyJWT
- Flask-Migrate
- Faker
- Boto3
- Bcrypt

### Using the app

#### Installation

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

#### Seed the database

1. Run the following command to seed the database with some example posts and users
   
    `flask db-custom seed`

#### Dump database to file

1. Run the following command to dump the database into a `dbdump.json` file in the projects root directory

    `flask db-custom dump`

### Available Endpoints

#### posts

**GET /posts/**

    Returns all posts

  Note that for the purposes of this assignment, this endpoint actually returns a HTML page as it is currently. 
 To revert back to API functionality, line 20 of `posts_controller.py` can be commented out and line 19 can be uncommented.

**POST /posts/**

    Create a post - Authorisation required

    Input:
    - caption

**GET /posts/\<id>**

    Get a single post by id

**PUT/PATCH /posts/\<id>**

    Update a post - Authorisation required

    Input:
    - caption

**DELETE /posts/\<id>**

    Delete a post - Authorisation required

**POST /posts/\<id>/like/**

    Like a post - Authorisation required

**POST /posts/\<id>/dislike/**

    Dislike a post - Authorisation required

**GET /posts/\<id>/image**

    Get post image details, returns filename and id

**GET /posts/\<id>/image/\<filename>**

    Get post image

**DELETE /posts/\<id>/image/\<id>**

    Delete a post image

#### users

**POST /auth/register/**

    Register a new user

    Input:
    - email
    - name
    - password

**POST /auth/login/**

    Login existing user

    Input:
    - email
    - password