import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';
import '../../core/utils/date_formatter.dart';
import 'status_badge.dart';
import 'priority_badge.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.id,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormatter.timeAgo(ticket.createdAt),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                ticket.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              Text(
                ticket.description.isNotEmpty
                    ? ticket.description
                    : '-',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  StatusBadge(
                    status: ticket.status,
                    small: true,
                  ),
                  const SizedBox(width: 6),

                  PriorityBadge(
                    priority: ticket.priority,
                    small: true,
                  ),
                  const SizedBox(width: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.category,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),

                  const Spacer(),

                  if (ticket.assignedTo != null)
                    Row(
                      children: const [
                        Icon(Icons.person,
                            size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Assigned',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}