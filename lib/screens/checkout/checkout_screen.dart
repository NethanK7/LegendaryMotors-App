import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_constants.dart';
import '../../api/api_client.dart';
import '../../providers/orders_provider.dart';
import '../../services/checkout_service.dart';
import '../../shared/models/car.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> extra; // Expects {'car': Car, 'config': Map}

  const CheckoutScreen({super.key, required this.extra});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;
  int _step = 0; // 0: Review, 1: Payment, 2: Success

  late Car? _car;
  late Map<String, dynamic> _config;

  @override
  void initState() {
    super.initState();
    _car = widget.extra['car'] as Car?;
    _config = widget.extra['config'] as Map<String, dynamic>? ?? {};
  }

  Future<void> _processPayment() async {
    if (_car == null) return;

    setState(() => _isLoading = true);

    try {
      final client = Provider.of<ApiClient>(context, listen: false);

      final response = await client.dio.post(
        ApiConstants.paymentIntentEndpoint,
        data: {
          'amount': 500000,
          'currency': 'usd',
          'description': 'Reservation Fee for ${_car!.model}',
        },
      );

      final clientSecret = response.data['clientSecret'];
      if (clientSecret == null) throw Exception('No clientSecret received');

      if (kIsWeb) {
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: const PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(),
          ),
        );
      } else {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Legendary Motors',
            style: ThemeMode.dark,
            appearance: const PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(
                background: Colors.black,
                primary: Color(0xFFE30613),
                componentBackground: Color(0xFF111111),
                componentBorder: Colors.white12,
                componentDivider: Colors.white24,
                primaryText: Colors.white,
                secondaryText: Colors.grey,
                icon: Colors.white,
                placeholderText: Colors.white54,
              ),
              shapes: PaymentSheetShape(borderRadius: 0, borderWidth: 1),
              primaryButton: PaymentSheetPrimaryButtonAppearance(
                colors: PaymentSheetPrimaryButtonTheme(
                  light: PaymentSheetPrimaryButtonThemeColors(
                    background: Color(0xFFE30613),
                    text: Colors.white,
                    border: Color(0xFFE30613),
                  ),
                  dark: PaymentSheetPrimaryButtonThemeColors(
                    background: Color(0xFFE30613),
                    text: Colors.white,
                    border: Color(0xFFE30613),
                  ),
                ),
              ),
            ),
          ),
        );
        await Stripe.instance.presentPaymentSheet();
      }

      if (mounted) {
        await Provider.of<CheckoutService>(
          context,
          listen: false,
        ).checkout(carId: _car!.id, configuration: _config);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _step = 2; // Success View
        });
      }
    } on StripeException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (e.error.code != FailureCode.Canceled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment Error: ${e.error.localizedMessage}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _step == 2 ? 'CONFIRMATION' : 'SECURE CHECKOUT',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 16,
            color: onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: onSurface),
        elevation: 0,
      ),
      body: SafeArea(
        child: _step == 2
            ? _buildSuccessView(theme, onSurface)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(theme, onSurface),
                    const SizedBox(height: 32),
                    Divider(color: onSurface.withValues(alpha: 0.1)),
                    const SizedBox(height: 32),
                    Text(
                      'PAYMENT METHOD',
                      style: GoogleFonts.inter(
                        color: onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (kIsWeb) ...[
                      const SizedBox(height: 32),
                      Text(
                        'CARD DETAILS',
                        style: GoogleFonts.inter(
                          color: onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CardField(
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: onSurface.withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE30613)),
                          ),
                        ),
                        style: GoogleFonts.inter(color: onSurface),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF111111)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.credit_card,
                              color: Color(0xFFE30613),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Stripe Secure Billing',
                              style: GoogleFonts.inter(
                                color: onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 100), // Space for sticky button
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _step == 2
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE30613),
                          shape: const RoundedRectangleBorder(),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'PAY & REQUEST ALLOCATION',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 10,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Secure payment via Stripe',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme, Color onSurface) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.grey[100],
        border: Border.all(color: onSurface.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PURCHASE SUMMARY',
            style: GoogleFonts.inter(
              color: onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VEHICLE PRICE',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '\$${_config.containsKey('totalPrice') ? (_config['totalPrice'] as double).toStringAsFixed(0) : (_car?.price.toStringAsFixed(0) ?? '0')}',
                style: GoogleFonts.inter(
                  color: onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TAXES (EST.)',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
              ),
              Text(
                'TBD',
                style: GoogleFonts.inter(
                  color: onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: onSurface.withValues(alpha: 0.1)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE30613),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DUE TODAY (DEPOSIT)',
                    style: GoogleFonts.inter(
                      color: onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                '\$5,000.00',
                style: GoogleFonts.inter(
                  color: onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme, Color onSurface) {
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Color(0xFFE30613)),
            const SizedBox(height: 32),
            Text(
              'PAYMENT SUCCESSFUL',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: onSurface,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your \$5,000.00 reservation fee has been processed securely. A receipt has been sent to your email.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey, height: 1.6),
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<OrdersProvider>(
                    context,
                    listen: false,
                  ).fetchOrders(); // Refresh My Garage properly
                  context.go('/favorites');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  'RETURN TO GARAGE',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
