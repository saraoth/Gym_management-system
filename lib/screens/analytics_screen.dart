import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/ai_analytics_service.dart';
import '../widgets/side_navigation.dart';
import '../models/member.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  
  final AIAnalyticsService _aiService = AIAnalyticsService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
          if (isDesktop || isTablet) const SideNavigation(currentRoute: '/analytics'),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChurnPrediction(isDesktop, isTablet),
                          const SizedBox(height: 24),
                          _buildAttendancePatterns(isDesktop, isTablet),
                          const SizedBox(height: 24),
                          _buildRevenuePrediction(isDesktop, isTablet),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            'AI Analytics & Insights',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'AI Powered',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChurnPrediction(bool isDesktop, bool isTablet) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final animationValue = Curves.easeOut.transform(_staggerController.value);
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 8,
        shadowColor: Colors.red.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.red.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.warning_amber, color: Colors.red, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Member Churn Prediction',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'AI-powered analysis of member retention risk',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getCollection('members'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final members = snapshot.data!.docs.map((doc) {
                    return Member.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();

                  // Simulate churn predictions for active members
                  final highRiskMembers = members.where((m) => m.status == 'Active').take(5).toList();

                  return Column(
                    children: highRiskMembers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final member = entry.value;
                      
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(-20 * (1 - value), 0),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: _ChurnRiskCard(member: member, index: index),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendancePatterns(bool isDesktop, bool isTablet) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final delay = 0.2;
        final animationValue = Curves.easeOut.transform(
          (_staggerController.value - delay).clamp(0.0, 1.0) / (1.0 - delay),
        );
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 8,
        shadowColor: Colors.blue.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.insights, color: Colors.blue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Patterns',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Peak times and trends analysis',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPatternInsights(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenuePrediction(bool isDesktop, bool isTablet) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final delay = 0.4;
        final animationValue = Curves.easeOut.transform(
          (_staggerController.value - delay).clamp(0.0, 1.0) / (1.0 - delay),
        );
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 8,
        shadowColor: Colors.green.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.green.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.trending_up, color: Colors.green, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revenue Prediction',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'AI-based revenue forecasting',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildRevenueForecast(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatternInsights() {
    final insights = [
      {'label': 'Peak Day', 'value': 'Monday', 'icon': Icons.calendar_today, 'color': Colors.blue},
      {'label': 'Peak Time', 'value': 'Evening (17-22)', 'icon': Icons.access_time, 'color': Colors.orange},
      {'label': 'Avg Daily', 'value': '45 members', 'icon': Icons.people, 'color': Colors.green},
      {'label': 'Trend', 'value': 'Increasing', 'icon': Icons.trending_up, 'color': Colors.purple},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: insights.map((insight) {
        return Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (insight['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (insight['color'] as Color).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(insight['icon'] as IconData, color: insight['color'] as Color, size: 24),
              const SizedBox(height: 8),
              Text(
                insight['label'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                insight['value'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRevenueForecast() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Month Prediction',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'E£45,000',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'High Confidence',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Growing trend detected (+12% from last month)',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChurnRiskCard extends StatelessWidget {
  final Member member;
  final int index;

  const _ChurnRiskCard({required this.member, required this.index});

  @override
  Widget build(BuildContext context) {
    // Simulate churn risk (in real app, would call AI service)
    final riskScores = [75, 65, 55, 45, 35];
    final riskScore = riskScores[index % riskScores.length];
    final riskLevel = riskScore > 60 ? 'High' : (riskScore > 40 ? 'Medium' : 'Low');
    final riskColor = riskScore > 60 ? Colors.red : (riskScore > 40 ? Colors.orange : Colors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last visit: ${_getRandomDaysAgo(riskScore)} days ago',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$riskLevel Risk',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: riskColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$riskScore% score',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getRandomDaysAgo(int riskScore) {
    if (riskScore > 60) return 15 + (riskScore - 60);
    if (riskScore > 40) return 8 + (riskScore - 40);
    return 2 + (riskScore ~/ 10);
  }
}
