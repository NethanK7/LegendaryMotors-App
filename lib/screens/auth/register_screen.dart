import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/premium_button.dart';
import '../../shared/widgets/premium_text_field.dart';
import '../../shared/widgets/glass_container.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
            _phoneController.text.trim(),
          );

      if (mounted) {
        // Successful registration usually logs in automatically via the provider update
        // Redirect to home
        context.go('/');
      }
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
                'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?q=80&w=2069&auto=format&fit=crop', // Different Brabus Image
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.8),
                colorBlendMode: BlendMode.darken,
              ).animate().fadeIn(duration: 1000.ms),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 48,
                  ),
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
                            Text(
                                  'BECOME A LEGEND',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 0.9,
                                    letterSpacing: -0.5,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .moveY(begin: 20, end: 0),
                            const SizedBox(height: 12),
                            Text(
                              'Join existing members of the elite club',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ).animate().fadeIn(delay: 600.ms),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Form
                        GlassContainer(
                              borderRadius: BorderRadius.circular(0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    PremiumTextField(
                                      label: 'FULL NAME',
                                      controller: _nameController,
                                    ),
                                    const SizedBox(height: 16),
                                    PremiumTextField(
                                      label: 'EMAIL ADDRESS',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 16),
                                    PremiumTextField(
                                      label: 'PHONE NUMBER',
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 16),
                                    PremiumTextField(
                                      label: 'PASSWORD',
                                      controller: _passwordController,
                                      isPassword: true,
                                    ),
                                    const SizedBox(height: 16),
                                    PremiumTextField(
                                      label: 'CONFIRM PASSWORD',
                                      controller: _confirmPasswordController,
                                      isPassword: true,
                                    ),
                                    const SizedBox(height: 32),
                                    PremiumButton(
                                      text: 'REGISTER',
                                      onPressed: _handleRegister,
                                      isLoading: _isLoading,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 800.ms)
                            .moveY(begin: 30, end: 0),

                        const SizedBox(height: 24),

                        Center(
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: RichText(
                              text: TextSpan(
                                text: 'ALREADY A MEMBER? ',
                                style: GoogleFonts.inter(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'LOGIN',
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
}
