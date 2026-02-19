import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/admin_view_model.dart';
import '../widgets/admin_chat_ui_components.dart';
import '../screens/admin_chat_detail_screen.dart';

class AdminChatView extends StatelessWidget {
  const AdminChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Check if we are in desktop mode (split view) or mobile (list only)
            // Note: AdminDashboardScreen already handles the main layout switch > 600.
            // But within AdminChatView, we might assume full width available.
            // If the parent is Row (Desktop), we have an Expanded width.
            // If parent is Column/Body (Mobile), we have full width.
            
            // Actually, AdminDashboardScreen decides if we are in Mobile or Desktop mode layout.
            // But AdminChatView needs to know if it should show Split View or just List.
            // The LayoutBuilder here will see the width of the parent (the content area).
            // On Desktop: content area is width - 240px.
            // On Mobile: content area is full width.
            
            // Let's use a breakpoint. Since AdminDashboardScreen uses 600 for the main layout switch,
            // we can stick to that or check if we have enough space for split view.
            // AdminUserList is 320px fixed. So checks should be > 600 effectively.
            
            final isDesktop = MediaQuery.of(context).size.width >= 800; 
            // Using 800 here because on 600-800 range, split view might be too cramped (320px list + minimal chat).
            
            if (isDesktop) {
              return Row(
                children: [
                  Expanded(
                     flex: 3,
                     child: AdminUserList(
                       vm: vm,
                       onUserTap: (userId, userName) {
                         vm.selectUser(userId, userName);
                       },
                     ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: AppColors.lightGrey, width: 1)),
                      ),
                      child: AdminChatPanel(vm: vm),
                    ),
                  ),
                ],
              );
            } else {
              // Mobile / Tablet Portrait: Show List Only. Navigate to Detail on Tap.
              // Note: AdminUserList has a fixed width of 320 in the extracted widget.
              // We should probably make it flexible or full width here.
              // The extracted widget has `width: 320`. We might need to override it or wrap it.
              
              // To fix the fixed width 320 in AdminUserList, we should update AdminUserList to be flexible.
              // But for now let's wrap it in a Container with width double.infinity if needed,
              // OR better, update AdminUserList to take width as optional param or use constraints.
              
              return SizedBox(
                 width: double.infinity,
                 child: AdminUserList(
                    vm: vm, 
                    onUserTap: (userId, userName) {
                      vm.selectUser(userId, userName);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            child: const AdminChatDetailScreen(),
                          ),
                        ),
                      );
                    },
                 ),
              ); 
            }
          },
        );
      },
    );
  }
}
