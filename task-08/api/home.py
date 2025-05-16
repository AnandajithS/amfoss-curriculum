import requests
import os
from dotenv import load_dotenv
from flask import jsonify, Blueprint

load_dotenv()
api_key=os.getenv("TMDB_API_KEY")


headers = {
    "accept": "application/json",
    "User-Agent": "Mozilla/5.0"
}

def safe_get(url):
    try:
        res = requests.get(url, headers=headers)
        res.raise_for_status()
        return res.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching {url}: {e}")
        return {"results": []}

home = Blueprint('home',__name__)
@home.route('/api/home', methods=['GET'])
def get_home_data():
    
    trending_url = f"https://api.themoviedb.org/3/trending/movie/day?api_key={api_key}"
    top_rated_url = f"https://api.themoviedb.org/3/movie/top_rated?api_key={api_key}"
    popular_url = f"https://api.themoviedb.org/3/movie/popular?api_key={api_key}"

    

    trending = safe_get(trending_url)
    top_rated = safe_get(top_rated_url)
    popular = safe_get(popular_url)

    # Send only a few items and only what's needed (like title, poster_path, id)
    def extract_info(movies):
        return [
            {
                "id": movie["id"],
                "title": movie["title"],
                "poster_path": movie["poster_path"]
            }
            for movie in movies["results"][:5]
        ]

    data = {
        "New and Trending": extract_info(trending),
        "Top Picks": extract_info(top_rated),
        "Recommendations": extract_info(popular)
    }

    return jsonify(data)

