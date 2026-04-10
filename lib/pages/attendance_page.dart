import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance.dart';
import '../services/firestore_service.dart';
import 'main_layout.dart';
import '../widgets/check_in_dialog.dart'; // Import CheckInDialog widget

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
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
      currentRoute: '/attendance',
      child: Container(
        color: const Color(0xFF000000),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getCollection('attendance'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                      ),
                    );
                  }

                  final attendanceRecords = snapshot.data!.docs
                      .map((doc) => Attendance.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          ))
                      .toList();

                  return Column(
                    children: [
                      _buildStats(attendanceRecords),
                      _buildTabs(attendanceRecords),
                      Expanded(child: _buildTabContent(attendanceRecords)),
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
                    'Attendance',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track member check-ins and gym activity',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showCheckInDialog(context);
                },
                icon: const Icon(Icons.login, size: 20),
                label: Text(
                  'Check In Member',
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
              hintText: 'Search by member name or ID...',
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

  Widget _buildStats(List<Attendance> records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayRecords = records.where((r) {
      final checkIn = r.checkInTime;
      return checkIn.year == today.year &&
          checkIn.month == today.month &&
          checkIn.day == today.day;
    }).toList();

    final activeNow = todayRecords.where((r) => r.checkOutTime == null).length;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Today\'s Check-ins',
              todayRecords.length.toString(),
              const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Currently Active',
              activeNow.toString(),
              const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total Records',
              records.length.toString(),
              const Color(0xFFF59E0B),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(List<Attendance> records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayCount = records.where((r) {
      final checkIn = r.checkInTime;
      return checkIn.year == today.year &&
          checkIn.month == today.month &&
          checkIn.day == today.day;
    }).length;

    final activeCount = records.where((r) => r.checkOutTime == null).length;

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
        tabs: [
          Tab(text: 'Today ($todayCount)'),
          Tab(text: 'Active ($activeCount)'),
          Tab(text: 'All Records'),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<Attendance> records) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAttendanceList(records, 'today'),
        _buildAttendanceList(records, 'active'),
        _buildAttendanceList(records, 'all'),
      ],
    );
  }

  Widget _buildAttendanceList(List<Attendance> records, String filter) {
    var filteredRecords = records;

    if (filter == 'today') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      filteredRecords = records.where((r) {
        final checkIn = r.checkInTime;
        return checkIn.year == today.year &&
            checkIn.month == today.month &&
            checkIn.day == today.day;
      }).toList();
    } else if (filter == 'active') {
      filteredRecords = records.where((r) => r.checkOutTime == null).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredRecords = filteredRecords.where((r) {
        return r.memberName.toLowerCase().contains(query) ||
            r.memberId.toLowerCase().contains(query);
      }).toList();
    }

    filteredRecords.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

    if (filteredRecords.isEmpty) {
      return Center(
        child: Text(
          'No attendance records found',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return _buildAttendanceCard(record);
      },
    );
  }

  Widget _buildAttendanceCard(Attendance record) {
    final isActive = record.checkOutTime == null;
    final duration = record.checkOutTime != null
        ? record.checkOutTime!.difference(record.checkInTime)
        : DateTime.now().difference(record.checkInTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color(0xFF10B981).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isActive ? const Color(0xFF10B981) : const Color(0xFF3B82F6))
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isActive ? Icons.person : Icons.check_circle,
                color: isActive ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                size: 24,
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
                        record.memberName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.activityType} • ${_formatDuration(duration)}',
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
                  'In: ${_formatTime(record.checkInTime)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                if (record.checkOutTime != null)
                  Text(
                    'Out: ${_formatTime(record.checkOutTime!)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _checkOutMember(record.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'Check Out',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  void _showCheckInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CheckInDialog(),
    );
  }

  void _checkOutMember(String attendanceId) {
    final firestoreService = ref.read(firestoreServiceProvider);
    firestoreService.updateDocument('attendance', attendanceId, {
      'checkOutTime': Timestamp.now(),
    });
  }
}
