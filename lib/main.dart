import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/core/change_languague/app_locazications.dart';
import 'package:math_app/core/shared_preferences/shared_prefs.dart';
import 'package:math_app/splash.dart';
import 'package:math_app/ultis/colors.dart';
import 'package:provider/provider.dart';
import 'core/setting/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize SharedPrefs first
  await SharedPrefs.init();

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => settingsProvider)],
      child: EasyLocalization(
        supportedLocales: const [
          AppLocazications.engLocale,
          AppLocazications.viLocale,
        ],
        path: AppLocazications.translationFile,
        saveLocale: true,
        fallbackLocale: AppLocazications.viLocale,
        startLocale: AppLocazications.viLocale,
        child: const MathApp(),
      ),
    ),
  );
}

class MathApp extends StatelessWidget {
  const MathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Size của iPhone 13
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.white,
            scaffoldBackgroundColor: TColors.yellow2,
          ),
          debugShowCheckedModeBanner: false,
          locale: context.locale, // Sử dụng ngôn ngữ từ EasyLocalization
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          home: SafeArea(child: Splash()),
        );
      },
    );
  }
}
