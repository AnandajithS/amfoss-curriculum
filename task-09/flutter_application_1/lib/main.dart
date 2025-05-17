import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_details.dart';
import 'type_colors.dart';
import 'login.dart';
import 'register.dart';

void main()=>runApp(PokedexApp());

TextEditingController _searchController = TextEditingController();
List<Pokemon> filteredList = [];


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
        title: Text('Pokédex'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    onRegisterClicked: () {
                      print('Register');
                    },
                    onLogin: (email, password) {
                      print("Logged in with credentials - user $email and password $password ");
                    },
                  ),
                ),
              );
            },
            child: Text(
              'Login',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterPage(
                    onLoginClicked: () {
                      print('Go to login');
                    },
                    onRegister: (email, password) {
                      print("Registered with credentials - user $email and password $password ");
                    },
                  ),
                ),
              );
            },
            child: Text(
              'Register',
              style: TextStyle(color: Colors.black),
            ),),
        ],
      ),
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
                          controller: _searchController,
                          onChanged: _filterPokemon,
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
      : filteredList.isEmpty
          ? Center(child: Text("No Pokémon found."))
          : GridView.builder(
              itemCount: filteredList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (context, index) {
                final poke = filteredList[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailPage(pokemon: poke),
                      ),
                    );
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
                        SizedBox(height: 10),
                        Text(
                          poke.name.toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 6,
                          children: poke.types.map((type) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: typeColors[type] ?? Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
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
