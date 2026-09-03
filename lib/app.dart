import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'biometrics/biometric_service.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'screens/transfer_screen.dart';
import 'telephony/call_state_service.dart';

class SynapApp extends StatelessWidget {
  const SynapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BiometricService()),
        ChangeNotifierProvider(create: (_) => CallStateService()..initialize()),
      ],
      child: MaterialApp(
        title: 'Synap',
        debugShowCheckedModeBanner: false,
        theme: AegisTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/transfer': (context) => const TransferScreen(),
        },
      ),
    );
  }
}
