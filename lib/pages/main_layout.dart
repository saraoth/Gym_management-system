import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(child: child),
        ],
      ),
      drawer: !isDesktop ? _buildDrawer(context) : null,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildNavigation(context)),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A0A0A),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildNavigation(context)),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fitness_center,
            color: Color(0xFF3B82F6),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'GymFlow',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    final navItems = [
      _NavItem(
        name: 'Dashboard',
        route: '/dashboard',
        icon: Icons.dashboard_outlined,
      ),
      _NavItem(
        name: 'Members',
        route: '/members',
        icon: Icons.people_outline,
      ),
      _NavItem(
        name: 'Guests & Sales',
        route: '/guests',
        icon: Icons.person_add_outlined,
      ),
      _NavItem(
        name: 'Attendance',
        route: '/attendance',
        icon: Icons.calendar_today_outlined,
      ),
      _NavItem(
        name: 'Trainers',
        route: '/trainers',
        icon: Icons.fitness_center_outlined,
      ),
      _NavItem(
        name: 'Payments',
        route: '/payments',
        icon: Icons.attach_money_outlined,
      ),
      _NavItem(
        name: 'Reports',
        route: '/reports',
        icon: Icons.bar_chart_outlined,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: navItems.map((item) {
        final isActive = currentRoute == item.route;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushReplacementNamed(item.route);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF3B82F6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Logged in as',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Admin User',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String name;
  final String route;
  final IconData icon;

  _NavItem({
    required this.name,
    required this.route,
    required this.icon,
  });
}
