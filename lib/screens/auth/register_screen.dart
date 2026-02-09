import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../shared/widgets/common/premium_button.dart';
import '../../shared/widgets/common/premium_text_field.dart';
import '../../shared/widgets/layout/auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim(),
      );

      if (mounted) {
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
    return AuthLayout(
      title: 'BECOME A LEGEND',
      subtitle: 'Join existing members of the elite club',
      backgroundUrl:
          'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?q=80&w=2069&auto=format&fit=crop',
      footerActions: [
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            PremiumTextField(label: 'FULL NAME', controller: _nameController),
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
    );
  }
}
