import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'type_colors.dart'; 

class PokemonDetailPage extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailPage({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          pokemon.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: typeColors[pokemon.types.first] ?? Colors.grey,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Hero(
              tag: pokemon.id,
              child: Image.network(
                pokemon.imageUrl,
                height: 180,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "#${pokemon.id} - ${pokemon.name.toUpperCase()}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: pokemon.types.map((type) {
                return Chip(
                  label: Text(
                    type.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: typeColors[type] ?? Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            Text(
              pokemon.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
