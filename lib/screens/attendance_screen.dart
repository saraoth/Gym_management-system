import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/side_navigation.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with TickerProviderStateMixin { // Changed from SingleTickerProviderStateMixin to TickerProviderStateMixin to support multiple tickers (AnimationController and TabController)
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;
  
  DateTime _selectedDate = DateTime.now();
  final Map<String, bool> _memberAttendance = {};
  final Map<String, int> _trainerClasses = {};

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
    
    _tabController = TabController(length: 2, vsync: this);
    _loadTodayAttendance();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayAttendance() async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    // Load member attendance
    final memberAttendanceSnapshot = await firestoreService.queryCollection(
      'attendance',
      field: 'date',
      isGreaterThan: startOfDay,
      isLessThan: endOfDay,
    );
    
    setState(() {
      _memberAttendance.clear();
      for (var doc in memberAttendanceSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        _memberAttendance[data['memberId']] = data['present'] ?? false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 600 && size.width <= 1200;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop || isTablet) const SideNavigation(currentRoute: '/attendance'),
          
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildAppBar(context),
                  _buildDateSelector(context),
                  _buildTabBar(context),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMembersAttendance(context, isDesktop, isTablet),
                        _buildTrainersAttendance(context, isDesktop, isTablet),
                      ],
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
            'Attendance Tracking',
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
                onPressed: () {
                  _loadTodayAttendance();
                  setState(() {});
                },
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

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                ? () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Members Attendance'),
          Tab(text: 'Trainers Classes'),
        ],
      ),
    );
  }

  Widget _buildMembersAttendance(BuildContext context, bool isDesktop, bool isTablet) {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('members'),
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
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No members found',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        final members = snapshot.data!.docs;
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${members.length} members',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Present: ${_memberAttendance.values.where((v) => v).length}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final doc = members[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final memberId = doc.id;
                  final isPresent = _memberAttendance[memberId] ?? false;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isPresent
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          color: isPresent ? Colors.green : Colors.grey,
                        ),
                      ),
                      title: Text(
                        data['name'] ?? 'Unknown',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${data['trainingType'] ?? 'N/A'} Training${data['trainerId'] != null ? ' - Trainer Assigned' : ''}',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      trailing: Switch(
                        value: isPresent,
                        onChanged: (value) {
                          _toggleMemberAttendance(memberId, data['name'], value);
                        },
                        activeColor: Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrainersAttendance(BuildContext context, bool isDesktop, bool isTablet) {
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
              ],
            ),
          );
        }
        
        final trainers = snapshot.data!.docs;
        
        return StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getCollection('trainer_attendance'),
          builder: (context, attendanceSnapshot) {
            final todayClasses = <String, int>{};
            
            if (attendanceSnapshot.hasData) {
              final today = DateTime.now();
              for (var doc in attendanceSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final date = (data['date'] as Timestamp).toDate();
                
                if (date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day) {
                  final trainerId = data['trainerId'];
                  todayClasses[trainerId] = (todayClasses[trainerId] ?? 0) + 1;
                }
              }
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainers.length,
              itemBuilder: (context, index) {
                final doc = trainers[index];
                final data = doc.data() as Map<String, dynamic>;
                final trainerId = doc.id;
                final classesToday = todayClasses[trainerId] ?? 0;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.fitness_center,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      data['name'] ?? 'Unknown',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${data['specialization'] ?? 'N/A'} - Classes Today: $classesToday',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        _markTrainerClass(trainerId, data['name']);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Mark Class'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _toggleMemberAttendance(String memberId, String memberName, bool isPresent) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    setState(() {
      _memberAttendance[memberId] = isPresent;
    });
    
    try {
      // Check if attendance record exists for today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      final existingRecords = await firestoreService.queryCollection(
        'attendance',
        field: 'memberId',
        isEqualTo: memberId,
      );
      
      bool recordExists = false;
      String? recordId;
      
      for (var doc in existingRecords.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();
        
        if (date.isAfter(startOfDay) && date.isBefore(endOfDay)) {
          recordExists = true;
          recordId = doc.id;
          break;
        }
      }
      
      if (recordExists && recordId != null) {
        // Update existing record
        await firestoreService.updateDocument('attendance', recordId, {
          'present': isPresent,
        });
      } else {
        // Create new record
        await firestoreService.addDocument('attendance', {
          'memberId': memberId,
          'memberName': memberName,
          'date': DateTime.now(),
          'present': isPresent,
          'createdAt': DateTime.now(),
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPresent
                  ? '$memberName marked as present'
                  : '$memberName marked as absent',
            ),
            backgroundColor: isPresent ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Revert the state on error
      setState(() {
        _memberAttendance[memberId] = !isPresent;
      });
    }
  }

  Future<void> _markTrainerClass(String trainerId, String trainerName) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    try {
      // Create attendance record
      await firestoreService.addDocument('trainer_attendance', {
        'trainerId': trainerId,
        'trainerName': trainerName,
        'date': DateTime.now(),
        'createdAt': DateTime.now(),
      });
      
      // Update trainer's class count
      final trainerDoc = await FirebaseFirestore.instance
          .collection('trainers')
          .doc(trainerId)
          .get();
      
      if (trainerDoc.exists) {
        final currentCount = trainerDoc.data()?['classesCount'] ?? 0;
        await firestoreService.updateDocument('trainers', trainerId, {
          'classesCount': currentCount + 1,
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Class marked for $trainerName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
