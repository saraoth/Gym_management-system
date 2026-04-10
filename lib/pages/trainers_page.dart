import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trainer.dart';
import '../services/firestore_service.dart';
import '../widgets/add_trainer_dialog.dart';
import 'main_layout.dart';
import 'trainer_detail_page.dart';

class TrainersPage extends ConsumerStatefulWidget {
  const TrainersPage({super.key});

  @override
  ConsumerState<TrainersPage> createState() => _TrainersPageState();
}

class _TrainersPageState extends ConsumerState<TrainersPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return MainLayout(
      currentRoute: '/trainers',
      child: Container(
        color: const Color(0xFF000000),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getCollection('trainers'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                      ),
                    );
                  }

                  final trainers = snapshot.data!.docs
                      .map((doc) => Trainer.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          ))
                      .toList();

                  return Column(
                    children: [
                      _buildStats(trainers),
                      Expanded(child: _buildTrainersList(trainers)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trainers',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your gym trainers and track their performance',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddTrainerDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  'Add Trainer',
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
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search trainers by name, email, or phone...',
              hintStyle: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withOpacity(0.5),
              ),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<Trainer> trainers) {
    final activeTrainers = trainers.where((t) => t.status == 'active').length;
    final totalSessions = 0;
    final totalEarnings = 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total Trainers', trainers.length.toString(), Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Active Trainers', activeTrainers.toString(), const Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Total Sessions', totalSessions.toString(), const Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Total Earnings', '${totalEarnings.toStringAsFixed(0)} EGP', const Color(0xFFF59E0B)),
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

  Widget _buildTrainersList(List<Trainer> trainers) {
    var filteredTrainers = trainers;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredTrainers = trainers.where((t) {
        return t.name.toLowerCase().contains(query) ||
            t.email.toLowerCase().contains(query) ||
            t.phone.contains(query);
      }).toList();
    }

    if (filteredTrainers.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isNotEmpty
              ? 'No trainers found matching your search'
              : 'No trainers yet',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filteredTrainers.length,
      itemBuilder: (context, index) {
        final trainer = filteredTrainers[index];
        return _buildTrainerCard(trainer);
      },
    );
  }

  Widget _buildTrainerCard(Trainer trainer) {
    final statusColor = trainer.status == 'active'
        ? const Color(0xFF10B981)
        : Colors.grey;

    final totalSessions = 0;
    final totalEarnings = trainer.baseSalary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TrainerDetailPage(trainerId: trainer.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                  child: Text(
                    trainer.name[0].toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 20,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              trainer.status.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${trainer.phone} • ${trainer.specialization}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalSessions sessions',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalEarnings.toStringAsFixed(0)} EGP',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
