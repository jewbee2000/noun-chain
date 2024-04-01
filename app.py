"""
Author: Walter Teitelbaum
File: app.py
Date: 4/1/2024
Modified: 4/1/2024

Description: This file contains the code for the Flask application. It includes the routes for the login, logout,
and protected pages. The login route checks the username and password against the users dictionary and logs the user
in if the credentials are correct. The protected route is only accessible to logged in users. The logout route logs
the user out. The register route allows users to register by creating a new user in the users dictionary."""

from flask import Flask, request, session, redirect, url_for
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.config['SECRET_KEY'] = 'smelly-louis'  # TODO: Change this to something more secure

login_manager = LoginManager()
login_manager.init_app(app)

# A dictionary to store users as if it were a database
users = {}


class User(UserMixin):
    def __init__(self, id, username, password_hash):
        self.id = id
        self.username = username
        self.password_hash = password_hash


@login_manager.user_loader
def load_user(user_id):
    user = users.get(user_id)
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
    return redirect(url_for('login'))


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
                return redirect(url_for('protected'))
    return 'Invalid username or password'


@app.route('/logout')
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


if __name__ == "__main__":
    app.run(debug=True)
