import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:utsmobile/core/router/app_router.dart';
import 'package:utsmobile/core/theme/app_theme.dart';
import 'package:utsmobile/data/services/local_storage_service.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/ticket_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();
  await LocalStorageService.seedDefaultUsers();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const ETicketingApp(),
    ),
  );
}

class ETicketingApp extends StatefulWidget {
  const ETicketingApp({super.key});

  @override
  State<ETicketingApp> createState() => _ETicketingAppState();
}

class _ETicketingAppState extends State<ETicketingApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    final auth = context.read<AuthProvider>();
    _router = createRouter(auth);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));

      auth.restoreSession();

      await Future.delayed(const Duration(milliseconds: 50));

      if (auth.isLoggedIn) {
        final userId = auth.currentUser!.id;

        await context.read<TicketProvider>().loadTickets();
        context.read<NotificationProvider>().loadForUser(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'E-Ticketing Helpdesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}