import 'package:flutter/material.dart';
import 'package:utsmobile/data/models/user_model.dart';
import 'package:utsmobile/data/services/supabase_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() =>
      _ManageUsersScreenState();
}

class _ManageUsersScreenState
    extends State<ManageUsersScreen> {

  List<UserModel> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() {
      isLoading = true;
    });

    final data =
    await SupabaseService.getUsers();

    setState(() {
      users = data;
      isLoading = false;
    });
  }

  Future<void> _changeRole(UserModel user) async {
    final selected =
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ubah Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Admin'),
              onTap: () =>
                  Navigator.pop(
                      context, 'admin'),
            ),
            ListTile(
              title: const Text('Helpdesk'),
              onTap: () =>
                  Navigator.pop(
                      context,
                      'helpdesk'),
            ),
            ListTile(
              title: const Text('User'),
              onTap: () =>
                  Navigator.pop(
                      context, 'user'),
            ),
          ],
        ),
      ),
    );

    if (selected == null) return;

    final updatedUser =
    user.copyWith(role: selected);

    await SupabaseService.updateUser(
        updatedUser);

    await loadUsers();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Role berhasil diperbarui',
        ),
      ),
    );
  }

  Future<void> _deleteUser(
      UserModel user) async {
    final confirm =
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:
        const Text('Hapus Pengguna'),
        content: const Text(
          'Yakin ingin menghapus user ini?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    context, false),
            child:
            const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(
                    context, true),
            child:
            const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await SupabaseService.deleteUser(
        user.id);

    await loadUsers();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Pengguna berhasil dihapus',
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'helpdesk':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Kelola Pengguna'),
      ),

      body: isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: loadUsers,
        child: ListView.builder(
          padding:
          const EdgeInsets.all(
              16),
          itemCount: users.length,
          itemBuilder:
              (context, index) {
            final user =
            users[index];

            return Card(
              margin:
              const EdgeInsets.only(
                bottom: 12,
              ),
              child: ListTile(
                leading:
                CircleAvatar(
                  child: Text(
                    user.initials,
                  ),
                ),

                title:
                Text(user.name),

                subtitle: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(user.email),

                    const SizedBox(
                        height: 4),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                      BoxDecoration(
                        color: _roleColor(
                            user.role)
                            .withOpacity(
                            0.15),
                        borderRadius:
                        BorderRadius
                            .circular(
                            8),
                      ),
                      child: Text(
                        user.role
                            .toUpperCase(),
                        style:
                        TextStyle(
                          color:
                          _roleColor(
                              user
                                  .role),
                          fontWeight:
                          FontWeight
                              .bold,
                          fontSize:
                          12,
                        ),
                      ),
                    ),
                  ],
                ),

                trailing:
                PopupMenuButton(
                  itemBuilder: (_) =>
                  [
                    const PopupMenuItem(
                      value: 'role',
                      child: Text(
                          'Ubah Role'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                          'Hapus'),
                    ),
                  ],

                  onSelected:
                      (value) {
                    if (value ==
                        'role') {
                      _changeRole(
                          user);
                    }

                    if (value ==
                        'delete') {
                      _deleteUser(
                          user);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}