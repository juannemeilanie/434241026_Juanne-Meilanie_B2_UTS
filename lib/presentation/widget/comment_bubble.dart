import 'package:flutter/material.dart';
import 'package:utsmobile/data/models/comment_model.dart';

class CommentBubble extends StatelessWidget {
  final CommentModel comment;
  final bool isCurrentUser;

  const CommentBubble({
    super.key,
    required this.comment,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment:
      isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? colorScheme.primary.withOpacity(0.15)
                  : colorScheme.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                Radius.circular(isCurrentUser ? 16 : 4),
                bottomRight:
                Radius.circular(isCurrentUser ? 4 : 16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style:
                  theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  comment.content,
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _formatTime(comment.createdAt),
                    style:
                    theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}