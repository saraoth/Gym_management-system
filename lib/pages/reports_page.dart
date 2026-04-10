import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';
import 'main_layout.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return MainLayout(
      currentRoute: '/reports',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getCollection('payments'),
              builder: (context, paymentsSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getCollection('members'),
                  builder: (context, membersSnapshot) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: firestoreService.getCollection('guests'),
                      builder: (context, guestsSnapshot) {
                        if (!paymentsSnapshot.hasData ||
                            !membersSnapshot.hasData ||
                            !guestsSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF3B82F6),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            _buildFinancialOverview(
                              paymentsSnapshot.data!.docs,
                              membersSnapshot.data!.docs,
                            ),
                            const SizedBox(height: 24),
                            _buildChartsRow(
                              paymentsSnapshot.data!.docs,
                              membersSnapshot.data!.docs,
                            ),
                            const SizedBox(height: 24),
                            _buildMembershipStats(
                              membersSnapshot.data!.docs,
                              guestsSnapshot.data!.docs,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports & Analytics',
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comprehensive insights into your gym performance',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildPeriodSelector(),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement export functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export feature coming soon')),
                );
              },
              icon: const Icon(Icons.download, size: 20),
              label: Text(
                'Export Report',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        onChanged: (value) => setState(() => _selectedPeriod = value!),
        dropdownColor: const Color(0xFF1A1A1A),
        underline: const SizedBox(),
        style: GoogleFonts.inter(color: Colors.white),
        items: ['This Week', 'This Month', 'This Quarter', 'This Year']
            .map((period) => DropdownMenuItem(
                  value: period,
                  child: Text(period),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFinancialOverview(
    List<QueryDocumentSnapshot> payments,
    List<QueryDocumentSnapshot> members,
  ) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    double totalRevenue = 0;
    double monthlyRevenue = 0;
    double expenses = 0;

    for (var doc in payments) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] == 'completed') {
        final amount = (data['amount'] ?? 0).toDouble();
        totalRevenue += amount;
        
        final date = (data['date'] as Timestamp).toDate();
        if (date.isAfter(monthStart)) {
          monthlyRevenue += amount;
        }
      }
    }

    // Mock expenses calculation (you can add actual expense tracking)
    expenses = monthlyRevenue * 0.4; // Assume 40% expenses
    final netProfit = monthlyRevenue - expenses;

    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Financial Overview',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildFinancialCard(
                  'Total Revenue',
                  '${monthlyRevenue.toStringAsFixed(0)} EGP',
                  Icons.trending_up,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFinancialCard(
                  'Expenses',
                  '${expenses.toStringAsFixed(0)} EGP',
                  Icons.trending_down,
                  const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFinancialCard(
                  'Net Profit',
                  '${netProfit.toStringAsFixed(0)} EGP',
                  Icons.account_balance_wallet,
                  const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow(
    List<QueryDocumentSnapshot> payments,
    List<QueryDocumentSnapshot> members,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildRevenueBreakdownChart(payments)),
        const SizedBox(width: 24),
        Expanded(child: _buildMembershipGrowthChart(members)),
      ],
    );
  }

  Widget _buildRevenueBreakdownChart(List<QueryDocumentSnapshot> payments) {
    final revenueByType = <String, double>{};
    
    for (var doc in payments) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] == 'completed') {
        final type = data['paymentType'] ?? 'Other';
        final amount = (data['amount'] ?? 0).toDouble();
        revenueByType[type] = (revenueByType[type] ?? 0) + amount;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Revenue Breakdown',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(revenueByType),
                sectionsSpace: 2,
                centerSpaceRadius: 60,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildLegend(revenueByType),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFA855F7),
    ];

    final entries = data.entries.toList();
    return List.generate(entries.length, (index) {
      final entry = entries[index];
      return PieChartSectionData(
        value: entry.value,
        title: '',
        color: colors[index % colors.length],
        radius: 50,
      );
    });
  }

  List<Widget> _buildLegend(Map<String, double> data) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFA855F7),
    ];

    final entries = data.entries.toList();
    return List.generate(entries.length, (index) {
      final entry = entries[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key}: ${entry.value.toStringAsFixed(0)} EGP',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMembershipGrowthChart(List<QueryDocumentSnapshot> members) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Membership Growth',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
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
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 150,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 85),
                      FlSpot(1, 92),
                      FlSpot(2, 98),
                      FlSpot(3, 110),
                      FlSpot(4, 118),
                      FlSpot(5, 130),
                    ],
                    isCurved: true,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF3B82F6),
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipStats(
    List<QueryDocumentSnapshot> members,
    List<QueryDocumentSnapshot> guests,
  ) {
    final activeMembers = members.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] == 'Active';
    }).length;

    final convertedGuests = guests.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] == 'Converted';
    }).length;

    final conversionRate = guests.isNotEmpty
        ? (convertedGuests / guests.length * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Key Performance Indicators',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  'Active Members',
                  activeMembers.toString(),
                  'Currently enrolled',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPICard(
                  'Total Members',
                  members.length.toString(),
                  'All time',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPICard(
                  'Conversion Rate',
                  '$conversionRate%',
                  'Guest to member',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
