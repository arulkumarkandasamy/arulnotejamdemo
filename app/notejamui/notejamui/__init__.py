from flask import Flask
from flask.ext.login import LoginManager
from flask.ext.mail import Mail

# @TODO use application factory approach
app = Flask(__name__)

app.config['WTF_CSRF_ENABLED'] = False

login_manager = LoginManager()
login_manager.login_view = "signin"
login_manager.init_app(app)

mail = Mail()
mail.init_app(app)

from notejamui import views
