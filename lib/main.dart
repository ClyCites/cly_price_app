import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/product_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/prediction_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/connectivity_provider.dart';  // Import ConnectivityProvider
import 'core/services/service_locator.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ensure service locator is initialized before app starts
  try {
    await setupServiceLocator();
  } catch (e) {
    // Log or handle error accordingly
    print("Error during service locator setup: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()), // Add ConnectivityProvider
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'ClyCites',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: settingsProvider.settings.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
