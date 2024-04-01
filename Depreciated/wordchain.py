"""
Author: Walter Teitelbaum
File: wordchain.py
Date: 4/1/2024
Modified: 4/1/2024

Description: This file contains the code for the Flask application. It includes the routes for the login, logout,
and protected pages. The login route checks the username and password against the users dictionary and logs the user
in if the credentials are correct. The protected route is only accessible to logged in users. The logout route logs
the user out. The register route allows users to register by creating a new user in the users dictionary."""

from datetime import datetime
from flask import Flask, request
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.config['SECRET_KEY'] = 'smelly-louis'  # TODO: Change this to something more secure

login_manager = LoginManager()
login_manager.init_app(app)

# A dictionary to store users as if it were a database
users = {}

# A dictionary to store the games as if it were a database
games = {"04012024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1},
         "04022024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1},
         "04032024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1},
         "04042024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1},
         "04052024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1},
         "04062024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1},
         "04072024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1},
         "04082024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1},
         "04092024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1},
         "04102024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1},
         "04112024": {'from': 'dog', 'to': 'blade', 'steps': 6, 'expires': 1}}


class User(UserMixin):
    def __init__(self, id, username, password_hash):
        self.id = id
        self.username = username
        self.password_hash = password_hash
        self.stats = {"played": 0, "won": 0, "current_streak": 0, "max_streak": 0, "dist": [0, 0, 0, 0, 0, 0, 0]}


@login_manager.user_loader
def load_user(user_id):
    user = users.get(int(user_id))
    if user:
        return User(user_id, user['username'], user['password_hash'])


@app.route('/register', methods=['POST'])
# This function is used to register a new user by adding them to the users dictionary
def register():
    username = request.form.get('username')
    password = request.form.get('password')
    password_hash = generate_password_hash(password)
    user_id = len(users) + 1  # Generate a simple user_id
    users[user_id] = {'username': username, 'password_hash': password_hash}
    return 'User registered successfully. Please navigate to the login page to log in.'


@app.route('/login', methods=['POST'])
# This function is used to log a user in by checking the username and password against the users dictionary
def login():
    username = request.form.get('username')
    password = request.form.get('password')
    for user_id, user in users.items():
        if user['username'] == username:
            if check_password_hash(user['password_hash'], password):
                user_obj = User(user_id, username, user['password_hash'])
                login_user(user_obj)
                return "Logged in successfully."
    return 'Invalid username or password'


@app.route('/logout', methods=['GET', 'POST'])
# This function is used to log a user out by calling the logout_user function
@login_required
def logout():
    logout_user()
    return 'Logged out'


@app.route('/protected')
# This function is only accessible to logged-in users and displays the username of the logged-in user
@login_required
def protected():
    return 'Logged in as: ' + current_user.username


@app.route('/stats', methods=['GET'])
# This function returns the stats for the current user
@login_required
def stats():
    return current_user.stats


@app.route('/game', methods=['GET'])
# This function returns the game for the current date
def game():
    current_date = datetime.now()
    date_str = current_date.strftime("%m%d%Y")
    if date_str in games.keys():
        return games[date_str]
    else:
        return 'No game for today'


if __name__ == "__main__":
    app.run(host='localhost', port=5000, debug=True)
    # app.run(debug=True)
