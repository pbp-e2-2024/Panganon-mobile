import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:panganon_mobile/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'PANGANON',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Colors.black, // Primary color
            onPrimary: Colors.white, // Text/Icon color on primary
            secondary: Colors.grey, // Secondary color
            onSecondary: Colors.white, // Text/Icon color on secondary
            error: Colors.red, // Error color
            onError: Colors.white, // Text/Icon color on error
            surface: Colors.white, // Surface color
            onSurface: Colors.black, // Text/Icon color on surface
          ),
        ),
        home: const LoginPage(),
      ),
    );
  }
}

