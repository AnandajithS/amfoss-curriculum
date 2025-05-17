import 'package:flutter/material.dart';
import 'pokemon.dart';

class PokemonDetailPage extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailPage({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.network(
              pokemon.imageUrl,
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              "Name: ${pokemon.name}",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "ID: ${pokemon.id}",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            Text(              
              "Types: ${pokemon.types}",
              style: TextStyle(fontSize: 18))
          ],
        ),
      ),
    );
  }
}
