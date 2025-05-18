import 'package:flutter/material.dart';
import 'pokemon.dart';

void main()=>runApp(PokedexApp());

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Pokemon> pokemonList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPokemon();
  }

  Future<void> loadPokemon() async {
    final fetchedList = await PokemonService.fetchPokemonList();
    setState(() {
      pokemonList = fetchedList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          // Background pokéball
          Positioned(
            top: 40,
            right: -20,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/pokeball.png',
                width: MediaQuery.of(context).size.width * 0.4,
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.menu),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search Pokémon...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.search),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Grid
                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            itemCount: pokemonList.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 3 / 4,
                            ),
                            itemBuilder: (context, index) {
                              final poke = pokemonList[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[800],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      poke.imageUrl,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      poke.name.toUpperCase(),
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
