import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_routes.dart';
import 'models/check_in.dart';
import 'providers/check_in_provider.dart';
import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_check_in_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FieldCheckApp());
}

class FieldCheckApp extends StatelessWidget {
  const FieldCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckInProvider(),
      child: MaterialApp(
        title: 'FieldCheck',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.newCheckIn: (_) => const NewCheckInScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.detail) {
            final checkIn = settings.arguments;
            if (checkIn is CheckIn) {
              return MaterialPageRoute(
                builder: (_) => DetailScreen(checkIn: checkIn),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
