import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_constants.dart';
import '../../api/api_client.dart';
import '../../shared/widgets/layout/premium_app_bar.dart';
import '../../shared/widgets/common/premium_text_field.dart';
import '../../shared/widgets/common/premium_button.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitContent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final client = Provider.of<ApiClient>(context, listen: false);
      await client.dio.post(
        ApiConstants.contactEndpoint,
        data: {
          'name': _nameController.text,
          'email': _emailController.text,
          'message': _messageController.text,
        },
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: const Color(0xFF111111),
            title: Text(
              'MESSAGE SENT',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Our concierge team has received your inquiry and will respond shortly.',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c); // Close dialog
                  context.pop(); // Go back
                },
                child: const Text(
                  'DONE',
                  style: TextStyle(color: Color(0xFFE30613)),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
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
      appBar: PremiumAppBar(title: 'CONCIERGE'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GET IN TOUCH',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Direct line to our sales & support team.',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 48),

              PremiumTextField(
                label: 'Full Name',
                controller: _nameController,
                hintText: 'John Doe',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              PremiumTextField(
                label: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'john@example.com',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              PremiumTextField(
                label: 'Message',
                controller: _messageController,
                maxLines: 5,
                hintText: 'How can we help you?',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 48),

              PremiumButton(
                text: 'SEND INQUIRY',
                onPressed: _submitContent,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'LEGENDARY MOTORS HQ\nBottrop, Germany',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.grey[800],
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
