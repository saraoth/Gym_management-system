import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';
import '../models/membership_history.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';
import '../widgets/edit_member_dialog.dart';
import 'main_layout.dart';

class MemberDetailPage extends ConsumerStatefulWidget {
  final String memberId;

  const MemberDetailPage({super.key, required this.memberId});

  @override
  ConsumerState<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends ConsumerState<MemberDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Member? _member;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      currentRoute: '/members',
      child: Container(
        color: const Color(0xFF000000),
        child: StreamBuilder<DocumentSnapshot>(
          stream: firestoreService.getDocument('members', widget.memberId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'Member not found',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              );
            }

            _member = Member.fromMap(
              snapshot.data!.data() as Map<String, dynamic>,
              snapshot.data!.id,
            );

            return _buildContent();
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_member == null) return const SizedBox();

    return Column(
      children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(),
              _buildMembershipTab(),
              _buildHistoryTab(),
              _buildNotesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final statusColor = _getStatusColor(_member!.status);

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
                'Back to Members',
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
                  _member!.name[0].toUpperCase(),
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
                          _member!.name,
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
                            _member!.status.toUpperCase(),
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
                      'Member ID: ${_member!.id}',
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
                    builder: (context) => EditMemberDialog(member: _member!),
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
          Tab(text: 'Membership'),
          Tab(text: 'History'),
          Tab(text: 'Notes'),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            title: 'Personal Information',
            child: Column(
              children: [
                _buildInfoRow(Icons.email, 'Email', _member!.email),
                _buildInfoRow(Icons.phone, 'Phone', _member!.phone),
                _buildInfoRow(Icons.location_on, 'Address', _member!.address ?? 'N/A'),
                _buildInfoRow(
                  Icons.cake,
                  'Date of Birth',
                  _member!.dateOfBirth != null
                      ? _formatDate(_member!.dateOfBirth!)
                      : 'N/A',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'Emergency Contact',
            child: Column(
              children: [
                _buildInfoRow(Icons.person, 'Name', _member!.emergencyContact ?? 'N/A'),
                _buildInfoRow(Icons.phone, 'Phone', _member!.emergencyPhone ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            title: 'Current Membership',
            child: Column(
              children: [
                _buildInfoRow(Icons.card_membership, 'Plan', _member!.planName),
                _buildInfoRow(Icons.calendar_today, 'Start Date', _formatDate(_member!.startDate)),
                _buildInfoRow(Icons.event, 'End Date', _formatDate(_member!.expiryDate)),
                _buildInfoRow(Icons.attach_money, 'Fee', '${_member!.fee.toStringAsFixed(0)} EGP'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getSubcollection(
        'members',
        widget.memberId,
        'membershipHistory',
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
          );
        }

        final history = snapshot.data!.docs
            .map((doc) => MembershipHistory.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return _buildHistoryCard(item);
          },
        );
      },
    );
  }

  Widget _buildNotesTab() {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getSubcollection(
        'members',
        widget.memberId,
        'notes',
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
          );
        }

        final notes = snapshot.data!.docs
            .map((doc) => Note.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return _buildNoteCard(note);
          },
        );
      },
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

  Widget _buildHistoryCard(MembershipHistory item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            item.action,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(item.effectiveDate),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            note.content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'By ${note.createdBy} • ${_formatDate(note.createdAt)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF10B981);
      case 'expired':
        return const Color(0xFFEF4444);
      case 'frozen':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
