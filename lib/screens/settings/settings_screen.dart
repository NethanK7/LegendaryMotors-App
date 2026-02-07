import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../shared/utils/io_utils.dart' as io;

import '../../providers/auth_provider.dart';
import '../../shared/widgets/layout/sliver_page_header.dart';
import '../../shared/widgets/common/premium_list_tile.dart';
import '../../shared/widgets/common/section_label.dart';
import 'package:battery_plus/battery_plus.dart';
import '../../shared/widgets/common/premium_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  final Battery _battery = Battery();
  int _batteryLevel = 100;

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
  }

  Future<void> _getBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() => _batteryLevel = level);
      }
    } catch (e) {
      // Battery info unavailable (Start-up or Web limitation)
      if (mounted) {
        setState(() => _batteryLevel = -1);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo != null) {
        if (kIsWeb) {
          final bytes = await photo.readAsBytes();
          final base64String = 'data:image/png;base64,${base64.encode(bytes)}';
          if (mounted) {
            Provider.of<AuthProvider>(
              context,
              listen: false,
            ).updateLocalProfileImage(base64String);
          }
          return;
        }
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(photo.path);
        final savedImage = await io.File(
          photo.path,
        ).copy('${appDir.path}/$fileName');

        if (mounted) {
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).updateLocalProfileImage(savedImage.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

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
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFFE30613),
                                backgroundImage:
                                    authProvider.state.localProfileImagePath !=
                                        null
                                    ? (kIsWeb
                                          ? (authProvider
                                                    .state
                                                    .localProfileImagePath!
                                                    .startsWith('data:image')
                                                ? MemoryImage(
                                                    base64Decode(
                                                      authProvider
                                                          .state
                                                          .localProfileImagePath!
                                                          .split(',')
                                                          .last,
                                                    ),
                                                  )
                                                : NetworkImage(
                                                        authProvider
                                                            .state
                                                            .localProfileImagePath!,
                                                      )
                                                      as ImageProvider)
                                          : FileImage(
                                                  io.File(
                                                        authProvider
                                                            .state
                                                            .localProfileImagePath!,
                                                      )
                                                      as dynamic,
                                                )
                                                as ImageProvider)
                                    : null,
                                child:
                                    authProvider.state.localProfileImagePath ==
                                        null
                                    ? Text(
                                        user?.name
                                                .substring(0, 1)
                                                .toUpperCase() ??
                                            'U',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 36,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE30613),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
                        PremiumButton(
                          text: 'LOGOUT',
                          onPressed: () {
                            Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).logout();
                          },
                          isPrimary: false,
                          width: 160,
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
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xFFE30613),
                                  backgroundImage:
                                      authProvider
                                              .state
                                              .localProfileImagePath !=
                                          null
                                      ? (kIsWeb
                                            ? (authProvider
                                                      .state
                                                      .localProfileImagePath!
                                                      .startsWith('data:image')
                                                  ? MemoryImage(
                                                      base64Decode(
                                                        authProvider
                                                            .state
                                                            .localProfileImagePath!
                                                            .split(',')
                                                            .last,
                                                      ),
                                                    )
                                                  : NetworkImage(
                                                          authProvider
                                                              .state
                                                              .localProfileImagePath!,
                                                        )
                                                        as ImageProvider)
                                            : FileImage(
                                                    io.File(
                                                          authProvider
                                                              .state
                                                              .localProfileImagePath!,
                                                        )
                                                        as dynamic,
                                                  )
                                                  as ImageProvider)
                                      : null,
                                  child:
                                      authProvider
                                              .state
                                              .localProfileImagePath ==
                                          null
                                      ? Text(
                                          user?.name
                                                  .substring(0, 1)
                                                  .toUpperCase() ??
                                              'U',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE30613),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
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
                      child: PremiumButton(
                        text: 'LOGOUT',
                        onPressed: () {
                          Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).logout();
                        },
                        isPrimary: false,
                        width: 200,
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

        const SizedBox(height: 32),
        const SectionLabel(title: 'DEVICE HEALTH'),
        PremiumListTile(
          title: 'Power Source',
          subtitle: _batteryLevel >= 0
              ? 'Battery Level: $_batteryLevel%'
              : 'Power Status: Unknown',
          icon: Icons.battery_charging_full,
          trailing: Text(
            _batteryLevel >= 0 ? '$_batteryLevel%' : 'N/A',
            style: GoogleFonts.inter(
              color: _batteryLevel < 20 && _batteryLevel >= 0
                  ? const Color(0xFFE30613)
                  : (_batteryLevel >= 0 ? Colors.green : Colors.grey),
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: _getBatteryLevel,
        ),
      ],
    );
  }
}
