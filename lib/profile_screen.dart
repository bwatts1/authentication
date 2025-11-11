import 'package:flutter/material.dart';
import 'auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final AuthService authService;
  ProfileScreen({required this.authService});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _passwordController = TextEditingController();
  String _message = "";

  void _changePassword() async {
    if (_passwordController.text.length < 6) {
      setState(() {
        _message = "Password must be 6+ characters";
      });
      return;
    }

    String? feedback =
        await widget.authService.changePassword(_passwordController.text.trim());
    setState(() {
      _message = feedback ?? "";
    });
  }

  void _logout() async {
    await widget.authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = widget.authService.currentUser?.email ?? "Unknown user";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, $userEmail",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text("Change Password"),
            ),
            const SizedBox(height: 10),
            Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
