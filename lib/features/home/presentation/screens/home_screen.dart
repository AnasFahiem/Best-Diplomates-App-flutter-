import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../presentation/views/conferences_view.dart';
import '../../presentation/views/opportunities_view.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../profile/presentation/viewmodels/profile_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final user = authViewModel.currentUser;
      if (user != null) {
        // Fetch profile immediately to ensure we have the latest first/last name
        Provider.of<ProfileViewModel>(context, listen: false).fetchProfile(user.id);
      }
    });
  }

  final List<Widget> _pages = [
    const ConferencesView(),
    const OpportunitiesView(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    "Conferences",
    "Opportunities",
    "My Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: Consumer2<AuthViewModel, ProfileViewModel>(
        builder: (context, authViewModel, profileViewModel, child) {
          final user = authViewModel.currentUser;
          final profile = profileViewModel.userProfile;
          
          // Use profile data if available, otherwise auth metadata
          String name = 'Guest User';
          if (profile != null) {
            name = profile.fullName;
          } else if (user != null) {
            final meta = user.userMetadata;
            if (meta != null) {
              if (meta.containsKey('first_name') || meta.containsKey('last_name')) {
                name = "${meta['first_name'] ?? ''} ${meta['last_name'] ?? ''}".trim();
              } else if (meta.containsKey('full_name')) {
                name = meta['full_name'];
              }
            }
          }
          if (name.isEmpty) name = 'Guest User';
                  
          final email = profile?.email ?? user?.email ?? 'guest@example.com';
          
          final avatarUrl = profile?.avatarUrl;

          final initials = name.trim().isNotEmpty 
              ? name.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase()
              : 'GU';

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: AppColors.primaryBlue),
                  accountName: Text(name),
                  accountEmail: Text(email),
                  currentAccountPicture: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: ClipOval(
                      child: avatarUrl != null
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.broken_image, color: Colors.blue));
                              },
                            )
                          : Center(
                              child: Text(initials, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 24)),
                            ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text("Help & Support"),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("About Us"),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text("Logout", style: TextStyle(color: AppColors.error)),
                  onTap: () async {
                    await authViewModel.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Conferences",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: "Opportunities",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
