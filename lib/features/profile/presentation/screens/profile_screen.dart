import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/profile_view_model.dart';
import '../views/basic_info_view.dart';
import '../views/certificates_view.dart';
import '../views/passport_details_view.dart';
import '../views/support_center_view.dart';
import '../views/account_verification_view.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      
      if (authVM.currentUser != null && profileVM.userProfile == null) {
        profileVM.fetchProfile(authVM.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, ProfileViewModel>(
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

        return Scaffold(
          backgroundColor: AppColors.lightGrey,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                 const SizedBox(height: 20),
                // Profile Header
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: avatarUrl != null
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.broken_image, color: Colors.blue));
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                          )
                        : CircleAvatar(
                            backgroundColor: AppColors.primaryBlue,
                            child: Text(initials, style: const TextStyle(fontSize: 30, color: AppColors.white)),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Profile Options
                _buildProfileCard(context),
                
                const SizedBox(height: 20),
                 _buildLogoutButton(context, authViewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildListTile(context, "Basic Information", Icons.person_outline, const BasicInfoView()),
          _buildDivider(),
          _buildListTile(context, "My Certificates", Icons.workspace_premium_outlined, const CertificatesView()),
          _buildDivider(),
          _buildListTile(context, "Passport Details", Icons.book_outlined, const PassportDetailsView()),
          _buildDivider(),
          _buildListTile(context, "Account Verification", Icons.verified_user_outlined, const AccountVerificationView()),
          _buildDivider(),
          _buildListTile(context, "Support Center", Icons.support_agent_outlined, const SupportCenterView()),
          _buildDivider(),
          _buildDeleteAccountTile(context),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, Widget view) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => view),
        );
      },
    );
  }

  Widget _buildDeleteAccountTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
      ),
      title: Text(
        "Delete Account",
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.error),
      ),
      onTap: () {
        _showDeleteConfirmationDialog(context);
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Account", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Handle account deletion logic
              Navigator.pop(ctx);
              
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              
            },
            child: Text("Delete", style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

   Widget _buildLogoutButton(BuildContext context, AuthViewModel authViewModel) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
            await authViewModel.signOut();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
        }, 
        child: Text("Logout", style: GoogleFonts.poppins(color: AppColors.grey))
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 60);
  }
}
