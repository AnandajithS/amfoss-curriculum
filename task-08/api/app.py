import os
from flask import Flask
from flask_cors import CORS

from extensions import db  
from home import home
from auth import auth
from movie import movie
from reviews import reviews
from watchlist import watchlist
from myprofile import profile
from search import search

basedir = os.path.abspath(os.path.dirname(__file__))
app = Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = f"sqlite:///{os.path.join(basedir, 'users.db')}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

app.register_blueprint(home)
app.register_blueprint(auth)
app.register_blueprint(movie)
app.register_blueprint(reviews)
app.register_blueprint(watchlist)
app.register_blueprint(profile)
app.register_blueprint(search)


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
