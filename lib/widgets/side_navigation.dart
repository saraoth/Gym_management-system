import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SideNavigation extends StatelessWidget {
  final String currentRoute;
  
  const SideNavigation({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Gym Manager',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/dashboard',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people,
                  label: 'Members',
                  route: '/members',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.fitness_center,
                  label: 'Trainers',
                  route: '/trainers',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.person_add,
                  label: 'Guest Members',
                  route: '/guests',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.event_note,
                  label: 'Classes',
                  route: '/classes',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.check_circle,
                  label: 'Attendance',
                  route: '/attendance',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.payment,
                  label: 'Payments & Reports',
                  route: '/payments',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.card_membership,
                  label: 'Plans',
                  route: '/plans',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.analytics,
                  label: 'AI Analytics',
                  route: '/analytics',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings,
                  label: 'Settings',
                  route: '/settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = currentRoute == route;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[600],
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[800],
          ),
        ),
        onTap: () {
          if (!isActive) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
      ),
    );
  }
}
