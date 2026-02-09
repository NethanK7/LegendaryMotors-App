import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/status/admin_stat_card.dart';
import '../../shared/widgets/common/quick_action_card.dart';
import '../../shared/widgets/common/premium_badge.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statsFuture = Provider.of<AdminService>(context, listen: false).getStats();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final adminService = Provider.of<AdminService>(context, listen: false);
    setState(() {
      _statsFuture = adminService.getStats();
    });
    await _statsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.state.user;

    return Scaffold(
      backgroundColor: Colors.black, // #000000 matching web
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFFE30613),
          backgroundColor: Colors.grey[900],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'COMMAND CENTER ACTIVE',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFE30613),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'WELCOME BACK,\n${user?.name.toUpperCase() ?? 'ADMIN'}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SYSTEM OPERATIONAL • ${DateFormat('MMMM d, y').format(DateTime.now())}',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).logout();
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                FutureBuilder<Map<String, dynamic>>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE30613),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final stats = snapshot.data ?? {};

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AdminStatCard(
                                label: 'Total Inventory',
                                value: stats['total_cars'].toString(),
                                accentColor: const Color(0xFFE30613),
                                icon: Icons.directions_car,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AdminStatCard(
                                label: 'Registered Users',
                                value: stats['total_users'].toString(),
                                accentColor: Colors.white,
                                icon: Icons.people,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AdminStatCard(
                                label: 'Allocations',
                                value: stats['total_allocations'].toString(),
                                accentColor: Colors.blue,
                                icon: Icons.assignment_turned_in,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AdminStatCard(
                                label: 'Deposits Held',
                                value:
                                    '\$${(double.tryParse(stats['deposits_collected']?.toString() ?? '0') ?? 0 / 1000).toStringAsFixed(1)}k',
                                accentColor: Colors.green,
                                icon: Icons.attach_money,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AdminStatCard(
                          label: 'Pipeline Value',
                          value:
                              '\$${(double.tryParse(stats['revenue']?.toString() ?? '0') ?? 0 / 1000000).toStringAsFixed(1)}M',
                          accentColor: Colors.purple,
                          icon: Icons.trending_up,
                          isFullWidth: true,
                        ),

                        const SizedBox(height: 40),

                        _buildSectionHeader('RECENT INQUIRIES'),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F0F0F),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _tableHeader('CLIENT'),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: _tableHeader('VEHICLE'),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _tableHeader('STATUS'),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Colors.white12),
                              if (stats['recent_allocations'] != null)
                                ...(stats['recent_allocations'] as List).map((
                                  allocation,
                                ) {
                                  return _buildInquiryRow(allocation);
                                }),
                              if ((stats['recent_allocations'] == null) ||
                                  (stats['recent_allocations'] as List).isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Center(
                                    child: Text(
                                      'No inquiries yet',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),

                _buildSectionHeader('QUICK ACTIONS'),
                const SizedBox(height: 16),
                QuickActionCard(
                  title: 'NEW VEHICLE',
                  subtitle: 'Add a new masterpiece to the inventory.',
                  icon: Icons.add,
                  onTap: () => context.push('/admin/add'),
                  accentColor: const Color(0xFFE30613),
                ),
                const SizedBox(height: 16),
                QuickActionCard(
                  title: 'MANAGE FLEET',
                  subtitle: 'Edit or remove existing vehicles.',
                  icon: Icons.edit_road,
                  onTap: () => context.push('/admin/fleet'),
                  accentColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: const Color(0xFFE30613)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInquiryRow(dynamic allocation) {
    final clientName = allocation['user']?['name'] ?? 'Unknown';
    final carModel = allocation['car']?['model'] ?? 'Unknown Car';
    final status = allocation['status'] ?? 'pending';

    Color statusColor = Colors.grey;
    if (status == 'paid') statusColor = Colors.green;
    if (status == 'reserved') statusColor = const Color(0xFFE30613);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              clientName,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              carModel,
              style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: PremiumBadge(
              text: status,
              color: statusColor,
              isOutline: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.grey[600],
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }
}
