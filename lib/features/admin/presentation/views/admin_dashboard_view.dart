import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../auth/presentation/views/login_view.dart'; // Anticipating change
import '../../data/datasources/admin_remote_data_source.dart';
import '../viewmodels/admin_view_model.dart';
import 'admin_chat_view.dart';
import 'admin_announcements_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedIndex = 0;
  late AdminViewModel _adminViewModel;

  @override
  void initState() {
    super.initState();
    _adminViewModel = AdminViewModel(
      dataSource: AdminRemoteDataSourceImpl(
        supabaseClient: Supabase.instance.client,
      ),
    );
    _adminViewModel.fetchThreads();
    _adminViewModel.fetchAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _adminViewModel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 600;

          if (isDesktop) {
            return Scaffold(
              backgroundColor: AppColors.scaffoldBackground,
              body: Row(
                children: [
                  // ── Side Navigation Rail ──
                  _buildSideNav(context),
                  // ── Main Content ──
                  Expanded(
                    child: _selectedIndex == 0
                        ? const AdminChatView()
                        : const AdminAnnouncementsView(),
                  ),
                ],
              ),
            );
          } else {
            // ── Mobile Layout ──
            return Scaffold(
              backgroundColor: AppColors.scaffoldBackground,
              appBar: AppBar(
                title: Text(
                  'Admin Panel',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppColors.navyBlue,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    onPressed: () => _handleLogout(context),
                  ),
                ],
              ),
              body: _selectedIndex == 0
                  ? const AdminChatView()
                  : const AdminAnnouncementsView(),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                selectedItemColor: AppColors.primaryBlue,
                unselectedItemColor: AppColors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline),
                    activeIcon: Icon(Icons.chat_bubble),
                    label: 'Support',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.campaign_outlined),
                    activeIcon: Icon(Icons.campaign),
                    label: 'Announcements',
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    await authVM.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()), // Updated
      );
    }
  }

  Widget _buildSideNav(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.navyBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // ── Logo / Brand ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: AppColors.primaryBlue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Admin Panel',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 20),
          // ── Navigation Items ──
          _buildNavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'Support Chat',
            index: 0,
          ),
          const SizedBox(height: 4),
          _buildNavItem(
            icon: Icons.campaign_outlined,
            activeIcon: Icons.campaign,
            label: 'Announcements',
            index: 1,
          ),
          const Spacer(),
          // ── Logout ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _handleLogout(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          color: AppColors.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: isActive ? AppColors.primaryBlue.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _selectedIndex = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.primaryBlue : AppColors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: isActive ? Colors.white : AppColors.grey,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
