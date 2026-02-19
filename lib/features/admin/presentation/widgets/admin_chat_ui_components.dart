import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/admin_view_model.dart';

class AdminUserList extends StatelessWidget {
  final AdminViewModel vm;
  final Function(String userId, String userName) onUserTap;

  const AdminUserList({
    super.key,
    required this.vm,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.lightGrey, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: AppColors.lightGrey, width: 1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: AppColors.primaryBlue, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Conversations',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                // Refresh button
                IconButton(
                  onPressed: () => vm.fetchThreads(),
                  icon: const Icon(Icons.refresh, color: AppColors.grey, size: 20),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          // User threads list
          Expanded(
            child: vm.isLoadingThreads
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : vm.threads.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox, size: 48, color: AppColors.grey.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'No conversations yet',
                              style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: vm.threads.length,
                        itemBuilder: (context, index) {
                          final thread = vm.threads[index];
                          final isSelected = vm.selectedUserId == thread['user_id'];
                          final unread = thread['unread_count'] as int? ?? 0;
                          final userName = (thread['user_name'] as String?)?.isNotEmpty == true
                              ? thread['user_name'] as String
                              : 'Unknown User';
                          final lastMsg = thread['last_message'] as String? ?? '';
                          final initials = userName.trim().split(' ').take(2)
                              .map((e) => e.isNotEmpty ? e[0] : '')
                              .join()
                              .toUpperCase();

                          return Material(
                            color: isSelected ? AppColors.primaryBlue.withOpacity(0.08) : Colors.transparent,
                            child: InkWell(
                              onTap: () => onUserTap(
                                thread['user_id'] as String,
                                userName,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                                      width: 3,
                                    ),
                                    bottom: BorderSide(color: AppColors.lightGrey.withOpacity(0.5), width: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: isSelected
                                          ? AppColors.primaryBlue
                                          : AppColors.primaryBlue.withOpacity(0.1),
                                      child: Text(
                                        initials,
                                        style: GoogleFonts.poppins(
                                          color: isSelected ? Colors.white : AppColors.primaryBlue,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Name + last message
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: GoogleFonts.poppins(
                                              fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            lastMsg,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Unread badge
                                    if (unread > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          unread.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class AdminChatPanel extends StatelessWidget {
  final AdminViewModel vm;

  const AdminChatPanel({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.selectedUserId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_outlined, size: 64, color: AppColors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'Select a conversation',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a user from the list to view their messages',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Chat Header ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(bottom: BorderSide(color: AppColors.lightGrey, width: 1)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryBlue,
                child: Text(
                  vm.selectedUserName?.trim().split(' ').take(2)
                      .map((e) => e.isNotEmpty ? e[0] : '')
                      .join()
                      .toUpperCase() ?? '?',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.selectedUserName ?? 'User',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Support conversation',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── Messages ──
        Expanded(
          child: vm.isLoadingChat
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
              : vm.chatMessages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages in this conversation',
                        style: GoogleFonts.poppins(color: AppColors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.chatMessages.length,
                      itemBuilder: (context, index) {
                        final msg = vm.chatMessages[index];
                        final isAdmin = msg.senderRole == 'admin';
                        return _buildMessageBubble(msg, isAdmin);
                      },
                    ),
        ),
        // ── Reply Input ──
        _buildReplyInput(context),
      ],
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isAdmin) {
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: isAdmin ? AppColors.primaryBlue : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 16 : 4),
            bottomRight: Radius.circular(isAdmin ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.messageText,
              style: GoogleFonts.poppins(
                color: isAdmin ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.createdAt),
              style: GoogleFonts.poppins(
                color: isAdmin ? Colors.white70 : AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(BuildContext context) {
    final controller = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.lightGrey, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your reply...',
                hintStyle: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  vm.sendReply(text);
                  controller.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primaryBlue,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (controller.text.trim().isNotEmpty) {
                  vm.sendReply(controller.text);
                  controller.clear();
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);

    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final time = '$h:$m $ampm';

    if (date == today) return time;

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, $time';
  }
}
