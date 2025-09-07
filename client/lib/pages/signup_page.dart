import 'package:client/colors/color_pallete.dart';
import 'package:flutter/material.dart';
import '../logic/signup_page_logic.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
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

  // Handle signup button tap - delegates to logic
  void _handleSignUp() async {
    await SignUpPageLogic.handleSignUp(
      context: context,
      nameController: _nameController,
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
              // Outer shadow (darker)
              BoxShadow(
                color: const Color.fromARGB(
                  255,
                  104,
                  104,
                  105,
                ).withOpacity(ColorPalette.darkShadowOpacity + 0.1),
                blurRadius: 15,
                offset: const Offset(8, 8),
              ),
              // Inner shadow (lighter)
              BoxShadow(
                color: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ).withOpacity(ColorPalette.lightShadowOpacity),
                blurRadius: 15,
                offset: const Offset(-8, -8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/self-love.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                //  Title
                const Text(
                  'create account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: ColorPalette.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 30),

                // Name Field
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorPalette.backgroundColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          104,
                          104,
                          105,
                        ).withOpacity(ColorPalette.darkShadowOpacity),
                        blurRadius: 10,
                        offset: const Offset(3, 3),
                      ),
                      BoxShadow(
                        color: ColorPalette.lightShadowColor.withOpacity(
                          ColorPalette.lightShadowOpacity,
                        ),
                        blurRadius: 10,
                        offset: const Offset(-3, -3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'name',
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

                // Email Field
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorPalette.backgroundColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          104,
                          104,
                          105,
                        ).withOpacity(ColorPalette.darkShadowOpacity),
                        blurRadius: 10,
                        offset: const Offset(3, 3),
                      ),
                      BoxShadow(
                        color: ColorPalette.lightShadowColor.withOpacity(
                          ColorPalette.lightShadowOpacity,
                        ),
                        blurRadius: 10,
                        offset: const Offset(-3, -3),
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
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          104,
                          104,
                          105,
                        ).withOpacity(ColorPalette.darkShadowOpacity),
                        blurRadius: 10,
                        offset: const Offset(3, 3),
                      ),
                      BoxShadow(
                        color: ColorPalette.lightShadowColor.withOpacity(
                          ColorPalette.lightShadowOpacity,
                        ),
                        blurRadius: 10,
                        offset: const Offset(-3, -3),
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

                // Sign Up Button
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ColorPalette.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          104,
                          104,
                          105,
                        ).withOpacity(ColorPalette.darkShadowOpacity + 0.1),
                        blurRadius: 10,
                        offset: const Offset(3, 3),
                      ),
                      BoxShadow(
                        color: ColorPalette.lightShadowColor.withOpacity(
                          ColorPalette.lightShadowOpacity,
                        ),
                        blurRadius: 8,
                        offset: const Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _isLoading ? null : _handleSignUp,
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
                                'Sign Up',
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
                const SizedBox(height: 10),

                // Have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Have an account? ",
                      style: TextStyle(
                        color: ColorPalette.primaryTextColor.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        SignUpPageLogic.navigateToLogin(context);
                      },
                      child: const Text(
                        "Login",
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