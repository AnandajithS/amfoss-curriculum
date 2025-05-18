import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pokemon.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000'; // or your deployed backend URL

  // Register user
static Future<Map<String, dynamic>?> registerUser(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);

    } else {
      // handle errors based on response body if needed
      return null;
    }
  }

  // Login user
  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
  final url = Uri.parse('$baseUrl/login');
  final response = await http.post(url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    // decode JSON user data
    return jsonDecode(response.body);
  } else {
    return null;  // login failed
  }
}


  // Fetch Pokemon details
  static Future<Map<String, dynamic>?> fetchPokemonDetails(int id) async {
    final url = Uri.parse('$baseUrl/pokemon/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

static Future<bool> saveCaptureToBackend(Pokemon pokemon) async {
      final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      // User not logged in
      return false;  // tell caller that capture failed due to no user
    }

    final url = Uri.parse('$baseUrl/capture'); // fix URL to use baseUrl

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'pokemon_id': pokemon.id,
      }),
    );

    return response.statusCode == 201; 
}

static Future<List<Pokemon>> getCapturedPokemons(int userId) async {
  final url = Uri.parse('$baseUrl/captured/$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<dynamic> capturedIds = data['captured_pokemon'];
    print('Captured IDs from backend: $capturedIds'); // <--- print here


    // Map each id to a Future of fetchPokemonDetails
    var futures = capturedIds.map((id) => fetchPokemonDetails(id));
    print(futures);

    // Await all futures together
    final detailsList = await Future.wait(futures);

    // Filter nulls and build Pokemon list
    List<Pokemon> pokemons = detailsList
      .where((details) => details != null)
      .map((details) => Pokemon.fromJson(details!))
      .toList();

    return pokemons;
  } else {
    return [];
  }
}
// GET all users
static Future<List<Map<String, dynamic>>> getAllUsers() async {
  final res = await http.get(Uri.parse('$baseUrl/users'));
  if (res.statusCode == 200) {
    final List<dynamic> data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception("Failed to fetch users");
  }
}

// POST trade
static Future<bool> tradePokemon(int pokemonId, int toUserId) async {
  final prefs = await SharedPreferences.getInstance();
  final fromUserId = prefs.getInt('userId');

  if (fromUserId == null) return false;

  final res = await http.post(
    Uri.parse('$baseUrl/trade'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'pokemon_id': pokemonId,
    }),
  );

  

  return res.statusCode == 200;
}



}
