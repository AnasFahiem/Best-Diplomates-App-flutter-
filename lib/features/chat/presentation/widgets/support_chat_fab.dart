import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/chat_view_model.dart';
import 'chat_bottom_sheet.dart';

class SupportChatFab extends StatelessWidget {
  const SupportChatFab({super.key});

  void _openChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: Provider.of<ChatViewModel>(context, listen: false),
        child: const ChatBottomSheet(),
      ),
    ).whenComplete(() {
      // Ensure chat is marked as closed when the sheet is dismissed
      Provider.of<ChatViewModel>(context, listen: false).setChatOpen(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, chatVM, _) {
        final unread = chatVM.unreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // FAB
            Material(
              elevation: 6,
              shadowColor: AppColors.primaryBlue.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => _openChatSheet(context),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.headset_mic,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
            // Badge
            if (unread > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      unread > 99 ? '99+' : unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
