import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_routes.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onRegisterClicked;
  final Function(String email, String password) onLogin;

  LoginPage({required this.onRegisterClicked, required this.onLogin});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pokédex Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text;
                final password = _passwordController.text;

              final userData = await ApiService.loginUser(email,password);
              if (userData!=null){
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', true);
                await prefs.setString('userEmail', userData['email']);
                await prefs.setInt('userId',userData['id']);
                await prefs.setString('userName',userData['name']);
                Navigator.pop(context);
              }
              else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed! Please check your credentials.')),
                  );
              }
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: widget.onRegisterClicked,
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
