import 'package:flutter/material.dart';
import 'auth_service.dart';

class RegisterSection extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onSwitch;

  const RegisterSection({
    required this.authService,
    required this.onSwitch,
  });

  @override
  State<RegisterSection> createState() => _RegisterSectionState();
}

class _RegisterSectionState extends State<RegisterSection> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final user =
          await widget.authService.register(_email.text, _password.text);
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registered successfully as ${user.email}')),
        );
        widget.onSwitch();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text('Register', style: TextStyle(fontSize: 22)),
          TextFormField(
            controller: _email,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (val) =>
                val!.isEmpty || !val.contains('@') ? 'Enter valid email' : null,
          ),
          TextFormField(
            controller: _password,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (val) =>
                val!.length < 6 ? '6+ chars required' : null,
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: _register, child: Text('Register')),
          TextButton(
            onPressed: widget.onSwitch,
            child: Text('Already have an account? Sign in'),
          ),
        ],
      ),
    );
  }
}
