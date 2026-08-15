import 'package:art_port/core/theme/app_theme.dart';
import 'package:art_port/features/auth/presentation/auth_bootstrap_provider.dart';
import 'package:art_port/features/common/presentation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(
    const ProviderScope(
      child: ArtPortApp(),
    ),
  );
}

class ArtPortApp extends ConsumerWidget {
  const ArtPortApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authBootstrapProvider);

    return MaterialApp(
      title: 'ArtPort',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
