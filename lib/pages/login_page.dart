import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_error_dialog.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthProvider _authProvider;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login
  Future<void> login() async {
    _authProvider.setLoading(true);

    try {
      await _authProvider.loginEmailPassword(
          _emailController.text, _passwordController.text);
    } catch (ex) {
      // replace with custom show dialog for errros
      if (mounted) {
        showErrorDialog(context, ex.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // App bar
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Login header text
            const Text('Log In'),

            // Space between login and text boxes
            const SizedBox(height: 30),

            // Login text field
            MyTextField(
              controller: _emailController,
              hintText: 'Email',
              obscureText: false,
            ),

            // Space
            const SizedBox(height: 30),

            // Password text field
            MyTextField(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
            ),

            // Space
            const SizedBox(height: 30),

            // Login button
            MyButton(
              text: 'Login',
              onTap: () async => login(),
            ),

            // Space
            const SizedBox(height: 30),

            // dont have an acc?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account?'),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
