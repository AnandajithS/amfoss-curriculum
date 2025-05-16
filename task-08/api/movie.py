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

print(api_key)

def fetch_details(url):
    try:
        res = requests.get(url, headers=headers)
        res.raise_for_status()
        return res.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching {url} --> {e}")
        return None

movie = Blueprint('movie',__name__)
@movie.route('/api/movie/<id>', methods=['GET'])
def movie_details(id):
    
    movie_url = f"https://api.themoviedb.org/3/movie/{id}?api_key={api_key}"
    credits_url = f"https://api.themoviedb.org/3/movie/{id}/credits?api_key={api_key}"

  

    movie_info = fetch_details(movie_url)
    credits_info=fetch_details(credits_url)


    cast = []
    if 'cast' in credits_info:
        # Get top 5 cast members
        for person in credits_info['cast'][:5]:
            cast.append({
                "name": person["name"],
                "character": person["character"],
                "profile_path": f"https://image.tmdb.org/t/p/w185{person['profile_path']}" if person["profile_path"] else None
            })

    data = {
        "title": movie_info["title"],
        "poster_path": f"https://image.tmdb.org/t/p/w500{movie_info['poster_path']}" if movie_info["poster_path"] else None,
        "overview": movie_info["overview"],
        "release_date": movie_info["release_date"],
        "cast": cast
    }

    return jsonify(data)



