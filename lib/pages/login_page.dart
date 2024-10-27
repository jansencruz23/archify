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
  late final _authProvider = Provider.of<AuthProvider>(context, listen: false);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Login
  Future<void> login() async {
    _authProvider.setLoading(true);

    try {
      await _authProvider.loginEmailPassword(
          emailController.text, passwordController.text);
    } catch (ex) {
      // replace with custom show dialog for errros
      if (mounted) {
        showErrorDialog(context, ex.toString());
      }
    }
  }

//For Resposiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  //hover
  bool amIHovering = false;
  Offset exitFrom = Offset(0, 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // App bar
      appBar: AppBar(
        title: const Text(''),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Login header text
              Text(
                'Log In',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Sora',
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),

              // Space between login and text boxes
              const SizedBox(height: 30),

              // Login text field
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              // Space
              const SizedBox(height: 30),

              // Password text field
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              // Space
              const SizedBox(height: 40),

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
                  Text(
                    "Don\'t have an account?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontFamily: 'Sora',
                      fontSize: _getClampedFontSize(context, 0.02),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (PointerEvent details) =>
                          setState(() => amIHovering = true),

                      // callback when your mouse pointer leaves the underlying widget
                      onExit: (PointerEvent details) {
                        setState(() {
                          amIHovering = false;
                          // Storing the exit position
                          exitFrom = details.localPosition;
                        });
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: amIHovering
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Theme.of(context).colorScheme.secondary,
                          fontFamily: 'Sora',
                          fontSize: _getClampedFontSize(context, 0.02),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
