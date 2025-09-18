import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itinera_ai/core/app_image.dart';
import 'package:itinera_ai/screen/signUp/bloc/signup_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String path = '/sign-up-screen';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F7),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: height * 0.03),
                // App Logo and Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(AppImage.logo),
                    Text(
                      "Itinera AI",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Helvetica Neue",
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.037),
                Center(
                  child: Text(
                    "Create your account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFamily: GoogleFonts.inter().fontFamily,
                      color: Color(0xFF081735),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.012),
                Text(
                  "Lets get started",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: GoogleFonts.inter().fontFamily,
                    color: Color(0xFF8F95B2),
                  ),
                ),

                SizedBox(height: height * 0.054),

                // Google Sign Up Button
                BlocBuilder<SignupBloc, SignupState>(
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFFFFFFFF),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),

                        child: InkWell(
                          onTap:
                              state is SignupLoading
                                  ? null
                                  : _handleGoogleSignUp,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (state is SignupLoading &&
                                  state is! GoogleSignupSuccess)
                                Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF065F46),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    Image.asset(
                                      AppImage.googleLogo,
                                      width: 24,
                                      height: 24,
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      "Sign up with Google",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily:
                                            GoogleFonts.inter().fontFamily,
                                        color: Color(0xFF081735),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: height * 0.026),

                // Divider with text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: Color(0xFFE6E8F0),
                        indent: 34,
                        endIndent: 18,
                      ),
                    ),
                    Text(
                      "or Sign up with Email",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: GoogleFonts.inter().fontFamily,
                        color: Color(0xFF8F95B2),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Color(0xFFE6E8F0),
                        indent: 18,
                        endIndent: 34,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),

                // Email Field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 33),
                  child: _buildTextField(
                    controller: _emailController,
                    label: "Email address",
                    hint: "john@example.com",
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: height * 0.024),

                // Password Field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 33),
                  child: _buildTextField(
                    controller: _passwordController,
                    label: "Password",
                    hint: "Enter your password",
                    prefixIcon: Icons.lock_outline,
                    obscureText: _isPasswordVisible,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      child: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color(0xFF8F95B2),
                        size: 19,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Passowrd must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: height * 0.024),

                // Confirm password Field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 33),
                  child: _buildTextField(
                    controller: _confirmPasswordController,
                    label: "Confirm Password",
                    hint: "Confirm your password",
                    prefixIcon: Icons.lock_outline,
                    obscureText: _isConfirmPasswordVisible,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                      child: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color(0xFF8F95B2),
                        size: 19,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passowrds do not match';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: height * 0.032),

                // Sign up Button
                BlocConsumer<SignupBloc, SignupState>(
                  listener: (context, state) {
                    if (state is SignupSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Navigate to next Screen or reset form
                    } else if (state is GoogleSignupSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is SignupFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (state is GoogleSignupFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Container(
                      width: double.infinity,
                      height: height * 0.052,
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: Color(0xFF065F46),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: state is SignupLoading ? null : _handleSignUp,
                        child: Center(
                          child:
                              state is SignupLoading
                                  ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    "Sign UP",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFFFAF7),
                                    ),
                                  ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF081735),
          ),
        ),
        SizedBox(height: height * 0.012),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontSize: 16, color: Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: Color(0xFF081735)),
            prefixIcon: Icon(prefixIcon, color: Color(0xFF8F95B2), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF065F46), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      context.read<SignupBloc>().add(
        SignupWithEmailEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );
    }
  }

  void _handleGoogleSignUp() {
    context.read<SignupBloc>().add(SignupWithGoogleEvent());
  }

  void _resetForm() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      context.read<SignupBloc>().add(ResetSignupStateEvent());
    });
  }
}
