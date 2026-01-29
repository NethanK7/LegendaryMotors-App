import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/common/premium_button.dart';
import '../../shared/widgets/common/premium_text_field.dart';
import '../../shared/widgets/layout/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Navigation is handled by router redirect based on auth state
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loginWithGoogle();
      // Navigation is handled by router redirect based on auth state
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fillDebugCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'LEGENDARY\nMOTORS',
      subtitle: 'The Pinnacle of Automotive Engineering',
      backgroundUrl:
          'https://images.unsplash.com/photo-1617788138017-80ad40651399?q=80&w=2070&auto=format&fit=crop',
      logo: const Icon(
        Icons.speed,
        color: Color(0xFFE30613),
        size: 48,
      ).animate().scale(delay: 200.ms, duration: 400.ms),
      footerActions: [
        // Debug Quick Login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _debugButton('USER', 'test@example.com', 'password'),
            const SizedBox(width: 16),
            _debugButton('ADMIN', 'admin@admin.com', '123456'),
          ],
        ).animate().fadeIn(delay: 1000.ms),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () => context.push('/register'),
            child: RichText(
              text: TextSpan(
                text: 'NEW TO LEGENDARY? ',
                style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'CREATE ACCOUNT',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            PremiumTextField(
              label: 'EMAIL',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            PremiumTextField(
              label: 'PASSWORD',
              controller: _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 32),
            PremiumButton(
              text: 'ENTER SHOWROOM',
              onPressed: _handleLogin,
              isLoading: _isLoading,
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            PremiumButton(
              text: 'LOGIN WITH GOOGLE',
              onPressed: _handleGoogleLogin,
              isLoading: _isLoading,
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  // _buildTextField removed as it is replaced by Reusable Widget

  Widget _debugButton(String label, String email, String pass) {
    return TextButton(
      onPressed: () => _fillDebugCredentials(email, pass),
      child: Text(
        'LOGIN AS $label',
        style: GoogleFonts.inter(
          color: Colors.white24,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
