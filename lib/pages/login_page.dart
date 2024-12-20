import 'dart:math';

import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_error_dialog.dart';
import 'package:archify/components/my_square_tile.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/foundation.dart';
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
  late final UserProvider _userProvider;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  //focus text field
  late final FocusNode _fieldEmail;
  late final FocusNode _fieldPass;

  final int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _fieldEmail = FocusNode();
    _fieldPass = FocusNode();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

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
      // replace with custom show dialog for errors
      if (mounted) {
        if (ex.toString() == 'Exception: invalid-email') {
          showErrorDialog(context, 'Enter a valid email');
        } else if (ex.toString() == 'Exception: invalid-credentials') {
          showErrorDialog(context, 'Error: Invalid Credentials');
        } else if (ex.toString() == 'Exception: channel-error') {
          showErrorDialog(context, 'Enter both email and password');
        } else {
          showErrorDialog(context, ex.toString()); //'Something went wrong'
        }
      }
    }
  }

  //hover for button and mouse change
  bool amIHovering = false;
  Offset exitFrom = Offset(0, 0);

  // Login with Google
  Future<void> loginWithGoogle() async {
    try {
      // Get user credentials from Google login
      final userCredential = await _authProvider.loginWithGoogle();

      // Check if the user is new -> save user to database and
      if (userCredential != null &&
          userCredential.additionalUserInfo!.isNewUser) {
        _userProvider.setLoading(true);

        final email = _authProvider.getCurrentUser()!.email;
        await _userProvider.saveUser(email!);
      }
    } catch (ex) {
      // replace with custom show dialog for errors
      if (mounted) {
        showErrorDialog(context, ex.toString());
      }
    } finally {
      _userProvider.setLoading(false);
    }
  }

  //unfocus all textfield pag click anywhere
  void _unfocusAllFields() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _unfocusAllFields();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        // App bar
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.33,
                      constraints:
                          const BoxConstraints(minWidth: double.infinity),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFD2691E),
                            Color(0xFFE4A68A),
                            Color(0xFFF5DEB3),
                            Color(0xFFFAA376),
                            Color(0xFFFF6F61),
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.33,
                      constraints:
                          const BoxConstraints(minWidth: double.infinity),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          border: Border(
                            bottom: BorderSide(
                                width: 15, color: Colors.transparent),
                          )),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        child: Image.asset(
                          'lib/assets/images/sample_Image2.jpg',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) => FutureBuilder(
                        future:
                            Future.delayed(Duration(milliseconds: 300 * index)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return AnimatedOpacity(
                              opacity: 1.0,
                              duration: Duration(milliseconds: 200),
                              child: buildDot(context, index),
                            );
                          }
                          return AnimatedOpacity(
                            opacity: 0.0,
                            duration: Duration(milliseconds: 200),
                            child: SizedBox(width: 12),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: Column(
                    children: [
                      // Login text field
                      MyTextField(
                        focusNode: _fieldEmail,
                        controller: _emailController,
                        hintText: 'Email',
                        obscureText: false,
                        onSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_fieldPass);
                        },
                      ),
                      // Space
                      const SizedBox(height: 10),

                      // Password text field
                      MyTextField(
                        focusNode: _fieldPass,
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: true,
                        showToggleIcon: true,
                        onSubmitted: (value) {
                          _fieldPass.unfocus();
                        },
                      ),

                      // Space
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // Login button
                MyButton(
                  text: 'Login',
                  onTap: () async => login(),
                ),

                // Space

                // dont have an acc?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontFamily: 'Sora',
                        fontSize: 12,
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
                                ? Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                : Theme.of(context).colorScheme.secondary,
                            fontFamily: 'Sora',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Space
                const SizedBox(height: 30),

                //Google continue
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontFamily: 'Sora',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Replace with my icon button
                SizedBox(
                  height: 50,
                  child: MySquareTile(
                    imagePath: 'lib/assets/images/google.png',
                    onTap: () async => loginWithGoogle(),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))
              ],
            ),
          ),
        ),
      ),
    );
  }

  AnimatedContainer buildDot(BuildContext context, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 10,
      width: _currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
