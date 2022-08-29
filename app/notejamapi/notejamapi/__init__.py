from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
from notejamapi.config import (
    Config,
    DevelopmentConfig,
    ProductionConfig,
    TestingConfig)
import os

from_env = {'production': ProductionConfig,
            'development': DevelopmentConfig,
            'testing': TestingConfig,
            'dbconfig': Config}

# @TODO use application factory approach
app = Flask(__name__)
app.config.from_object(from_env[os.environ.get('ENVIRONMENT', 'testing')])
db = SQLAlchemy(app)


@app.before_first_request
def create_tables():
    db.create_all()
