import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trainer.dart';
import '../services/firestore_service.dart';
import '../widgets/edit_trainer_dialog.dart';
import 'main_layout.dart';

class TrainerDetailPage extends ConsumerStatefulWidget {
  final String trainerId;

  const TrainerDetailPage({super.key, required this.trainerId});

  @override
  ConsumerState<TrainerDetailPage> createState() => _TrainerDetailPageState();
}

class _TrainerDetailPageState extends ConsumerState<TrainerDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return MainLayout(
      currentRoute: '/trainers',
      child: Container(
        color: const Color(0xFF000000),
        child: StreamBuilder<DocumentSnapshot>(
          stream: firestoreService.getDocument('trainers', widget.trainerId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'Trainer not found',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              );
            }

            final trainer = Trainer.fromMap(
              snapshot.data!.data() as Map<String, dynamic>,
              snapshot.data!.id,
            );

            return Column(
              children: [
                _buildHeader(trainer),
                _buildStats(trainer),
                _buildTabs(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDetailsTab(trainer),
                      _buildEarningsTab(trainer),
                      _buildSessionsTab(trainer),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Trainer trainer) {
    final statusColor = trainer.status == 'active'
        ? const Color(0xFF10B981)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Back to Trainers',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                child: Text(
                  trainer.name[0].toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          trainer.name,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            trainer.status.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trainer ID: ${trainer.id}',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditTrainerDialog(trainer: trainer),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: Text(
                  'Edit',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Trainer trainer) {
    // For now, using placeholder values - these should be calculated from actual PT session records
    final totalSessions = 0; // TODO: Calculate from PT sessions subcollection
    final commissionEarnings = totalSessions * 300 * trainer.commissionRate / 100;
    final totalEarnings = trainer.baseSalary + commissionEarnings;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Base Salary',
              '${trainer.baseSalary.toStringAsFixed(0)} EGP',
              const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Commission Rate',
              '${trainer.commissionRate}%',
              const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total Sessions',
              totalSessions.toString(),
              const Color(0xFFA855F7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total Earnings',
              '${totalEarnings.toStringAsFixed(0)} EGP',
              const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF3B82F6),
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicatorColor: const Color(0xFF3B82F6),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'Earnings'),
          Tab(text: 'Sessions'),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Trainer trainer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            title: 'Personal Information',
            child: Column(
              children: [
                _buildInfoRow(Icons.email, 'Email', trainer.email),
                _buildInfoRow(Icons.phone, 'Phone', trainer.phone),
                _buildInfoRow(Icons.calendar_today, 'Hire Date', _formatDate(trainer.hireDate)),
                _buildInfoRow(Icons.fitness_center, 'Status', trainer.status),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'Specialization',
            child: Text(
              trainer.specialization,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTab(Trainer trainer) {
    final totalSessions = 0; // TODO: Calculate from PT sessions subcollection
    final commissionEarnings = totalSessions * 300 * trainer.commissionRate / 100;
    final monthlyEarnings = trainer.baseSalary + commissionEarnings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            title: 'Salary Breakdown',
            child: Column(
              children: [
                _buildEarningRow(
                  'Base Salary',
                  '${trainer.baseSalary.toStringAsFixed(0)} EGP',
                ),
                _buildEarningRow(
                  'Commission (${trainer.commissionRate}%)',
                  '${commissionEarnings.toStringAsFixed(0)} EGP',
                  subtitle:
                      '$totalSessions sessions × 300 EGP × ${trainer.commissionRate}%',
                ),
                const Divider(height: 32),
                _buildEarningRow(
                  'Estimated Monthly Earnings',
                  '${monthlyEarnings.toStringAsFixed(0)} EGP',
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab(Trainer trainer) {
    final totalSessions = 0; // TODO: Calculate from PT sessions subcollection
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildCard(
        title: 'Session Statistics',
        child: Column(
          children: [
            _buildInfoRow(
              Icons.fitness_center,
              'Total Sessions',
              totalSessions.toString(),
            ),
            _buildInfoRow(
              Icons.attach_money,
              'Revenue Generated',
              '${(totalSessions * 300).toStringAsFixed(0)} EGP',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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

  Widget _buildEarningRow(String label, String value,
      {String? subtitle, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: isTotal ? 16 : 14,
                    fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? const Color(0xFF3B82F6) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
