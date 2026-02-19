import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/admin_view_model.dart';
import '../widgets/admin_chat_ui_components.dart';

class AdminChatDetailView extends StatelessWidget {
  const AdminChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminViewModel>(context);
    
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          vm.selectedUserName ?? 'Chat',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: AdminChatPanel(vm: vm),
    );
  }
}
