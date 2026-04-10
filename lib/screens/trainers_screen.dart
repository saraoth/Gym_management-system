import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/side_navigation.dart';
import '../models/trainer.dart';
import '../widgets/add_trainer_dialog.dart';
import '../widgets/edit_trainer_dialog.dart';

class TrainersScreen extends ConsumerStatefulWidget {
  const TrainersScreen({super.key});

  @override
  ConsumerState<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends ConsumerState<TrainersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
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
          if (isDesktop || isTablet) const SideNavigation(currentRoute: '/trainers'),
          
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildAppBar(context),
                  _buildFilters(context, isDesktop, isTablet),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildTrainersTable(context, isDesktop, isTablet),
                          const SizedBox(height: 24),
                          _buildPerformanceChart(context, isDesktop, isTablet),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTrainerDialog(context),
        icon: const Icon(Icons.add),
        label: Text(
          'Add Trainer',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
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
            'Trainers Management',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => setState(() {}),
              ),
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
    );
  }

  Widget _buildFilters(BuildContext context, bool isDesktop, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: isDesktop ? 300 : (isTablet ? 250 : double.infinity),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or specialization...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          DropdownMenu<String>(
            label: const Text('Status'),
            initialSelection: _filterStatus,
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'All', label: 'All Status'),
              DropdownMenuEntry(value: 'Active', label: 'Active'),
              DropdownMenuEntry(value: 'Inactive', label: 'Inactive'),
            ],
            onSelected: (value) {
              setState(() => _filterStatus = value ?? 'All');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrainersTable(BuildContext context, bool isDesktop, bool isTablet) {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('trainers'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No trainers found',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first trainer to get started',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }
        
        var trainers = snapshot.data!.docs.map((doc) {
          return Trainer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        
        // Apply filters
        if (_searchQuery.isNotEmpty) {
          trainers = trainers.where((trainer) {
            return trainer.name.toLowerCase().contains(_searchQuery) ||
                trainer.specialization.toLowerCase().contains(_searchQuery);
          }).toList();
        }
        
        if (_filterStatus != 'All') {
          trainers = trainers.where((trainer) => trainer.status == _filterStatus).toList();
        }
        
        if (trainers.isEmpty) {
          return Center(
            child: Text(
              'No trainers match your filters',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }
        
        return isDesktop
            ? _buildDesktopTable(trainers)
            : _buildMobileCards(trainers);
      },
    );
  }

  Widget _buildDesktopTable(List<Trainer> trainers) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Phone', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Specialization', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Members', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Classes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Actions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
          ],
          rows: trainers.map((trainer) {
            return DataRow(
              cells: [
                DataCell(Text(trainer.name, style: GoogleFonts.poppins())),
                DataCell(Text(trainer.phone, style: GoogleFonts.poppins())),
                DataCell(Text(trainer.specialization, style: GoogleFonts.poppins())),
                DataCell(Text(trainer.membersCount.toString(), style: GoogleFonts.poppins())),
                DataCell(Text(trainer.classesCount.toString(), style: GoogleFonts.poppins())),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: trainer.status == 'Active'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trainer.status,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trainer.status == 'Active' ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditTrainerDialog(context, trainer),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle, size: 20, color: Colors.blue),
                        onPressed: () => _markClass(trainer),
                        tooltip: 'Mark Class',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => _deleteTrainer(trainer.id),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileCards(List<Trainer> trainers) {
    return Column(
      children: trainers.map((trainer) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trainer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: trainer.status == 'Active'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trainer.status,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: trainer.status == 'Active' ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, trainer.phone),
                _buildInfoRow(Icons.fitness_center, trainer.specialization),
                _buildInfoRow(Icons.people, '${trainer.membersCount} Members'),
                _buildInfoRow(Icons.class_, '${trainer.classesCount} Classes'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      onPressed: () => _showEditTrainerDialog(context, trainer),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Mark Class'),
                      onPressed: () => _markClass(trainer),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => _deleteTrainer(trainer.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context, bool isDesktop, bool isTablet) {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('trainers'),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final trainers = snapshot.data!.docs.map((doc) {
          return Trainer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        
        // Take top 5 trainers by classes count
        trainers.sort((a, b) => b.classesCount.compareTo(a.classesCount));
        final topTrainers = trainers.take(5).toList();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trainer Performance (Classes Conducted)',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: topTrainers.isEmpty ? 10 : topTrainers.first.classesCount.toDouble() + 5,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${topTrainers[groupIndex].name}\n${rod.toY.toInt()} classes',
                              GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < topTrainers.length) {
                                final name = topTrainers[value.toInt()].name;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    name.length > 10 ? '${name.substring(0, 10)}...' : name,
                                    style: GoogleFonts.poppins(fontSize: 10),
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
                      barGroups: List.generate(topTrainers.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: topTrainers[index].classesCount.toDouble(),
                              color: Theme.of(context).colorScheme.primary,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTrainerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTrainerDialog(),
    );
  }

  void _showEditTrainerDialog(BuildContext context, Trainer trainer) {
    showDialog(
      context: context,
      builder: (context) => EditTrainerDialog(trainer: trainer),
    );
  }

  Future<void> _markClass(Trainer trainer) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    // Increment class count
    await firestoreService.updateDocument('trainers', trainer.id, {
      'classesCount': trainer.classesCount + 1,
    });
    
    // Create attendance record
    await firestoreService.addDocument('trainer_attendance', {
      'trainerId': trainer.id,
      'trainerName': trainer.name,
      'date': DateTime.now(),
      'createdAt': DateTime.now(),
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class marked for ${trainer.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteTrainer(String trainerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Trainer', style: GoogleFonts.poppins()),
        content: Text(
          'Are you sure you want to delete this trainer?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.deleteDocument('trainers', trainerId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trainer deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
