import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'type_colors.dart';
import 'capture.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_routes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'trade_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<List<Pokemon>>? capturedFuture;
  int? userId;
  String? username;

  @override
  void initState() {
    super.initState();
    capturedFuture = loadUserAndCaptured();
  }

  Future<List<Pokemon>> loadUserAndCaptured() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    username = prefs.getString('username');

    if (userId != null) {
      return await ApiService.getCapturedPokemons(userId!);
    } else {
      print("No userId found in SharedPreferences");
      return [];
    }
  }

  void handleCapture(Pokemon p) async {
    if (userId == null) {
      print("User ID is null, cannot capture");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/capture'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'pokemon_id': p.id}),
      );

      if (response.statusCode == 201) {
        setState(() {
          capturedFuture = loadUserAndCaptured();
        });
      } else {
        print("Failed to capture: ${response.body}");
      }
    } catch (e) {
      print("Error during capture API call: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Captured Pokémon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<List<Pokemon>>(
                future: capturedFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading Pokémon'));
                  }
                  final pokemons = snapshot.data ?? [];
                  if (pokemons.isEmpty) {
                    return Center(child: Text('No captured Pokémon'));
                  }

                  return ListView.builder(
                    itemCount: pokemons.length,
                    itemBuilder: (context, index) {
                      final poke = pokemons[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: poke.imageUrl != null && poke.imageUrl!.isNotEmpty
                              ? Image.network(poke.imageUrl!, width: 50)
                              : Icon(Icons.question_mark, size: 50),
                          title: Text(poke.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Wrap(
                            spacing: 6,
                            children: poke.types.map((type) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: typeColors[type] ?? Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(type.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 10)),
                              );
                            }).toList(),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TradePage(pokemon: poke, onTradeSuccess: () {setState(() {
          capturedFuture = loadUserAndCaptured(); // 👈 refresh the list
                                    });}),
                                    ),
                                  );
                            },
                            child: Text("Trade"),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            ElevatedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getInt('userId');
                if (id == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("You must be logged in to capture Pokémon!"))
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CapturePage(onCapture: handleCapture)),
                );
              },
              icon: Icon(Icons.catching_pokemon),
              label: Text("Capture Pokémon"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
