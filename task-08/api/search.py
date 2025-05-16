import requests
from flask import request
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

search = Blueprint('search',__name__)
@search.route('/api/search', methods=['GET'])
def search_data():
    term = request.args.get("term", "")
    if not term:
        return jsonify({"error": "Missing search term"}), 400
    search_url = f"https://api.themoviedb.org/3/search/movie?api_key={api_key}&query={term}"
    
    search_data=safe_get(search_url)

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
        "Search Results": extract_info(search_data),
    }

    return jsonify(data)

