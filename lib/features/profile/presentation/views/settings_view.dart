import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Notification preferences
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _conferenceReminders = true;
  bool _applicationUpdates = true;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _conferenceReminders = prefs.getBool('conference_reminders') ?? true;
      _applicationUpdates = prefs.getBool('application_updates') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _togglePushNotifications(bool val) async {
    setState(() => _pushNotifications = val);
    await _savePref('push_notifications', val);

    if (!val) {
      // If master toggle is off, cancel all active notifications
      await NotificationService.instance.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications disabled'), backgroundColor: Colors.orange),
        );
      }
    } else {
      // Send a test notification to confirm it works
      await NotificationService.instance.sendTestNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGrey,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Notifications ──
                  _buildSectionHeader("Notifications", Icons.notifications_outlined),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      title: "Push Notifications",
                      subtitle: "Master switch for all device notifications",
                      icon: Icons.notifications_active_outlined,
                      value: _pushNotifications,
                      onChanged: _togglePushNotifications,
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: "Email Notifications",
                      subtitle: "Receive updates via email",
                      icon: Icons.email_outlined,
                      value: _emailNotifications,
                      enabled: _pushNotifications,
                      onChanged: (val) {
                        setState(() => _emailNotifications = val);
                        _savePref('email_notifications', val);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: "Conference Reminders",
                      subtitle: "Get notified before upcoming conferences",
                      icon: Icons.event_outlined,
                      value: _conferenceReminders,
                      enabled: _pushNotifications,
                      onChanged: (val) {
                        setState(() => _conferenceReminders = val);
                        _savePref('conference_reminders', val);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: "Application Updates",
                      subtitle: "Status changes for your applications",
                      icon: Icons.update_outlined,
                      value: _applicationUpdates,
                      enabled: _pushNotifications,
                      onChanged: (val) {
                        setState(() => _applicationUpdates = val);
                        _savePref('application_updates', val);
                      },
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Security ──
                  _buildSectionHeader("Security", Icons.shield_outlined),
                  _buildSettingsCard([
                    _buildNavigationTile(
                      title: "Change Password",
                      subtitle: "Update your login password",
                      icon: Icons.lock_outline,
                      onTap: () {
                        _showChangePasswordDialog(context);
                      },
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── About ──
                  _buildSectionHeader("About", Icons.info_outline),
                  _buildSettingsCard([
                    _buildInfoTile(
                      title: "App Version",
                      trailing: "1.0.0",
                      icon: Icons.apps_outlined,
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      title: "Terms of Service",
                      subtitle: "Read our terms and conditions",
                      icon: Icons.description_outlined,
                      onTap: () => _launchUrl("https://future-diplomats.com/terms/"),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      title: "Privacy Policy",
                      subtitle: "Learn how we handle your data",
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => _launchUrl("https://future-diplomats.com/terms/"),
                    ),
                  ]),

                  const SizedBox(height: 30),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Future Diplomats",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Crafting Future Leaders",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ── Builders ──

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (enabled ? AppColors.primaryBlue : AppColors.grey).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: enabled ? AppColors.primaryBlue : AppColors.grey, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: enabled ? null : AppColors.grey,
        ),
      ),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey)),
      trailing: Switch(
        value: value && enabled,
        onChanged: enabled ? onChanged : null,
        activeTrackColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String trailing,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: Text(trailing, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey)),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 60);
  }

  // ── Actions ──

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link'), backgroundColor: Colors.red),
      );
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Change Password", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 6) return 'At least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) {
                  if (v != newController.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                final success = await authViewModel.changePassword(newController.text);
                
                if (!mounted) return;
                Navigator.pop(ctx);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed successfully!'), backgroundColor: Colors.green),
                  );
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authViewModel.errorMessage ?? 'Failed to change password'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: Text("Update", style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
