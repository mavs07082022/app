import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/zone_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CropApp());
}

class CropApp extends StatelessWidget {
  const CropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ZoneProvider()),
      ],
      child: MaterialApp(
        title: 'Crop Suitability',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeScreen(),
      ),
    );
  }
}