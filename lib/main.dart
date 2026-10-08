import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'services/supabase_service.dart';
import 'services/sync_service.dart';
import 'state/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Supabase (hoạt động offline-first an toàn nếu chưa điền key)
  await SupabaseService.initialize();

  // Khởi động lắng nghe kết nối mạng để tự động đồng bộ ngầm
  SyncService.instance.startListening();

  runApp(
    const ProviderScope(
      child: VkuBankOcrApp(),
    ),
  );
}

class VkuBankOcrApp extends ConsumerWidget {
  const VkuBankOcrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'VKU Bank Transfer OCR & Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
