import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_error_dialog.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final _authProvider = Provider.of<AuthProvider>(context, listen: false);
  late final _userProvider = Provider.of<UserProvider>(context, listen: false);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPwController = TextEditingController();

//For Resposiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  // Register function calling the user provider
  Future<void> register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPwController.text;

    if (password != confirmPassword) {
      showErrorDialog(context, 'Passwords do not match');
      return;
    }

    _userProvider.setLoading(true);

    try {
      // Register in firebase auth
      await _authProvider.registerEmailPassword(email, password);

      // Save user in firebase database
      await _userProvider.saveUser(email);
    } catch (ex) {
      if (mounted) {
        showErrorDialog(context, ex.toString());
      }
    } finally {
      _userProvider.setLoading(false);
    }
  }

//Hover not finished yet
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
                'Sign Up',
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

              // Password text field
              MyTextField(
                controller: _confirmPwController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              // Space
              const SizedBox(height: 40),

              // Login button
              MyButton(
                text: 'Sign Up',
                onTap: () async => register(),
              ),

              // Space
              const SizedBox(height: 30),

              // already have an acc?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
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
                        "Sign in",
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
