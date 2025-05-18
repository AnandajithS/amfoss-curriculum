import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pokemon.dart';
import 'api_routes.dart';

class CapturePage extends StatefulWidget {
  final Function(Pokemon) onCapture;

  const CapturePage({super.key, required this.onCapture});

  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  Pokemon? randomPokemon;
  Pokemon? testpokemon;
  bool isLoading = true;
  String userGuess = '';
  String message = '';
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    fetchRandomPokemon();
  }

  Future<void> fetchRandomPokemon() async {
    try {
      int randomId = Random().nextInt(151) + 1;
      final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$randomId')).timeout(Duration(seconds: 10));
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        int id = jsonData['id'];
        String name = jsonData['name'];
        String imageUrl = jsonData['sprites']['front_default'] ?? '';
        List<String> types = (jsonData['types'] as List).map((t) => t['type']['name'] as String).toList();
        String description = "None";
        setState(() {
          randomPokemon = Pokemon(id:id, name:name, imageUrl:imageUrl, types: types, description: description,);
          isLoading = false;
          message = '';
          userGuess = '';
          isCorrect = false;
        });
      } else {
        setState(() {
          message = "Failed to load Pokémon. Try again later.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = "Error loading Pokémon: $e";
        isLoading = false;
      });
    }
  }

  void checkAnswer() async {
    if (randomPokemon == null) {
      setState(() {
        message = "Pokémon not loaded yet.";
        isCorrect = false;
      });
      return;
    }

    if (userGuess.trim().toLowerCase() == randomPokemon!.name.toLowerCase()) {
      bool success = false;
      try {
        success = await ApiService.saveCaptureToBackend(randomPokemon!);
      } catch (e) {
        print("Error saving capture to backend: $e");
      }

      if (!mounted) return;

      setState(() {
        if (success) {
          isCorrect = true;
          message = "🎉 You caught ${randomPokemon!.name}!";
        } else {
          isCorrect = false;
          message = "❌ You must be logged in or something went wrong.";
        }
      });

      if (success) {
        widget.onCapture(randomPokemon!);
      }
    } else {
      if (!mounted) return;

      setState(() {
        isCorrect = false;
        message = "❌ Nope! Try again!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture Pokémon')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text("Who's that Pokémon?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    child: randomPokemon != null
                        ? Image.network(
                            randomPokemon!.imageUrl,
                            height: 150,
                            fit: BoxFit.contain,
                          )
                        : SizedBox.shrink(),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    onChanged: (val) => userGuess = val.trim(),
                    decoration: InputDecoration(
                      labelText: 'Enter Pokémon name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: checkAnswer,
                    child: Text('Catch!'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    message,
                    style: TextStyle(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
