import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:utsmobile/presentation/providers/auth_provider.dart';
import 'package:utsmobile/presentation/providers/ticket_provider.dart';
import 'package:utsmobile/presentation/widget/ticket_card.dart';
import 'package:utsmobile/core/constants/app_constants.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

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

    final tickets = user.isHelpdesk
        ? ticketProv.filteredTickets
        : ticketProv.filteredTickets
        .where((t) => t.userId == user.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tiket')),
      body: tickets.isEmpty
          ? const Center(child: Text('Tidak ada tiket'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: tickets
            .map((t) => TicketCard(
          ticket: t,
          onTap: () =>
              context.push('/tickets/${t.id}'),
        ))
            .toList(),
      ),
    );
  }
}