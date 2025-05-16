from flask import Blueprint, request, jsonify
from flask_sqlalchemy import SQLAlchemy
import os
import requests
from dotenv import load_dotenv
load_dotenv()
api_key = os.getenv("TMDB_API_KEY")

from auth import db, User  # use shared db instance from auth

watchlist = Blueprint('watchlist', __name__)

# Define the Watchlist model here
class Watchlist(db.Model):
    __tablename__ = 'watchlist'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    movie_id = db.Column(db.Integer, nullable=False)
    poster_path = db.Column(db.String(200), nullable=False)

    user = db.relationship('User', backref='watchlist')


# Route to get all watchlist items for a user
@watchlist.route('/api/watchlist/<int:user_id>', methods=['GET'])
def get_watchlist(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({'message': 'User not found'}), 404

    watchlist_items = Watchlist.query.filter_by(user_id=user_id).all()
    return jsonify({'watchlist_items': [{"movie_id": item.movie_id} for item in watchlist_items]})



# Route to add a movie to watchlist
@watchlist.route('/api/watchlist', methods=['POST'])
def add_to_watchlist():
    data = request.json
    user_id = data.get('user_id')
    movie_id = data.get('movie_id')

    if not user_id or not movie_id:
        return jsonify({'message': 'Missing user_id or movie_id'}), 400

    existing = Watchlist.query.filter_by(user_id=user_id, movie_id=movie_id).first()
    if existing:
        return jsonify({'message': 'Movie already in watchlist'}), 400
    
    poster_path = None
    response = requests.get(f"https://api.themoviedb.org/3/movie/{movie_id}", params={"api_key": api_key})
    if response.status_code == 200:
        poster_path = response.json().get("poster_path")
    new_item = Watchlist(user_id=user_id, movie_id=movie_id, poster_path=poster_path)
    db.session.add(new_item)
    db.session.commit()

    return jsonify({'message': 'Movie added to watchlist'}), 201


# Route to remove a movie from watchlist
@watchlist.route('/api/watchlist', methods=['DELETE'])
def remove_from_watchlist():
    data = request.json
    user_id = data.get('user_id')
    movie_id = data.get('movie_id')

    if not user_id or not movie_id:
        return jsonify({'message': 'Missing user_id or movie_id'}), 400

    item = Watchlist.query.filter_by(user_id=user_id, movie_id=movie_id).first()
    if not item:
        return jsonify({'message': 'Movie not found in watchlist'}), 404

    db.session.delete(item)
    db.session.commit()

    return jsonify({'message': 'Movie removed from watchlist'}), 200
