import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'conferences_view.dart';
import 'opportunities_view.dart';
import '../../../../features/profile/presentation/views/profile_view.dart'; // Anticipating change
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../auth/presentation/views/login_view.dart'; // Anticipating change
import '../../../profile/presentation/viewmodels/profile_view_model.dart';
import '../../../profile/presentation/views/support_center_view.dart';
import '../../../profile/presentation/views/settings_view.dart';
import '../../../chat/presentation/widgets/support_chat_fab.dart';
import '../../../chat/presentation/viewmodels/chat_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final userProfile = authViewModel.currentUserProfile;
      if (userProfile != null) {
        // Fetch profile immediately to ensure we have the latest first/last name
        Provider.of<ProfileViewModel>(context, listen: false).fetchProfile(userProfile['id']);
        // Initialize Support Chat for this user
        Provider.of<ChatViewModel>(context, listen: false).initialize(userProfile['id'].toString());
      }
    });
  }

  final List<Widget> _pages = [
    const ConferencesView(),
    const OpportunitiesView(),
    const ProfileView(), // Updated
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
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsView()));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: Consumer2<AuthViewModel, ProfileViewModel>(
        builder: (context, authViewModel, profileViewModel, child) {
          final userProfile = authViewModel.currentUserProfile;
          final profile = profileViewModel.userProfile;
          
          // Use profile data if available, otherwise logged-in profile map
          String name = 'Guest User';
          if (profile != null) {
            name = profile.fullName;
          } else if (userProfile != null) {
            final firstName = userProfile['first_name'] ?? '';
            final lastName = userProfile['last_name'] ?? '';
            name = '$firstName $lastName'.trim();
          }
          if (name.isEmpty) name = 'Guest User';
                  
          final email = profile?.email ?? userProfile?['email'] ?? 'guest@example.com';
          
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
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                    child: Container(
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
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsView()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text("Help & Support"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportCenterView()));
                  },
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
                        MaterialPageRoute(builder: (context) => const LoginView()), // Updated
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
      floatingActionButton: const SupportChatFab(),
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
