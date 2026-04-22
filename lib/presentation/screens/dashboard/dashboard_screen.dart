import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:utsmobile/presentation/providers/ticket_provider.dart';
import 'package:utsmobile/presentation/providers/auth_provider.dart';
import 'package:utsmobile/presentation/providers/notification_provider.dart';

import 'package:utsmobile/presentation/widget/ticket_card.dart';
import 'package:utsmobile/presentation/widget/stat_card.dart';
import 'package:utsmobile/presentation/widget/user_avatar.dart';

import 'package:utsmobile/core/constants/app_constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Pagi';
    if (hour < 17) return 'Siang';
    if (hour < 20) return 'Sore';
    return 'Malam';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final ticketProvider = context.watch<TicketProvider>(); // ✅ FIX
    final notifProvider = context.watch<NotificationProvider>();

    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadForUser(user.id);
    });


    final theme = Theme.of(context);

    final stats = user.isHelpdesk
        ? ticketProvider.stats
        : ticketProvider.getStatsByUser(user.id);

    final recentTickets = user.isHelpdesk
        ? ticketProvider.getRecentTickets()
        : ticketProvider.getRecentTickets(userId: user.id);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ticketProvider.loadTickets();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: AppColors.primary,
              title: const Text(
                AppStrings.dashboard,
                style: TextStyle(color: Colors.white),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          UserAvatar(user: user, radius: 26),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Halo, ${_greeting()} ${user.name.split(' ').first}! 👋',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(0.2),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    user.role.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    context.go('/notifications'),
                              ),
                              if (notifProvider.unreadCount > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding:
                                    const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.error,                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    constraints:
                                    const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Center(
                                      child: Text(
                                        notifProvider.unreadCount >
                                            99
                                            ? '99+'
                                            : '${notifProvider.unreadCount}',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Tiket',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.4,
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          label: 'Total',
                          value: stats['total'] ?? 0,
                          color: AppColors.primary,
                          icon: Icons.confirmation_number,
                        ),
                        StatCard(
                          label: 'Open',
                          value: stats['open'] ?? 0,
                          color: AppColors.primary,
                          icon: Icons.fiber_new,
                        ),
                        StatCard(
                          label: 'Progress',
                          value: stats['in_progress'] ?? 0,
                          color: AppColors.warning,
                          icon: Icons.pending_actions,
                        ),
                        StatCard(
                          label: 'Resolved',
                          value: stats['resolved'] ?? 0,
                          color: AppColors.success,
                          icon: Icons.check_circle,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (user.isUser)
                      const SizedBox(height: 24),

                    if (user.isHelpdesk) ...[
                      _buildHelpdeskInfo(
                          context, ticketProvider, user.id),
                      const SizedBox(height: 24),
                    ],

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiket Terbaru',
                          style:
                          theme.textTheme.headlineSmall,
                        ),
                        TextButton(
                          onPressed: () =>
                              context.go('/tickets'),
                          child:
                          const Text('Lihat Semua'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (recentTickets.isEmpty)
                      const Center(
                          child: Text('Belum ada tiket'))
                    else
                      ...recentTickets.map(
                            (t) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8),
                          child: TicketCard(
                            ticket: t,
                            onTap: () => context
                                .push('/tickets/${t.id}'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: user.isUser
          ? FloatingActionButton(
        onPressed: () =>
            context.push('/create-ticket'),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildHelpdeskInfo(
      BuildContext context, TicketProvider provider, String helpdeskId) {

    final theme = Theme.of(context);

    final myTickets = provider.filteredTickets
        .where((t) =>
    t.assignedTo == helpdeskId &&
        t.status == 'in_progress')
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assignment_ind,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${myTickets.length} tiket sedang kamu tangani',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}