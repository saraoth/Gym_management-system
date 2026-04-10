import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/side_navigation.dart';
import '../models/guest.dart';
import '../widgets/add_guest_dialog.dart';
import '../widgets/convert_guest_dialog.dart';

class GuestsScreen extends ConsumerStatefulWidget {
  const GuestsScreen({super.key});

  @override
  ConsumerState<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends ConsumerState<GuestsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterVisitType = 'All';
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
          if (isDesktop || isTablet) const SideNavigation(currentRoute: '/guests'),
          
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildAppBar(context),
                  _buildFilters(context, isDesktop, isTablet),
                  Expanded(
                    child: _buildGuestsTable(context, isDesktop, isTablet),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGuestDialog(context),
        icon: const Icon(Icons.add),
        label: Text(
          'Add Guest',
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
            'Guest Members',
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
                hintText: 'Search by name or phone...',
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
            label: const Text('Visit Type'),
            initialSelection: _filterVisitType,
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'All', label: 'All Types'),
              DropdownMenuEntry(value: 'Trial', label: 'Trial'),
              DropdownMenuEntry(value: 'Daily', label: 'Daily'),
            ],
            onSelected: (value) {
              setState(() => _filterVisitType = value ?? 'All');
            },
          ),
          DropdownMenu<String>(
            label: const Text('Status'),
            initialSelection: _filterStatus,
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'All', label: 'All Status'),
              DropdownMenuEntry(value: 'Visited', label: 'Visited'),
              DropdownMenuEntry(value: 'Converted', label: 'Converted'),
            ],
            onSelected: (value) {
              setState(() => _filterStatus = value ?? 'All');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestsTable(BuildContext context, bool isDesktop, bool isTablet) {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('guests'),
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
                  Icons.person_add_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No guests found',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first guest to get started',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }
        
        var guests = snapshot.data!.docs.map((doc) {
          return Guest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        
        // Apply filters
        if (_searchQuery.isNotEmpty) {
          guests = guests.where((guest) {
            return guest.name.toLowerCase().contains(_searchQuery) ||
                guest.phone.contains(_searchQuery);
          }).toList();
        }
        
        if (_filterVisitType != 'All') {
          guests = guests.where((guest) => guest.visitType == _filterVisitType).toList();
        }
        
        if (_filterStatus != 'All') {
          guests = guests.where((guest) => guest.status == _filterStatus).toList();
        }
        
        if (guests.isEmpty) {
          return Center(
            child: Text(
              'No guests match your filters',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isDesktop
              ? _buildDesktopTable(guests)
              : _buildMobileCards(guests),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<Guest> guests) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Phone', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Visit Type', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Visit Date', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Actions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
          ],
          rows: guests.map((guest) {
            return DataRow(
              cells: [
                DataCell(Text(guest.name, style: GoogleFonts.poppins())),
                DataCell(Text(guest.phone, style: GoogleFonts.poppins())),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: guest.visitType == 'Trial'
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      guest.visitType,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: guest.visitType == 'Trial' ? Colors.blue : Colors.purple,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(
                  DateFormat('MMM dd, yyyy').format(guest.visitDate),
                  style: GoogleFonts.poppins(),
                )),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: guest.status == 'Visited'
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      guest.status,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: guest.status == 'Visited' ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (guest.status == 'Visited')
                        IconButton(
                          icon: const Icon(Icons.person_add, size: 20, color: Colors.blue),
                          onPressed: () => _showConvertGuestDialog(context, guest),
                          tooltip: 'Convert to Member',
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => _deleteGuest(guest.id),
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

  Widget _buildMobileCards(List<Guest> guests) {
    return Column(
      children: guests.map((guest) {
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
                      guest.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: guest.status == 'Visited'
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        guest.status,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: guest.status == 'Visited' ? Colors.orange : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, guest.phone),
                _buildInfoRow(
                  Icons.fitness_center,
                  guest.visitType,
                  color: guest.visitType == 'Trial' ? Colors.blue : Colors.purple,
                ),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Visited: ${DateFormat('MMM dd, yyyy').format(guest.visitDate)}',
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (guest.status == 'Visited')
                      TextButton.icon(
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Convert'),
                        onPressed: () => _showConvertGuestDialog(context, guest),
                      ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => _deleteGuest(guest.id),
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

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: color ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddGuestDialog(),
    );
  }

  void _showConvertGuestDialog(BuildContext context, Guest guest) {
    showDialog(
      context: context,
      builder: (context) => ConvertGuestDialog(guest: guest),
    );
  }

  Future<void> _deleteGuest(String guestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Guest', style: GoogleFonts.poppins()),
        content: Text(
          'Are you sure you want to delete this guest?',
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
      await firestoreService.deleteDocument('guests', guestId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guest deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
