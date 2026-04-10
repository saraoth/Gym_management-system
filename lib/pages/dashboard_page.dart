import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'main_layout.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatsCards(),
            const SizedBox(height: 32),
            _buildChartsRow(),
            const SizedBox(height: 32),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back! Here\'s what\'s happening with your gym today.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final firestoreService = ref.read(firestoreServiceProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('members'),
      builder: (context, membersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getCollection('guests'),
          builder: (context, guestsSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getCollection('payments'),
              builder: (context, paymentsSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getCollection('attendance'),
                  builder: (context, attendanceSnapshot) {
                    final members = membersSnapshot.data?.docs ?? [];
                    final guests = guestsSnapshot.data?.docs ?? [];
                    final payments = paymentsSnapshot.data?.docs ?? [];
                    final attendance = attendanceSnapshot.data?.docs ?? [];

                    final activeMembers = members.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['status'] == 'Active';
                    }).length;

                    final now = DateTime.now();
                    final expiredMembers = members.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['expiryDate'] == null) return false;
                      try {
                        final expiryDate = (data['expiryDate'] as Timestamp).toDate();
                        return expiryDate.isBefore(now) && data['status'] != 'Expired';
                      } catch (e) {
                        return false;
                      }
                    }).length;

                    final newGuests = guests.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['status'] == 'new';
                    }).length;

                    final monthStart = DateTime(now.year, now.month, 1);
                    double monthlyRevenue = 0;
                    for (var doc in payments) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['paymentDate'] == null) continue;
                      try {
                        final date = (data['paymentDate'] as Timestamp).toDate();
                        if (date.isAfter(monthStart) &&
                            data['status'] == 'completed') {
                          monthlyRevenue += (data['amount'] ?? 0).toDouble();
                        }
                      } catch (e) {
                        // Skip invalid dates
                      }
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 1400
                            ? 4
                            : constraints.maxWidth > 900
                                ? 2
                                : 1;

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.8,
                          children: [
                            _buildStatCard(
                              'Total Members',
                              members.length.toString(),
                              '$activeMembers active',
                              Icons.people_outline,
                              const Color(0xFF3B82F6),
                            ),
                            _buildStatCard(
                              'Expired Memberships',
                              expiredMembers.toString(),
                              'Need renewal',
                              Icons.warning_outlined,
                              const Color(0xFFEF4444),
                            ),
                            _buildStatCard(
                              'New Guests',
                              newGuests.toString(),
                              'This month',
                              Icons.person_add_outlined,
                              const Color(0xFF10B981),
                            ),
                            _buildStatCard(
                              'Monthly Revenue',
                              '${monthlyRevenue.toStringAsFixed(0)} EGP',
                              '',
                              Icons.attach_money_outlined,
                              const Color(0xFFF59E0B),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            children: [
              Expanded(child: _buildWeeklyAttendanceChart()),
              const SizedBox(width: 24),
              Expanded(child: _buildRevenueTrendChart()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildWeeklyAttendanceChart(),
              const SizedBox(height: 24),
              _buildRevenueTrendChart(),
            ],
          );
        }
      },
    );
  }

  Widget _buildWeeklyAttendanceChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Weekly Attendance',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 80,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                      toY: 45,
                      color: const Color(0xFF3B82F6),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                      toY: 52,
                      color: const Color(0xFF3B82F6),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                      toY: 48,
                      color: const Color(0xFF3B82F6),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(
                      toY: 61,
                      color: const Color(0xFF3B82F6),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ]),
                  BarChartGroupData(x: 4, barRods: [
                    BarChartRodData(
                      toY: 55,
                      color: const Color(0xFF3B82F6),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ]),
                  BarChartGroupData(x: 5, barRods: [
                    BarChartRodData(
                      toY: 67,
                      color: const Color(0xFF3B82F6),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ]),
                  BarChartGroupData(x: 6, barRods: [
                    BarChartRodData(
                      toY: 58,
                      color: const Color(0xFF3B82F6),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Revenue Trend',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toInt()}k',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 70000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 45000),
                      FlSpot(1, 52000),
                      FlSpot(2, 48000),
                      FlSpot(3, 61000),
                      FlSpot(4, 58000),
                      FlSpot(5, 65000),
                    ],
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF10B981),
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildQuickActions()),
              const SizedBox(width: 24),
              Expanded(child: _buildAlerts()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildAlerts(),
            ],
          );
        }
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionButton(
            'Add New Member',
            Icons.people_outline,
            () => Navigator.of(context).pushNamed('/members'),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'Add New Guest',
            Icons.person_add_outlined,
            () => Navigator.of(context).pushNamed('/guests'),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'Check-in Member',
            Icons.calendar_today_outlined,
            () => Navigator.of(context).pushNamed('/attendance'),
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'Record Payment',
            Icons.attach_money_outlined,
            () => Navigator.of(context).pushNamed('/payments'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlerts() {
    final firestoreService = ref.read(firestoreServiceProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('members'),
      builder: (context, membersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getCollection('guests'),
          builder: (context, guestsSnapshot) {
            final members = membersSnapshot.data?.docs ?? [];
            final guests = guestsSnapshot.data?.docs ?? [];

            final now = DateTime.now();
            final thirtyDaysFromNow = now.add(const Duration(days: 30));

            final expiringMemberships = members.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['status'] != 'Active') return false;
              if (data['expiryDate'] == null) return false;
              final endDate = (data['expiryDate'] as Timestamp).toDate();
              return endDate.isAfter(now) && endDate.isBefore(thirtyDaysFromNow);
            }).length;

            final newGuests = guests.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'new';
            }).length;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alerts & Notifications',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (expiringMemberships > 0)
                    _buildAlertCard(
                      '$expiringMemberships membership${expiringMemberships > 1 ? 's' : ''} expiring in 30 days',
                      'View members →',
                      const Color(0xFFF59E0B),
                      () => Navigator.of(context).pushNamed('/members'),
                    ),
                  if (expiringMemberships > 0 && newGuests > 0)
                    const SizedBox(height: 12),
                  if (newGuests > 0)
                    _buildAlertCard(
                      '$newGuests new guest${newGuests > 1 ? 's' : ''} need follow-up',
                      'View guests →',
                      const Color(0xFF3B82F6),
                      () => Navigator.of(context).pushNamed('/guests'),
                    ),
                  if (expiringMemberships == 0 && newGuests == 0)
                    Text(
                      'No alerts at this time',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlertCard(
    String message,
    String action,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: color,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
