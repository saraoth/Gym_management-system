import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../widgets/side_navigation.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _emailNotifications = true;
  String _language = 'English';
  String _currency = 'EGP (E£)';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile) const SideNavigation(currentRoute: '/settings'),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (isMobile)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {},
                        ),
                      Text(
                        'Settings',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section
                        _buildSection(
                          context,
                          'Profile Settings',
                          Icons.person,
                          [
                            _buildProfileCard(context),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Appearance Section
                        _buildSection(
                          context,
                          'Appearance',
                          Icons.palette,
                          [
                            _buildSettingTile(
                              context,
                              'Dark Mode',
                              'Enable dark theme',
                              Icons.dark_mode,
                              trailing: Switch(
                                value: _darkMode,
                                onChanged: (value) {
                                  setState(() {
                                    _darkMode = value;
                                  });
                                },
                              ),
                            ),
                            _buildSettingTile(
                              context,
                              'Language',
                              'Select your preferred language',
                              Icons.language,
                              trailing: DropdownButton<String>(
                                value: _language,
                                underline: const SizedBox(),
                                items: ['English', 'Arabic']
                                    .map((lang) => DropdownMenuItem(
                                          value: lang,
                                          child: Text(lang),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _language = value!;
                                  });
                                },
                              ),
                            ),
                            _buildSettingTile(
                              context,
                              'Currency',
                              'Select your preferred currency',
                              Icons.attach_money,
                              trailing: DropdownButton<String>(
                                value: _currency,
                                underline: const SizedBox(),
                                items: ['EGP (E£)']
                                    .map((curr) => DropdownMenuItem(
                                          value: curr,
                                          child: Text(curr),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _currency = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Notifications Section
                        _buildSection(
                          context,
                          'Notifications',
                          Icons.notifications,
                          [
                            _buildSettingTile(
                              context,
                              'Push Notifications',
                              'Receive push notifications',
                              Icons.notifications_active,
                              trailing: Switch(
                                value: _notifications,
                                onChanged: (value) {
                                  setState(() {
                                    _notifications = value;
                                  });
                                },
                              ),
                            ),
                            _buildSettingTile(
                              context,
                              'Email Notifications',
                              'Receive email notifications',
                              Icons.email,
                              trailing: Switch(
                                value: _emailNotifications,
                                onChanged: (value) {
                                  setState(() {
                                    _emailNotifications = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Gym Information Section
                        _buildSection(
                          context,
                          'Gym Information',
                          Icons.fitness_center,
                          [
                            _buildGymInfoCard(context),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Security Section
                        _buildSection(
                          context,
                          'Security',
                          Icons.security,
                          [
                            _buildSettingTile(
                              context,
                              'Change Password',
                              'Update your password',
                              Icons.lock,
                              onTap: () {
                                _showChangePasswordDialog(context);
                              },
                            ),
                            _buildSettingTile(
                              context,
                              'Two-Factor Authentication',
                              'Add an extra layer of security',
                              Icons.verified_user,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Two-factor authentication coming soon'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // About Section
                        _buildSection(
                          context,
                          'About',
                          Icons.info,
                          [
                            _buildSettingTile(
                              context,
                              'Version',
                              '1.0.0',
                              Icons.info_outline,
                            ),
                            _buildSettingTile(
                              context,
                              'Terms of Service',
                              'Read our terms',
                              Icons.description,
                              onTap: () {},
                            ),
                            _buildSettingTile(
                              context,
                              'Privacy Policy',
                              'Read our privacy policy',
                              Icons.privacy_tip,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Logout Button
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text('Are you sure you want to logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                final authService = ref.read(authServiceProvider);
                                await authService.signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushReplacementNamed('/login');
                                }
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'admin@gym.com',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile coming soon'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGymInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(context, 'Gym Name', 'FitLife Gym'),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Address', '123 Fitness Street, City'),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Phone', '+91 1234567890'),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Email', 'contact@fitlifegym.com'),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                _showEditGymInfoDialog(context);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Gym Information'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Password',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully'),
                            ),
                          );
                        }
                      },
                      child: const Text('Change Password'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditGymInfoDialog(BuildContext context) {
    final gymNameController = TextEditingController(text: 'FitLife Gym');
    final addressController = TextEditingController(text: '123 Fitness Street, City');
    final phoneController = TextEditingController(text: '+91 1234567890');
    final emailController = TextEditingController(text: 'contact@fitlifegym.com');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Gym Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: gymNameController,
                    decoration: const InputDecoration(
                      labelText: 'Gym Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter gym name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gym information updated successfully'),
                              ),
                            );
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
