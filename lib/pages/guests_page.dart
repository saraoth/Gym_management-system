import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/guest.dart';
import '../services/firestore_service.dart';
import '../widgets/add_guest_dialog.dart';
import 'main_layout.dart';
import 'guest_detail_page.dart';

class GuestsPage extends ConsumerStatefulWidget {
  const GuestsPage({super.key});

  @override
  ConsumerState<GuestsPage> createState() => _GuestsPageState();
}

class _GuestsPageState extends ConsumerState<GuestsPage>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
      currentRoute: '/guests',
      child: Container(
        color: const Color(0xFF000000),
        child: Column(
          children: [
            _buildHeader(context),
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getCollection('guests'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  );
                }

                final guests = snapshot.data!.docs
                    .map((doc) => Guest.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        ))
                    .toList();

                return Expanded(
                  child: Column(
                    children: [
                      _buildStats(guests),
                      _buildTabs(guests),
                      Expanded(child: _buildTabContent(guests)),
                    ],
                  ),
                );
              },
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
                    'Guests & Sales',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track prospective members and manage your sales pipeline',
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
                    builder: (context) => const AddGuestDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  'Add Guest',
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
              hintText: 'Search guests by name, phone, or email...',
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

  Widget _buildStats(List<Guest> guests) {
    final statusCounts = {
      'all': guests.length,
      'new': guests.where((g) => g.status == 'New').length,
      'contacted': guests.where((g) => g.status == 'Contacted').length,
      'visited': guests.where((g) => g.status == 'Visited').length,
      'converted': guests.where((g) => g.status == 'Converted').length,
      'lost': guests.where((g) => g.status == 'Lost').length,
    };

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Leads', statusCounts['all']!, Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('New', statusCounts['new']!, const Color(0xFF3B82F6))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Contacted', statusCounts['contacted']!, const Color(0xFFF59E0B))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Visited', statusCounts['visited']!, const Color(0xFFA855F7))),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Converted', statusCounts['converted']!, const Color(0xFF10B981))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
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
            value.toString(),
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

  Widget _buildTabs(List<Guest> guests) {
    final statusCounts = {
      'all': guests.length,
      'new': guests.where((g) => g.status == 'New').length,
      'contacted': guests.where((g) => g.status == 'Contacted').length,
      'visited': guests.where((g) => g.status == 'Visited').length,
      'converted': guests.where((g) => g.status == 'Converted').length,
      'lost': guests.where((g) => g.status == 'Lost').length,
    };

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
        isScrollable: true,
        tabs: [
          Tab(text: 'All (${statusCounts['all']})'),
          Tab(text: 'New (${statusCounts['new']})'),
          Tab(text: 'Contacted (${statusCounts['contacted']})'),
          Tab(text: 'Visited (${statusCounts['visited']})'),
          Tab(text: 'Converted (${statusCounts['converted']})'),
          Tab(text: 'Lost (${statusCounts['lost']})'),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<Guest> guests) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGuestList(guests, null),
        _buildGuestList(guests, 'New'),
        _buildGuestList(guests, 'Contacted'),
        _buildGuestList(guests, 'Visited'),
        _buildGuestList(guests, 'Converted'),
        _buildGuestList(guests, 'Lost'),
      ],
    );
  }

  Widget _buildGuestList(List<Guest> guests, String? statusFilter) {
    var filteredGuests = guests;

    if (statusFilter != null) {
      filteredGuests = guests.where((g) => g.status == statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredGuests = filteredGuests.where((g) {
        return g.name.toLowerCase().contains(query) ||
            g.phone.contains(query) ||
            g.email.toLowerCase().contains(query);
      }).toList();
    }

    if (filteredGuests.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isNotEmpty
              ? 'No guests found matching your search'
              : 'No guests in this category',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filteredGuests.length,
      itemBuilder: (context, index) {
        final guest = filteredGuests[index];
        return _buildGuestCard(guest);
      },
    );
  }

  Widget _buildGuestCard(Guest guest) {
    final statusColor = _getStatusColor(guest.status);

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
                builder: (context) => GuestDetailPage(guestId: guest.id),
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
                    guest.name[0].toUpperCase(),
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
                            guest.name,
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
                              guest.status.toUpperCase(),
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
                        '${guest.phone} • ${guest.source}',
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
                      'Added ${_formatDate(guest.createdAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
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
      case 'New':
        return const Color(0xFF3B82F6);
      case 'Contacted':
        return const Color(0xFFF59E0B);
      case 'Visited':
        return const Color(0xFFA855F7);
      case 'Converted':
        return const Color(0xFF10B981);
      case 'Lost':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
