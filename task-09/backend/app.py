from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from models import db
from routes import api

import os

basedir = os.path.abspath(os.path.dirname(__file__))
db_path = os.path.join(basedir, 'pokedex.db')


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{db_path}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)
app.register_blueprint(api)

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
