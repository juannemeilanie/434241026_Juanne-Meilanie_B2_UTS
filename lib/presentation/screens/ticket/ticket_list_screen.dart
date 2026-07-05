import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:utsmobile/presentation/providers/auth_provider.dart';
import 'package:utsmobile/presentation/providers/ticket_provider.dart';
import 'package:utsmobile/presentation/widget/ticket_card.dart';
import 'package:utsmobile/core/constants/app_constants.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  Future<void> _confirmDelete(
      BuildContext context,
      String ticketId,
      ) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Tiket'),
        content: const Text('Yakin ingin menghapus tiket ini?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    final success = await context
        .read<TicketProvider>()
        .deleteTicket(ticketId);

    if (!context.mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Tiket berhasil dihapus'
              : 'Tiket tidak bisa dihapus karena sudah ditangani',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ticketProv = context.watch<TicketProvider>();

    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tickets = user.isAdmin
        ? ticketProv.filteredTickets
        : user.isHelpdesk
          ? ticketProv.filteredTickets
            .where((t) => t.assignedTo == user.id)
            .toList()
          : ticketProv.filteredTickets
            .where((t) => t.userId == user.id)
            .toList();

    return Scaffold(
        appBar: AppBar(title: const Text('Tiket')),
        body: tickets.isEmpty
            ? const Center(child: Text('Tidak ada tiket'))
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final t = tickets[index];
            final canDelete =
                t.userId == user.id && t.assignedTo == null;

            return Stack(
              children: [
                TicketCard(
                  ticket: t,
                  onTap: () => context.push('/tickets/${t.id}'),
                ),
                if (canDelete)
                  Positioned(
                    top: 90,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      tooltip: 'Hapus tiket',
                      onPressed: () => _confirmDelete(context, t.id),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/create-ticket'),
          child: const Icon(Icons.add),
        ),
    );
  }
}