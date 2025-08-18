import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/finance_provider.dart';
import 'pages/home_page.dart';

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Personal Finance',
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
