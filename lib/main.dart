import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/data_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if running in portable mode
  await _initializePortableMode();
  
  // Initialize default data only on first run
  await DataService.initializeDefaultData();
  
  runApp(const ExpenseManagementApp());
}

Future<void> _initializePortableMode() async {
  // Check environment variables for portable mode
  final isPortable = Platform.environment['EXPENSE_APP_PORTABLE'] == 'true';
  final customDataDir = Platform.environment['EXPENSE_APP_DATA_DIR'];
  
  if (isPortable && customDataDir != null) {
    print('Running in portable mode');
    print('Data directory: $customDataDir');
    await DataService.initializePortableMode(customDataDir);
  } else {
    // Default behavior - store relative to executable
    print('Running in standard mode with relative data path');
    // DataService will automatically use relative path
  }
}

class ExpenseManagementApp extends StatelessWidget {
  const ExpenseManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Management - Portable Edition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}