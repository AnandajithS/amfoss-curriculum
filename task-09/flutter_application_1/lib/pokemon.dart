import 'dart:convert';
import 'package:http/http.dart' as http;

class Pokemon {
  final String name;
  final String imageUrl;
  final int id;
  final List<String> types;

  Pokemon({required this.name, required this.imageUrl, required this.id, required this.types});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      imageUrl: json['sprites']['front_default'],
      id:json['id'],
      types: (json['types'] as List)
        .map((type) => type['type']['name'].toString())
        .toList()
    );
  }
}


class PokemonService {
  static Future<List<Pokemon>> fetchPokemonList() async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=20'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      List<Pokemon> pokemonList = [];

      for (var result in results) {
        final detailRes = await http.get(Uri.parse(result['url']));
        final detailData = json.decode(detailRes.body);
        pokemonList.add(Pokemon.fromJson(detailData));
      }

      return pokemonList;
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }
}



