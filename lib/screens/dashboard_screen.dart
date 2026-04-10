import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/side_navigation.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/notification_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _animationController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 600 && size.width <= 1200;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop || isTablet) const SideNavigation(currentRoute: '/dashboard'),
          
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dashboard',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: () async {
                                await ref.read(authServiceProvider).signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushReplacementNamed('/login');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOverviewCards(context, isDesktop, isTablet),
                          const SizedBox(height: 24),
                          
                          _buildChartsSection(context, isDesktop, isTablet),
                          const SizedBox(height: 24),
                          
                          _buildNotificationsSection(context),
                        ],
                      ),
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

  Widget _buildOverviewCards(BuildContext context, bool isDesktop, bool isTablet) {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('members'),
      builder: (context, membersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getCollection('trainers'),
          builder: (context, trainersSnapshot) {
            final members = membersSnapshot.data?.docs ?? [];
            final trainers = trainersSnapshot.data?.docs ?? [];
            
            final activeMembers = members.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'Active';
            }).length;
            
            final expiredMembers = members.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'Expired';
            }).length;
            
            final trainersCount = trainers.length;
            
            double monthlyRevenue = 0;
            for (var doc in members) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['status'] == 'Active') {
                monthlyRevenue += (data['fee'] ?? 0).toDouble();
              }
            }
            
            final gridCount = isDesktop ? 4 : (isTablet ? 2 : 1);
            
            final cards = [
              DashboardCard(
                title: 'Active Members',
                value: activeMembers.toString(),
                icon: Icons.people,
                color: Colors.green,
                trend: '+12%',
              ),
              DashboardCard(
                title: 'Expired Members',
                value: expiredMembers.toString(),
                icon: Icons.person_off,
                color: Colors.red,
                trend: '-5%',
              ),
              DashboardCard(
                title: 'Trainers',
                value: trainersCount.toString(),
                icon: Icons.fitness_center,
                color: Colors.blue,
                trend: '+2',
              ),
              DashboardCard(
                title: 'Monthly Revenue',
                value: 'E£${monthlyRevenue.toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: Colors.orange,
                trend: '+18%',
              ),
            ];
            
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isDesktop ? 1.5 : (isTablet ? 1.8 : 2.5),
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _staggerController,
                  builder: (context, child) {
                    final delay = index * 0.1;
                    final animationValue = Curves.easeOut.transform(
                      (_staggerController.value - delay).clamp(0.0, 1.0) / (1.0 - delay),
                    );
                    
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - animationValue)),
                      child: Opacity(
                        opacity: animationValue,
                        child: child,
                      ),
                    );
                  },
                  child: cards[index],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChartsSection(BuildContext context, bool isDesktop, bool isTablet) {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('members'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final members = snapshot.data!.docs;
        
        int personalTraining = 0;
        int generalTraining = 0;
        
        for (var doc in members) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['trainingType'] == 'Personal') {
            personalTraining++;
          } else {
            generalTraining++;
          }
        }
        
        final gridCount = isDesktop ? 3 : (isTablet ? 2 : 1);
        
        final charts = [
          _buildPieChart(context, personalTraining, generalTraining),
          _buildBarChart(context),
          _buildLineChart(context),
        ];
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isDesktop ? 1.2 : (isTablet ? 1.0 : 0.8),
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: charts.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 800 + (index * 200)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: charts[index],
            );
          },
        );
      },
    );
  }

  Widget _buildPieChart(BuildContext context, int personal, int general) {
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members by Training Type',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: personal.toDouble(),
                      title: 'Personal\n$personal',
                      color: Theme.of(context).colorScheme.primary,
                      radius: 60,
                      titleStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: general.toDouble(),
                      title: 'General\n$general',
                      color: Theme.of(context).colorScheme.secondary,
                      radius: 60,
                      titleStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Revenue',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          if (value.toInt() >= 0 && value.toInt() < months.length) {
                            return Text(
                              months[value.toInt()],
                              style: GoogleFonts.poppins(fontSize: 10),
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
                            'E£${(value / 1000).toStringAsFixed(0)}k',
                            style: GoogleFonts.poppins(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5000, color: Theme.of(context).colorScheme.primary)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 6500, color: Theme.of(context).colorScheme.primary)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 7200, color: Theme.of(context).colorScheme.primary)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 8100, color: Theme.of(context).colorScheme.primary)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 7800, color: Theme.of(context).colorScheme.primary)]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 9200, color: Theme.of(context).colorScheme.primary)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Visitors',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: GoogleFonts.poppins(fontSize: 10),
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
                            style: GoogleFonts.poppins(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 45),
                        const FlSpot(1, 52),
                        const FlSpot(2, 48),
                        const FlSpot(3, 65),
                        const FlSpot(4, 58),
                        const FlSpot(5, 72),
                        const FlSpot(6, 68),
                      ],
                      isCurved: true,
                      color: Theme.of(context).colorScheme.secondary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('members'),
      builder: (context, membersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getCollection('trainers'),
          builder: (context, trainersSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getCollection('guests'),
              builder: (context, guestsSnapshot) {
                final members = membersSnapshot.data?.docs ?? [];
                final trainers = trainersSnapshot.data?.docs ?? [];
                final guests = guestsSnapshot.data?.docs ?? [];
                
                final now = DateTime.now();
                final expiringToday = members.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final expiryDate = (data['expiryDate'] as Timestamp).toDate();
                  return expiryDate.year == now.year &&
                      expiryDate.month == now.month &&
                      expiryDate.day == now.day;
                }).length;
                
                final absentTrainers = 0;
                
                final unconvertedGuests = guests.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'Visited';
                }).length;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (expiringToday > 0)
                      NotificationCard(
                        icon: Icons.warning_amber,
                        color: Colors.orange,
                        title: 'Expiring Memberships',
                        message: '$expiringToday membership(s) expiring today',
                      ),
                    if (absentTrainers > 0)
                      NotificationCard(
                        icon: Icons.person_off,
                        color: Colors.red,
                        title: 'Absent Trainers',
                        message: '$absentTrainers trainer(s) marked absent today',
                      ),
                    if (unconvertedGuests > 0)
                      NotificationCard(
                        icon: Icons.person_add,
                        color: Colors.blue,
                        title: 'Guest Conversions',
                        message: '$unconvertedGuests guest(s) not converted to members',
                      ),
                    if (expiringToday == 0 && absentTrainers == 0 && unconvertedGuests == 0)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'No notifications at this time',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
