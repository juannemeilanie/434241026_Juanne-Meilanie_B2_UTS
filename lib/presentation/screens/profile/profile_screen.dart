import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsmobile/presentation/providers/theme_provider.dart';
import 'package:utsmobile/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, dynamic user) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Panggil method update di AuthProvider jika tersedia
              // context.read<AuthProvider>().updateProfile(
              //   name: nameController.text,
              //   email: emailController.text,
              // );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil berhasil diperbarui')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kebijakan Privasi',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: const [
                  _PolicySection(
                    title: '1. Pengumpulan Data',
                    content:
                    'Kami mengumpulkan informasi yang Anda berikan secara langsung, seperti nama dan alamat email saat mendaftar atau memperbarui profil Anda.',
                  ),
                  _PolicySection(
                    title: '2. Penggunaan Data',
                    content:
                    'Data Anda digunakan untuk menyediakan, memelihara, dan meningkatkan layanan kami, serta untuk berkomunikasi dengan Anda terkait pembaruan atau notifikasi penting.',
                  ),
                  _PolicySection(
                    title: '3. Keamanan Data',
                    content:
                    'Kami menerapkan langkah-langkah keamanan teknis dan organisasi yang wajar untuk melindungi informasi pribadi Anda dari akses yang tidak sah.',
                  ),
                  _PolicySection(
                    title: '4. Berbagi Data',
                    content:
                    'Kami tidak menjual atau menyewakan informasi pribadi Anda kepada pihak ketiga tanpa persetujuan Anda, kecuali diwajibkan oleh hukum.',
                  ),
                  _PolicySection(
                    title: '5. Hak Pengguna',
                    content:
                    'Anda berhak mengakses, memperbarui, atau menghapus informasi pribadi Anda kapan saja melalui pengaturan akun atau dengan menghubungi tim dukungan kami.',
                  ),
                  _PolicySection(
                    title: '6. Perubahan Kebijakan',
                    content:
                    'Kami dapat memperbarui kebijakan privasi ini sewaktu-waktu. Perubahan signifikan akan diberitahukan melalui notifikasi aplikasi atau email.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Terakhir diperbarui: Juni 2025',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar dengan tombol edit
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                GestureDetector(
                  onTap: () => _showEditProfileDialog(context, user),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              user?.name ?? '-',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(user?.email ?? '-'),

            const SizedBox(height: 20),

            // Dark Mode Toggle
            Consumer<ThemeProvider>(
              builder: (ctx, theme, _) => SwitchListTile(
                title: const Text('Dark Mode'),
                value: theme.isDark,
                onChanged: (_) => theme.toggleTheme(),
              ),
            ),

            // Edit Profil
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: const Text('Edit Profil'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showEditProfileDialog(context, user),
            ),

            // Privacy Policy
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Kebijakan Privasi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPrivacyPolicy(context),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade800,
              ),
              onPressed: () {
                context.read<AuthProvider>().logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget helper untuk tiap section privacy policy
class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}