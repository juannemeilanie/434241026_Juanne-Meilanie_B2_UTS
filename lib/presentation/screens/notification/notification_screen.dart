import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:utsmobile/presentation/providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProv = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: notifProv.markAllAsRead,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: notifProv.notifications.length,
        itemBuilder: (context, index) {
          final notif = notifProv.notifications[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: notif.isRead
                  ? Colors.grey[300]
                  : Colors.blue[100],
              child: Icon(
                Icons.notifications,
                color: notif.isRead ? Colors.grey : Colors.blue,
              ),
            ),
            title: Text(
              notif.title,
              style: TextStyle(
                fontWeight:
                notif.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Text(notif.body),
            trailing: Text(
              "${notif.createdAt.hour}:${notif.createdAt.minute}",
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () {
              notifProv.markAsRead(notif.id);
              context.push('/tickets/${notif.ticketId}');

            },
          );
        },
      ),
    );
  }
}