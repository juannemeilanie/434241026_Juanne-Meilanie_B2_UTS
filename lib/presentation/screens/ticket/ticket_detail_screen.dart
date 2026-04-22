import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsmobile/presentation/providers/auth_provider.dart';
import 'package:utsmobile/presentation/providers/ticket_provider.dart';
import 'dart:io';
import 'package:utsmobile/data/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:utsmobile/presentation/widget/status_badge.dart';
import 'package:utsmobile/presentation/widget/priority_badge.dart';
import 'package:utsmobile/presentation/widget/comment_bubble.dart';

import 'package:utsmobile/core/constants/app_constants.dart';
import 'package:utsmobile/core/utils/date_formatter.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  @override
  State<TicketDetailScreen> createState() =>
      _TicketDetailScreenState();
}

class _TicketDetailScreenState
    extends State<TicketDetailScreen> {
  final _commentCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  bool _isSendingComment = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final ticketProv = context.read<TicketProvider>();

    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _isSendingComment = true);

    await ticketProv.addComment(
      ticketId: widget.ticketId,
      userId: user.id,
      userName: user.name,
      userRole: user.role,
      content: text,
    );

    _commentCtrl.clear();
    setState(() => _isSendingComment = false);

    await Future.delayed(const Duration(milliseconds: 200));

    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _showUpdateStatusDialog() async {
    final ticketProv = context.read<TicketProvider>();
    final auth = context.read<AuthProvider>();

    final user = auth.currentUser;
    final ticket = ticketProv.getTicketById(widget.ticketId);

    if (ticket == null || user == null) return;

    String selected = ticket.status;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Status Tiket'),
        content: StatefulBuilder(
          builder: (_, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: TicketConstants.statuses.map((s) {
                return RadioListTile<String>(
                  value: s,
                  groupValue: selected,
                  title:
                  Text(TicketConstants.statusLabel(s)),
                  onChanged: (val) {
                    if (val != null) {
                      setStateDialog(
                              () => selected = val);
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              if (selected != ticket.status) {
                await ticketProv.updateStatus(
                  widget.ticketId,
                  selected,
                  updatedByUserId: user.id,
                  updatedByName: user.name,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Status berhasil diperbarui'),
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAssignDialog() async {
    final ticketProv = context.read<TicketProvider>();

    final helpdesks = LocalStorageService.getUsers()
        .where((u) => u.isHelpdesk)
        .toList();

    String? selectedId;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assign ke Helpdesk'),
        content: StatefulBuilder(
          builder: (_, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: helpdesks.map((h) {
                return RadioListTile<String>(
                  value: h.id,
                  groupValue: selectedId,
                  title: Text(h.name),
                  subtitle: Text(h.email),
                  onChanged: (val) {
                    setStateDialog(
                            () => selectedId = val);
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              if (selectedId == null) return;

              final selectedUser =
              LocalStorageService.getUserById(
                  selectedId!);

              if (selectedUser == null) return;

              await ticketProv.assignTicket(
                ticketId: widget.ticketId,
                helpdeskId: selectedUser.id,
                helpdeskName: selectedUser.name,
              );

              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Tiket berhasil di-assign'),
                  ),
                );
              }
            },
            child: const Text('Assign'),
          ),
        ],
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
        body: Center(
            child: CircularProgressIndicator()),
      );
    }

    final ticket =
    ticketProv.getTicketById(widget.ticketId);

    if (ticket == null) {
      return Scaffold(
        appBar:
        AppBar(title: const Text('Detail Tiket')),
        body: const Center(
            child: Text('Tiket tidak ditemukan')),
      );
    }

    final comments =
    ticketProv.getCommentsByTicket(widget.ticketId);

    final assignedUser = ticket.assignedTo != null
        ? LocalStorageService.getUserById(
        ticket.assignedTo!)
        : null;

    final creatorUser =
    LocalStorageService.getUserById(ticket.userId);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.id),
        actions: [
          if (user.isHelpdesk)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'status') {
                  _showUpdateStatusDialog();
                }
                if (val == 'assign') {
                  _showAssignDialog();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'status',
                  child: Text('Update Status'),
                ),
                PopupMenuItem(
                  value: 'assign',
                  child: Text('Assign Tiket'),
                ),
              ],
            ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding:
              const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            ticket.title,
                            style: theme.textTheme
                                .headlineSmall,
                          ),
                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 6,
                            children: [
                              StatusBadge(
                                  status:
                                  ticket.status),
                              PriorityBadge(
                                  priority:
                                  ticket.priority),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Text(ticket.description),

                          if (ticket.attachments.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text('Lampiran:'),

                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              children: ticket.attachments.map((path) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.network(
                                    path,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                      : Image.file(
                                    File(path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 16),

                          Text(
                              'Pelapor: ${creatorUser?.name ?? '-'}'),
                          Text(
                              'Ditangani: ${assignedUser?.name ?? 'Belum ada'}'),
                          Text(DateFormatter
                              .formatDateTime(
                              ticket.createdAt)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Komentar (${comments.length})',
                    style: theme.textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  if (comments.isEmpty)
                    const Center(
                        child:
                        Text('Belum ada komentar'))
                  else
                    ...comments.map(
                          (c) => CommentBubble(
                        comment: c,
                        isCurrentUser:
                        c.userId == user.id,
                      ),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          if (ticket.status != 'closed')
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 8,
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                    8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      decoration:
                      const InputDecoration(
                        hintText:
                        'Tulis komentar...',
                      ),
                    ),
                  ),
                  _isSendingComment
                      ? const Padding(
                    padding:
                    EdgeInsets.all(8),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                          strokeWidth: 2),
                    ),
                  )
                      : IconButton(
                    onPressed: _sendComment,
                    icon:
                    const Icon(Icons.send),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}