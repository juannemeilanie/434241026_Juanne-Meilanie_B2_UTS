import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utsmobile/presentation/providers/theme_provider.dart';
import 'package:utsmobile/presentation/providers/auth_provider.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),

            Text(
              user?.name ?? '-',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(user?.email ?? '-'),

            const SizedBox(height: 20),

            // Dark Mode
            Consumer<ThemeProvider>(
              builder: (ctx, theme, _) => SwitchListTile(
                title: const Text('Dark Mode'),
                value: theme.isDark,
                onChanged: (_) => theme.toggleTheme(),
              ),
            ),

            const Spacer(),

            // Logout
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