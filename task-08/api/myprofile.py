import os
import requests
from dotenv import load_dotenv
from flask import Blueprint, jsonify
from auth import User
from reviews import Review
from reviews import db
from watchlist import Watchlist

load_dotenv()
api_key=os.getenv("TMDB_API_KEY")
profile = Blueprint('profile', __name__)

@profile.route('/api/profile/<int:user_id>', methods=['GET'])
def get_user_profile(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    reviews = Review.query.filter_by(user_id=user_id).all()

    reviews_data = [
        {
            "movie_id": review.movie_id,
            "rating": review.rating,
            "comment": review.comment
        } for review in reviews
    ]

    watchlist_items = Watchlist.query.filter_by(user_id=user_id).all()
    movie_ids = [item.movie_id for item in watchlist_items]
    watchlist_data = []

    for movie_id in movie_ids:
        response = requests.get(
            f"https://api.themoviedb.org/3/movie/{movie_id}",
            params={"api_key": api_key}
        )
        if response.status_code == 200:
            data = response.json()
            watchlist_data.append({
                "id": data["id"],
                "title": data["title"],
                "poster_path": data["poster_path"]
            })

    return jsonify({
        "username": user.username,
        "email": user.email,
        "reviews": reviews_data,
        "watchlist": watchlist_data
    })