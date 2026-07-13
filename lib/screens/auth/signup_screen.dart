import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/social_auth_button.dart';
import '../../core/widgets/gradient_text.dart';
import '../../core/widgets/animations/fade_in_widget.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../data/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    double strength = 0;
    
    if (password.length >= 6) strength += 0.3;
    if (password.length >= 10) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;

    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
      if (strength < 0.4) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (strength < 0.8) {
        _passwordStrengthText = 'Medium';
        _passwordStrengthColor = Colors.amber;
      } else {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  void _handleSignup() async {
    if (!_agreedToTerms) {
      Helpers.showErrorSnackbar(context, 'Please agree to the Terms of Service');
      return;
    }

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.signUpWithEmail(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _referralController.text.trim().isNotEmpty ? _referralController.text.trim() : null,
      );

      if (authProvider.errorMessage != null && mounted) {
        Helpers.showErrorSnackbar(context, authProvider.errorMessage!);
      } else if (mounted) {
        // Pop back to login or go to main depending on navigation setup
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeInUpWidget(
                      delay: const Duration(milliseconds: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join millions earning with WatchEarn',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    FadeInUpWidget(
                      delay: const Duration(milliseconds: 300),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              hintText: 'Full Name',
                              prefixIcon: Icons.person_outline,
                              validator: Validators.validateName,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Email Address',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              validator: Validators.validatePassword,
                            ),
                            if (_passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: _passwordStrength,
                                      backgroundColor: Colors.white12,
                                      valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _passwordStrengthText,
                                    style: TextStyle(color: _passwordStrengthColor, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm Password',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              validator: (val) {
                                if (val != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _referralController,
                              hintText: 'Referral Code (Optional)',
                              prefixIcon: Icons.card_giftcard,
                              validator: Validators.validateReferralCode,
                            ),
                            if (_referralController.text.isNotEmpty && _referralController.text.length == 6)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      '+500 coins bonus!',
                                      style: GoogleFonts.poppins(color: Colors.green, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                                  fillColor: MaterialStateProperty.resolveWith((states) => 
                                    states.contains(MaterialState.selected) ? AppColors.primary : Colors.white24
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'I agree to Terms of Service and Privacy Policy',
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'Create Account',
                              isLoading: authProvider.isLoading,
                              onPressed: _handleSignup,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    FadeInUpWidget(
                      delay: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Colors.white24)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Or sign up with',
                                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                                ),
                              ),
                              const Expanded(child: Divider(color: Colors.white24)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SocialAuthButton(
                            type: SocialAuthType.google,
                            isLoading: authProvider.isLoading,
                            onPressed: () {
                              authProvider.signInWithGoogle();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    FadeInUpWidget(
                      delay: const Duration(milliseconds: 700),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const GradientText(
                              'Sign In',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
