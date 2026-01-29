import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/common/premium_button.dart';
import '../../shared/widgets/common/premium_text_field.dart';
import '../../shared/widgets/common/glass_container.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Dynamic Background
              Image.network(
                'https://images.unsplash.com/photo-1617788138017-80ad40651399?q=80&w=2070&auto=format&fit=crop',
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.7),
                colorBlendMode: BlendMode.darken,
              ).animate().fadeIn(duration: 1000.ms),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isLandscape ? 500 : 400,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo Section
                        Column(
                          children: [
                            const Icon(
                              Icons.speed,
                              color: Color(0xFFE30613),
                              size: 48,
                            ).animate().scale(delay: 200.ms, duration: 400.ms),
                            const SizedBox(height: 16),
                            Text(
                                  'LEGENDARY\nMOTORS',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 0.9,
                                    letterSpacing: -1.0,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .moveY(begin: 20, end: 0),
                            const SizedBox(height: 12),
                            Text(
                              'The Pinnacle of Automotive Engineering',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ).animate().fadeIn(delay: 600.ms),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // Glassmorphism Form Container
                        GlassContainer(
                          borderRadius: BorderRadius.circular(
                            0,
                          ), // Sharp Brabus style
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
                                  isLoading:
                                      _isLoading, // Share loading state or separate? Assuming shared for now
                                  isPrimary: false,
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 800.ms).moveY(begin: 30, end: 0),

                        const SizedBox(height: 24),

                        // Debug Quick Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _debugButton(
                              'USER',
                              'test@example.com',
                              'password',
                            ),
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
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
