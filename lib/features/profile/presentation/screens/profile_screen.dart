import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../views/basic_info_view.dart';
import '../views/certificates_view.dart';
import '../views/passport_details_view.dart';
import '../views/support_center_view.dart';
import '../views/account_verification_view.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
             const SizedBox(height: 20),
            // Profile Header
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.white,
              child: CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.navyBlue,
                  child: Text("AF", style: TextStyle(fontSize: 30, color: AppColors.gold))),
            ),
            const SizedBox(height: 15),
            Text(
              "Anas Fahiem",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            Text(
              "anas@example.com",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Profile Options
            _buildProfileCard(context),
            
            const SizedBox(height: 20),
             _buildLogoutButton(context),
          ],
        ),
      ),
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
          color: AppColors.navyBlue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.navyBlue, size: 20),
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
   Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: (){
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
        }, 
        child: Text("Logout", style: GoogleFonts.poppins(color: AppColors.grey))
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 60);
  }
}
