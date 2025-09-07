import 'package:client/colors/color_pallete.dart';
import 'package:flutter/material.dart';
import '../logic/login_page_logic.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Loading state setter
  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  // Handle login button tap - delegates to logic
  void _handleLogin() async {
    await LoginPageLogic.handleLogin(
      context: context,
      emailController: _emailController,
      passwordController: _passwordController,
      setLoading: _setLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      body: Center(
        child: Container(
          width: 350,
          height: 560,
          decoration: BoxDecoration(
            color: ColorPalette.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ColorPalette.darkShadowColor.withOpacity(
                  ColorPalette.darkShadowOpacity + 0.15,
                ),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(10, 10),
              ),
              BoxShadow(
                color: ColorPalette.lightShadowColor.withOpacity(
                  ColorPalette.lightShadowOpacity + 0.2,
                ),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(-10, -10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/instrument.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Login Title
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: ColorPalette.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 30),

                // Email Field
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorPalette.backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.darkShadowColor.withOpacity(
                          ColorPalette.darkShadowOpacity + 0.5,
                        ),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(4, 4),
                      ),
                      BoxShadow(
                        color: ColorPalette.lightShadowColor.withOpacity(
                          ColorPalette.lightShadowOpacity + 0.3,
                        ),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'email',
                      hintStyle: TextStyle(
                        color: ColorPalette.hintTextColor.withOpacity(
                          ColorPalette.hintTextOpacity,
                        ),
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    style: const TextStyle(
                      color: ColorPalette.primaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorPalette.backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.darkShadowColor.withOpacity(
                          ColorPalette.darkShadowOpacity + 0.5,
                        ),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(4, 4),
                      ),
                      BoxShadow(
                        color: ColorPalette.lightShadowColor.withOpacity(
                          ColorPalette.lightShadowOpacity + 0.3,
                        ),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    enabled: !_isLoading,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'password',
                      hintStyle: TextStyle(
                        color: ColorPalette.hintTextColor.withOpacity(
                          ColorPalette.hintTextOpacity,
                        ),
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    style: const TextStyle(
                      color: ColorPalette.primaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign In Button
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorPalette.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.darkShadowColor.withOpacity(
                          ColorPalette.darkShadowOpacity + 0.5,
                        ),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(4, 4),
                      ),
                      BoxShadow(
                        color: ColorPalette.lightShadowColor.withOpacity(
                          ColorPalette.lightShadowOpacity + 0.3,
                        ),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _isLoading ? null : _handleLogin,
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: ColorPalette.primaryTextColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: ColorPalette.primaryTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Don't have an account? Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: ColorPalette.primaryTextColor.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        LoginPageLogic.navigateToSignUp(context);
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: ColorPalette.primaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
