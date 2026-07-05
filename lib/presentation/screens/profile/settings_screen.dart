import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsmobile/presentation/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = 'Indonesia';

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollController) => Column(
          children: [
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                      fontSize: 12,
                      color: Colors.grey,
                    ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Consumer<ThemeProvider>(
            builder: (ctx, theme, _) => SwitchListTile(
              title: const Text('Dark Mode'),
              value: theme.isDark,
              onChanged: (_) => theme.toggleTheme(),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Bahasa'),
            subtitle: Text(selectedLanguage),
            onTap: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Pilih Bahasa'),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, 'Indonesia'),
                      child: const Text('Indonesia'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, 'English'),
                      child: const Text('English'),
                    ),
                  ],
                ),
              );

              if (result != null) {
                setState(() {
                  selectedLanguage = result;
                });
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Kebijakan Privasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyPolicy(context),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({
    required this.title,
    required this.content,
  });

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
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}