import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pokédex Register')),
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
            SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text == _confirmPasswordController.text) {
                  widget.onRegister(_emailController.text, _passwordController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Passwords don't match!")),
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
