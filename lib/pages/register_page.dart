import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_error_dialog.dart';
import 'package:archify/components/my_square_tile.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:archify/services/auth/auth_provider.dart';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final AuthProvider _authProvider;
  late final UserProvider _userProvider;

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPwController;
  //Text field focus
  late final FocusNode _fieldEmail;
  late final FocusNode _fieldPass;
  late final FocusNode _fieldRepass;

  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPwController = TextEditingController();

    _fieldEmail = FocusNode();
    _fieldPass = FocusNode();
    _fieldRepass = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPwController.dispose();
    //_fieldEmail.dispose();
    //_fieldPass.dispose();
    //_fieldRepass.dispose();
    super.dispose();
  }

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

  // Register with Google
  Future<void> registerWithGoogle() async {
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

  @override
  Widget build(BuildContext context) {
    //Gradinet Line Colors
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // App bar removed
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
                          bottom:
                              BorderSide(width: 15, color: Colors.transparent),
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
                  children:
                      List.generate(2, (index) => buildDot(context, index)),
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 10),

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
              const SizedBox(height: 20),

              // Password text field
              MyTextField(
                focusNode: _fieldPass,
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
                onSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_fieldRepass);
                },
              ),

              // Space
              const SizedBox(height: 20),

              // Password text field
              MyTextField(
                focusNode: _fieldRepass,
                controller: _confirmPwController,
                hintText: 'Confirm Password',
                obscureText: true,
                onSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
              ),

              // Space
              const SizedBox(height: 10),

              // Login button
              MyButton(
                text: 'Sign Up',
                onTap: () async => register(),
              ),

              // Space

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
              const SizedBox(height: 10),
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
                          fontSize: _getClampedFontSize(context, 0.02),
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
              SizedBox(
                height: 50,
                child: MySquareTile(
                  imagePath: 'lib/assets/images/google.png',
                  onTap: () async => registerWithGoogle(),
                ),
              ),
              const SizedBox(height: 10),
            ],
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
