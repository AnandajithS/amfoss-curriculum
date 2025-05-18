import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pokemon.dart';
import 'pokemon_details.dart';
import 'type_colors.dart';
import 'login.dart';
import 'register.dart';
import 'profile.dart';

void main() => runApp(const PokedexApp());

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
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
  List<Pokemon> filteredList = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  String? username; // null = not logged in

  @override
  void initState() {
    super.initState();
    loadPokemon();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('userName');
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userId');
    setState(() {
      username = null;
    });
  }

  Future<void> loadPokemon() async {
    final fetchedList = await PokemonService.fetchPokemonList();
    setState(() {
      pokemonList = fetchedList;
      filteredList = fetchedList;
      isLoading = false;
    });
  }

  void _filterPokemon(String query) {
    final results = pokemonList.where((poke) {
      return poke.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredList = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
actions: [
  if (username == null) ...[
    TextButton(
      onPressed: () async {
        // Go to LoginPage and wait for it to return
        await Navigator.push(context, MaterialPageRoute(
          builder: (context) => LoginPage(
            onRegisterClicked: () {},
            onLogin: (email, password) {}, // doesn't matter here
          ),
        ));
        // When back from LoginPage, check login status again
        await checkLoginStatus();
      },
      child: const Text('Login', style: TextStyle(color: Colors.black)),
    ),
    TextButton(
      onPressed: () async {
        // Go to RegisterPage and wait for it to return
        await Navigator.push(context, MaterialPageRoute(
          builder: (context) => RegisterPage(
            onLoginClicked: () {},
            onRegister: (email, password) {}, // doesn't matter here
          ),
        ));
        // When back from RegisterPage, check login status again
        await checkLoginStatus();
      },
      child: const Text('Register', style: TextStyle(color: Colors.black)),
    ),
  ] else ...[
    TextButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ProfilePage(username: username!),
        ));
      },
      child: const Text('Profile', style: TextStyle(color: Colors.black)),
    ),
    TextButton(
      onPressed: () async {
        await logout();           // clear shared prefs
        await checkLoginStatus(); // refresh UI
      },
      child: const Text('Logout', style: TextStyle(color: Colors.black)),
    ),
  ],
],

      ),
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          Positioned(
            top: 40,
            right: -20,
            child: Opacity(
              opacity: 0.1,
              child: Container(), 
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.menu),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterPokemon,
                            decoration: const InputDecoration(
                              hintText: "Search Pokémon...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Icon(Icons.search),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grid
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredList.isEmpty
                            ? const Center(child: Text("No Pokémon found."))
                            : GridView.builder(
                                itemCount: filteredList.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 3 / 4,
                                ),
                                itemBuilder: (context, index) {
                                  final poke = filteredList[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) =>
                                            PokemonDetailPage(pokemon: poke),
                                      ));
                                    },
                                    child: Container(
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
                                          const SizedBox(height: 10),
                                          Text(
                                            poke.name.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 6,
                                            children: poke.types.map((type) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: typeColors[type] ?? Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  type.toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
