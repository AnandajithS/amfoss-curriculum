import 'dart:convert';
import 'package:http/http.dart' as http;

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final String description;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.description,
  });

factory Pokemon.fromJson(Map<String, dynamic> json) {
  return Pokemon(
    id: json['id'],
    name: json['name'],
    imageUrl: json['image'] ?? '', // from your Flask backend
    types: List<String>.from(json['types'] ?? []),
    description: json['description'] ?? 'No description available',
  );
}

}

  


class PokemonService {
  static Future<List<Pokemon>> fetchPokemonList() async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=50'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      List<Pokemon> pokemonList = [];

      for (var result in results) {
        final detailRes = await http.get(Uri.parse(result['url']));
        final detailData = json.decode(detailRes.body);

        final speciesUrl = detailData['species']['url'];
        final speciesRes = await http.get(Uri.parse(speciesUrl));
        final speciesData = json.decode(speciesRes.body);

        // Get the English flavor text
        final flavorTexts = speciesData['flavor_text_entries'] as List;
        final englishEntry = flavorTexts.firstWhere(
          (entry) => entry['language']['name'] == 'en',
          orElse: () => {'flavor_text': 'No description available.'},
        );
        final description = (englishEntry['flavor_text'] as String).replaceAll('\n', ' ').replaceAll('\f', ' ');

         pokemonList.add(Pokemon(
    id: detailData['id'],
    name: detailData['name'],
    imageUrl: detailData['sprites']['front_default'],
    types: List<String>.from(detailData['types'].map((t) => t['type']['name'])),
    description: description,
  ));
      }

      return pokemonList;
    } else {
      throw Exception('Failed to load Pokémon');
    }
  }
  static Future<Pokemon> fetchPokemonById(int id) async {
  final detailRes = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
  final detailData = json.decode(detailRes.body);

  final speciesUrl = detailData['species']['url'];
  final speciesRes = await http.get(Uri.parse(speciesUrl));
  final speciesData = json.decode(speciesRes.body);

  // Get the English flavor text
  final flavorTexts = speciesData['flavor_text_entries'] as List;
  final englishEntry = flavorTexts.firstWhere(
    (entry) => entry['language']['name'] == 'en',
    orElse: () => {'flavor_text': 'No description available.'},
  );
  final description = (englishEntry['flavor_text'] as String).replaceAll('\n', ' ').replaceAll('\f', ' ');

    return Pokemon(
    id: detailData['id'],
    name: detailData['name'],
    imageUrl: detailData['sprites']['front_default'],
    types: List<String>.from(detailData['types'].map((t) => t['type']['name'])),
    description: description,
  );
}

}
