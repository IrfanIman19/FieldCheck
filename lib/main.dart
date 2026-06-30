import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/check_in_store.dart';
import 'screens/home_screen.dart';

const fieldCheckRed = Color(0xFFE6332A);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = CheckInStore();
  await store.load(); // restore saved history before first frame
  runApp(FieldCheckApp(store: store));
}

class FieldCheckApp extends StatelessWidget {
  final CheckInStore store;
  const FieldCheckApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CheckInStore>.value(
      value: store,
      child: MaterialApp(
        title: 'FieldCheck',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
          colorScheme: ColorScheme.fromSeed(
            seedColor: fieldCheckRed,
            primary: fieldCheckRed,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: fieldCheckRed,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: fieldCheckRed,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: fieldCheckRed),
          ),
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
