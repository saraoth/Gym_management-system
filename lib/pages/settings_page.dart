import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_layout.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _gymName = 'GymFlow Fitness Center';
  String _openingTime = '06:00 AM';
  String _closingTime = '10:00 PM';
  String _phone = '+20 123 456 7890';
  String _email = 'info@gymflow.com';
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _expiryReminders = true;
  int _reminderDays = 7;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/settings',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your gym settings and preferences',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            
            // General Settings
            _buildSection(
              'General Settings',
              [
                _buildEditableSettingItem(
                  'Gym Name',
                  _gymName,
                  Icons.business,
                  () => _showEditDialog('Gym Name', _gymName, (value) {
                    setState(() => _gymName = value);
                  }),
                ),
                _buildEditableSettingItem(
                  'Business Hours',
                  '$_openingTime - $_closingTime',
                  Icons.access_time,
                  () => _showBusinessHoursDialog(),
                ),
                _buildEditableSettingItem(
                  'Contact Information',
                  '$_phone • $_email',
                  Icons.contact_phone,
                  () => _showContactDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Membership Settings
            _buildSection(
              'Membership Settings',
              [
                _buildSettingItem(
                  'Subscription Plans',
                  'Manage membership plans and pricing',
                  Icons.card_membership,
                  () {
                    Navigator.of(context).pushNamed('/plans');
                  },
                ),
                _buildSettingItem(
                  'Payment Methods',
                  'Cash, Card, Bank Transfer',
                  Icons.payment,
                  () {},
                ),
                _buildSettingItem(
                  'Late Fees',
                  'Configure late payment policies',
                  Icons.warning,
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Notifications
            _buildSection(
              'Notifications',
              [
                _buildSwitchSettingItem(
                  'Email Notifications',
                  'Receive alerts via email',
                  Icons.email,
                  _emailNotifications,
                  (value) {
                    setState(() => _emailNotifications = value);
                  },
                ),
                _buildSwitchSettingItem(
                  'SMS Notifications',
                  'Receive alerts via SMS',
                  Icons.sms,
                  _smsNotifications,
                  (value) {
                    setState(() => _smsNotifications = value);
                  },
                ),
                _buildSwitchSettingItem(
                  'Expiry Reminders',
                  'Send membership expiry alerts $_reminderDays days before',
                  Icons.notifications,
                  _expiryReminders,
                  (value) {
                    setState(() => _expiryReminders = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // System
            _buildSection(
              'System',
              [
                _buildSettingItem(
                  'Backup Data',
                  'Export and backup your data',
                  Icons.backup,
                  () {
                    _showBackupDialog();
                  },
                ),
                _buildSettingItem(
                  'User Management',
                  'Manage staff accounts and permissions',
                  Icons.people,
                  () {},
                ),
                _buildSettingItem(
                  'About',
                  'GymFlow v1.0.0',
                  Icons.info,
                  () {
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableSettingItem(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit,
                color: Colors.white.withOpacity(0.3),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchSettingItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String title, String currentValue, ValueChanged<String> onSave) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Edit $title',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0A0A0A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: Text('Save', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  void _showBusinessHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Business Hours',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Business hours configuration coming soon',
          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: Text('OK', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Contact Information',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Contact information configuration coming soon',
          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: Text('OK', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Backup Data',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Text(
          'Data backup and export functionality coming soon',
          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: Text('OK', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'About GymFlow',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GymFlow Gym Management System',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6)),
            ),
            const SizedBox(height: 16),
            Text(
              'A comprehensive gym management solution for tracking members, trainers, payments, and attendance.',
              style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: Text('OK', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }
}
