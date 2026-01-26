import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../providers/auth_provider.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.read(adminServiceProvider).getStats();
});

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsyncValue = ref.watch(adminStatsProvider);
    final user = ref.read(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.black, // #000000 matching web
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminStatsProvider),
          color: const Color(0xFFE30613),
          backgroundColor: Colors.grey[900],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Section
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
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 2. Stats Grid (Cinematic Cards)
                statsAsyncValue.when(
                  data: (stats) => Column(
                    children: [
                      // Row 1
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Inventory',
                              stats['total_cars'].toString(),
                              const Color(0xFFE30613),
                              Icons.directions_car,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Registered Users',
                              stats['total_users'].toString(),
                              Colors.white,
                              Icons.people,
                              progressColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Row 2
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Allocations',
                              stats['total_allocations'].toString(),
                              Colors.blue,
                              Icons.assignment_turned_in,
                              progressColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Deposits Held',
                              '\$${(double.parse(stats['deposits_collected']?.toString() ?? '0') / 1000).toStringAsFixed(1)}k',
                              Colors.green,
                              Icons.attach_money,
                              progressColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Full Width Revenue
                      _buildStatCard(
                        'Pipeline Value',
                        '\$${(double.parse(stats['revenue']?.toString() ?? '0') / 1000000).toStringAsFixed(1)}M',
                        Colors.purple,
                        Icons.trending_up,
                        progressColor: Colors.purple,
                        isFullWidth: true,
                      ),

                      const SizedBox(height: 40),

                      // 3. Recent Inquiries List
                      _buildSectionHeader('RECENT INQUIRIES'),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F0F),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            // Header
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
                            // List
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
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE30613)),
                  ),
                  error: (e, s) => Center(
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 4. Quick Actions
                _buildSectionHeader('QUICK ACTIONS'),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
                  title: 'NEW VEHICLE',
                  subtitle: 'Add a new masterpiece to the inventory.',
                  icon: Icons.add,
                  onTap: () => context.push('/admin/add'),
                  accentColor: const Color(0xFFE30613),
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
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

  Widget _buildStatCard(
    String label,
    String value,
    Color accent,
    IconData icon, {
    Color? progressColor,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: accent.withValues(alpha: 0.8), size: 20),
              Icon(Icons.more_horiz, color: Colors.grey[800], size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.1),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.7,
              child: Container(color: progressColor ?? accent),
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

  Widget _buildInquiryRow(dynamic allocation) {
    // simplified since we don't have full type safety here without a model update
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status.toString().toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: statusColor,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: accentColor == Colors.white ? Colors.transparent : accentColor,
          border: accentColor == Colors.white
              ? Border.all(color: Colors.white12)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: accentColor == Colors.white
                          ? Colors.white
                          : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: accentColor == Colors.white
                          ? Colors.grey
                          : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
