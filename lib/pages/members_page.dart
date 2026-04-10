import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';
import '../services/firestore_service.dart';
import '../widgets/add_member_dialog.dart';
import 'main_layout.dart';
import 'member_detail_page.dart';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({super.key});

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return MainLayout(
      currentRoute: '/members',
      child: Container(
        color: const Color(0xFF000000),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getCollection('members'),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                      ),
                    );
                  }

                  final members = snapshot.data!.docs
                      .map((doc) => Member.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          ))
                      .toList();

                  final filteredMembers = members.where((member) {
                    final matchesSearch = member.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        member.phone.contains(_searchQuery) ||
                        member.id.contains(_searchQuery);

                    final matchesStatus = _statusFilter == 'all' ||
                        member.status == _statusFilter;

                    return matchesSearch && matchesStatus;
                  }).toList();

                  return _buildMembersList(filteredMembers);
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
              Text(
                'Members',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddMemberDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  'Add Member',
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, or ID...',
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
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: DropdownButton<String>(
                  value: _statusFilter,
                  dropdownColor: const Color(0xFF1A1A1A),
                  underline: const SizedBox(),
                  style: GoogleFonts.inter(color: Colors.white),
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All Status', style: GoogleFonts.inter()),
                    ),
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Active', style: GoogleFonts.inter()),
                    ),
                    DropdownMenuItem(
                      value: 'expired',
                      child: Text('Expired', style: GoogleFonts.inter()),
                    ),
                    DropdownMenuItem(
                      value: 'frozen',
                      child: Text('Frozen', style: GoogleFonts.inter()),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _statusFilter = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(List<Member> members) {
    if (members.isEmpty) {
      return Center(
        child: Text(
          'No members found',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildMemberCard(Member member) {
    final statusColor = _getStatusColor(member.status);
    final daysUntilExpiry = member.expiryDate.difference(DateTime.now()).inDays;

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
                builder: (context) => MemberDetailPage(memberId: member.id),
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
                    member.name[0].toUpperCase(),
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
                            member.name,
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
                              member.status.toUpperCase(),
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
                        '${member.phone} • ${member.planName}',
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
                      'Expires in $daysUntilExpiry days',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: daysUntilExpiry < 7
                            ? const Color(0xFFEF4444)
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${member.fee.toStringAsFixed(0)} EGP',
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
}
