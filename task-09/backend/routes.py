from flask import Blueprint, request, jsonify
from models import db, User, CapturedPokemon
from werkzeug.security import generate_password_hash, check_password_hash
import requests
import traceback  

api = Blueprint('api', __name__)

# REGISTER
@api.route('/register', methods=['POST'])
def register():
    data = request.json
    if User.query.filter_by(email=data['email']).first():
        return jsonify({"message": "User already exists"}), 400

    hashed_pw = generate_password_hash(data['password'])
    new_user = User(name=data['name'], email=data['email'], password_hash=hashed_pw)
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"message": "User registered successfully!",       
        "id": new_user.id,
        "name": new_user.name,
        "email": new_user.email }), 201

# LOGIN
@api.route('/login', methods=['POST'])
def login():
    data = request.json
    user = User.query.filter_by(email=data['email']).first()

    if user and check_password_hash(user.password_hash, data['password']):
        return jsonify({
            "id": user.id,
            "name": user.name,
            "email": user.email
        }), 200
    return jsonify({"message": "Invalid credentials"}), 401

# CAPTURE
@api.route('/capture', methods=['POST'])
def capture():
    data = request.json
    user = User.query.get(data['user_id'])
    if not user:
        return jsonify({"message": "User not found"}), 404

    capture = CapturedPokemon(user_id=data['user_id'], pokemon_id=data['pokemon_id'])
    db.session.add(capture)
    db.session.commit()
    return jsonify({"message": "Pokémon captured!"}), 201

# GET CAPTURED
@api.route('/captured/<int:user_id>', methods=['GET'])
def get_captured(user_id):
    user = User.query.get(user_id)
    if not user:
        return jsonify({"message": "User not found"}), 404

    captured = CapturedPokemon.query.filter_by(user_id=user_id).all()
    pokemon_list = [p.pokemon_id for p in captured]
    return jsonify({"captured_pokemon": pokemon_list})

@api.route('/pokemon/<name_or_id>', methods=['GET'])
def get_pokemon_details(name_or_id):
    # Get basic Pokémon data
    poke_url = f'https://pokeapi.co/api/v2/pokemon/{name_or_id}'
    species_url = f'https://pokeapi.co/api/v2/pokemon-species/{name_or_id}'

    poke_res = requests.get(poke_url)
    species_res = requests.get(species_url)

    if poke_res.status_code != 200 or species_res.status_code != 200:
        return jsonify({"error": "Pokémon not found"}), 404

    poke_data = poke_res.json()
    species_data = species_res.json()

    # Get English description
    flavor_text_entries = species_data["flavor_text_entries"]
    description = next(
        (entry["flavor_text"].replace('\n', ' ').replace('\f', ' ')
         for entry in flavor_text_entries if entry["language"]["name"] == "en"),
        "No description available."
    )

    result = {
        "id": poke_data["id"],
        "name": poke_data["name"],
        "abilities": [a["ability"]["name"] for a in poke_data["abilities"]],
        "types": [t["type"]["name"] for t in poke_data["types"]],
        "stats": {s["stat"]["name"]: s["base_stat"] for s in poke_data["stats"]},
        "image": poke_data.get("sprites", {}).get("front_default", None),
        "description": description
    }

    return jsonify(result)

@api.route('/trade', methods=['POST'])


@app.route('/trade', methods=['POST'])
def trade_pokemon():
    data = request.json
    from_user_id = data.get('from_user_id')
    to_user_id = data.get('to_user_id')
    pokemon_id = data.get('pokemon_id')

    if from_user_id == to_user_id:
        return jsonify({'error': "You can't trade Pokémon to yourself"}), 400

    from_user = User.query.get(from_user_id)
    to_user = User.query.get(to_user_id)

    if not from_user or not to_user:
        return jsonify({'error': 'User not found'}), 404

    # Check if the from_user owns this Pokémon
    captured = CapturedPokemon.query.filter_by(user_id=from_user_id, pokemon_id=pokemon_id).first()
    if not captured:
        return jsonify({'error': "You don't own this Pokémon"}), 403

    try:
        # Transfer: remove from from_user
        db.session.delete(captured)
        db.session.commit()

        # Add to to_user
        new_capture = CapturedPokemon(user_id=to_user_id, pokemon_id=pokemon_id)
        db.session.add(new_capture)
        db.session.commit()

        return jsonify({'message': f"Pokémon traded successfully to user {to_user.name}!"}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f"Trade failed: {str(e)}"}), 500
