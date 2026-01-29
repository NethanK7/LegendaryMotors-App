import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../shared/widgets/layout/sliver_page_header.dart';
import '../../shared/widgets/common/premium_list_tile.dart';
import '../../shared/widgets/common/section_label.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.state.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          if (isLandscape) {
            return Row(
              children: [
                // LEFT PANEL: Profile
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFE30613),
                          child: Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          user?.name.toUpperCase() ?? 'GUEST',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.email ?? '',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 48),
                        TextButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).logout();
                          },
                          child: Text(
                            'LOGOUT',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE30613),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // RIGHT PANEL: Settings
                Expanded(
                  flex: 5,
                  child: ListView(
                    padding: const EdgeInsets.all(32),
                    children: [
                      Text(
                        'SETTINGS',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSettingsList(context, user),
                    ],
                  ),
                ),
              ],
            );
          }

          // PORTRAIT
          return CustomScrollView(
            slivers: [
              const SliverPageHeader(title: 'PROFILE'),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFE30613),
                            child: Text(
                              user?.name.substring(0, 1).toUpperCase() ?? 'U',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name.toUpperCase() ?? 'GUEST',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: onSurface,
                                ),
                              ),
                              Text(
                                user?.email ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: _buildSettingsList(context, user),
                    ),

                    const SizedBox(height: 48),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).logout();
                        },
                        child: Text(
                          'LOGOUT',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFE30613),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'v1.0.0 • LEGENDARY MOTORS',
                        style: GoogleFonts.inter(
                          color: Colors.grey[800],
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user?.isAdmin == true) ...[
          const SectionLabel(title: 'ADMINISTRATION'),
          PremiumListTile(
            title: 'Admin Dashboard',
            subtitle: 'Manage Fleet & Users',
            icon: Icons.admin_panel_settings,
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFE30613),
            ),
            onTap: () {
              context.push('/admin');
            },
          ),
          const SizedBox(height: 32),
        ],

        const SectionLabel(title: 'SUPPORT'),
        PremiumListTile(
          title: 'Legacy',
          subtitle: 'About Us',
          icon: Icons.history_edu,
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey,
          ),
          onTap: () => context.push('/about'),
        ),
        PremiumListTile(
          title: 'Concierge',
          subtitle: 'Contact Support',
          icon: Icons.chat_bubble_outline,
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey,
          ),
          onTap: () => context.push('/contact'),
        ),

        const SizedBox(height: 32),
        const SectionLabel(title: 'LOCATION'),
        PremiumListTile(
          title: 'Find Showroom',
          subtitle: 'Locate nearest dealer',
          icon: Icons.location_on,
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey,
          ),
          onTap: () => context.push('/locations'),
        ),
      ],
    );
  }
}
