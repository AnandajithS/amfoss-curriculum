import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_routes.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onLoginClicked;
  final Function(String email, String password) onRegister;

  RegisterPage({required this.onLoginClicked, required this.onRegister});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pokédex Register')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
              TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = _nameController.text;
                final email = _emailController.text;
                final password = _passwordController.text;

                final userData = await ApiService.registerUser(username, email, password);
                if (userData != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('username', userData['name']);
                await prefs.setInt('userId', userData['id']);
                await prefs.setString('userEmail', userData['email']);
                await prefs.setBool('isLoggedIn', true);


                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Registered successfully!')),
                 );
                Navigator.pop(context);

              } else {    
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registration failed. Try again.')),
                  );
              }

              },
              child: Text('Register'),
            ),
            TextButton(
              onPressed: widget.onLoginClicked,
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
