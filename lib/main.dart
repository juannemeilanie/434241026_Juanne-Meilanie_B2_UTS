import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:utsmobile/core/router/app_router.dart';
import 'package:utsmobile/core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/ticket_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'package:utsmobile/data/services/local_storage_service.dart';
import 'package:utsmobile/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init local storage WAJIB sebelum runApp
  await LocalStorageService.init();
  await LocalStorageService.seedDefaultUsers();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
    final authProvider = context.read<AuthProvider>();

    // ✅ Restore session — cek apakah user pernah login sebelumnya
    authProvider.restoreSession();

    // Load data kalau sudah login
    if (authProvider.isLoggedIn) {
      final userId = authProvider.currentUser!.id;
      context.read<TicketProvider>().loadTickets();
      context.read<NotificationProvider>().loadForUser(userId);
    }

    // ✅ Router dibuat SEKALI di sini, bukan di build()
    _router = createRouter(authProvider);
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
