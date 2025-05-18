import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'api_routes.dart';

class TradePage extends StatefulWidget {
  final Pokemon pokemon;
   final VoidCallback onTradeSuccess;


  const TradePage({super.key, required this.pokemon, required this.onTradeSuccess,
});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  List<Map<String, dynamic>> allUsers = [];
  int? selectedUserId;
  bool isLoading = true;
  String message = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final users = await ApiService.getAllUsers(); 
      setState(() {
        allUsers = users;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        isLoading = false;
        message = "Failed to load users";
      });
    }
  }

  Future<void> sendTrade() async {
    if (selectedUserId == null) {
      setState(() {
        message = "Please select a user!";
      });
      return;
    }

    final success = await ApiService.tradePokemon(widget.pokemon.id, selectedUserId!);
    if (success) {
      setState(() {
        message = "🎉 Pokémon sent successfully!";
      });

    widget.onTradeSuccess(); // 👈 callback to refresh
    Navigator.pop(context); 

    } else {
      setState(() {
        message = "❌ Failed to trade Pokémon.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pokemon;
    return Scaffold(
      appBar: AppBar(title: Text('Trade ${p.name}')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.network(p.imageUrl ?? 'Pokemon', height: 120),
                  Text("${p.name.toUpperCase()} (#${p.id})", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),

                  DropdownButtonFormField<int>(
                    value: selectedUserId,
                    decoration: InputDecoration(
                      labelText: "Select user to trade with",
                      border: OutlineInputBorder(),
                    ),
                    items: allUsers.map((user) {
                      return DropdownMenuItem<int>(
                        value: user['id'],
                        child: Text(user['username']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedUserId = val;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: sendTrade,
                    icon: Icon(Icons.send),
                    label: Text("Send Pokémon"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    message,
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
    );
  }
}
