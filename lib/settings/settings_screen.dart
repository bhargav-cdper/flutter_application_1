import 'package:flutter/material.dart';
import '../settings/jobs_setting_screen.dart';
import '../settings/accounts_setting_screen.dart';
import '../settings/cash_bank_setting_screen.dart';
import '../settings/parties_setting_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingItem(
            context,
            'Jobs',
            'Manage job categories',
            Icons.work,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobsSettingScreen()),
            ),
          ),
          _buildSettingItem(
            context,
            'Accounts',
            'Manage account types',
            Icons.account_balance,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountsSettingScreen()),
            ),
          ),
          _buildSettingItem(
            context,
            'Cash/Bank Options',
            'Manage payment methods',
            Icons.payment,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CashBankSettingScreen()),
            ),
          ),
          _buildSettingItem(
            context,
            'Parties',
            'Manage parties/contacts',
            Icons.people,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PartiesSettingScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}