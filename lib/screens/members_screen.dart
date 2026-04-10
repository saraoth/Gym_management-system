import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/side_navigation.dart';
import '../models/member.dart';
import '../widgets/add_member_dialog.dart';
import '../widgets/edit_member_dialog.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _staggerController;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _filterTrainingType = 'All';

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
    
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animationController.forward();
    _staggerController.forward();
    
    _checkAndUpdateExpiredMemberships();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _staggerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAndUpdateExpiredMemberships() async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final snapshot = await firestoreService.queryCollection('members');
    
    final now = DateTime.now();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final expiryDate = (data['expiryDate'] as Timestamp).toDate();
      
      if (expiryDate.isBefore(now) && data['status'] == 'Active') {
        await firestoreService.updateDocument('members', doc.id, {
          'status': 'Expired',
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 600 && size.width <= 1200;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop || isTablet) const SideNavigation(currentRoute: '/members'),
          
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildAppBar(context),
                  _buildFilters(context, isDesktop, isTablet),
                  Expanded(
                    child: _buildMembersTable(context, isDesktop, isTablet),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddMemberDialog(context),
          icon: const Icon(Icons.add),
          label: Text(
            'Add Member',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 8,
        ),
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
            'Members Management',
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
                  _checkAndUpdateExpiredMemberships();
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
            label: const Text('Status'),
            initialSelection: _filterStatus,
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'All', label: 'All Status'),
              DropdownMenuEntry(value: 'Active', label: 'Active'),
              DropdownMenuEntry(value: 'Expired', label: 'Expired'),
            ],
            onSelected: (value) {
              setState(() => _filterStatus = value ?? 'All');
            },
          ),
          DropdownMenu<String>(
            label: const Text('Training Type'),
            initialSelection: _filterTrainingType,
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'All', label: 'All Types'),
              DropdownMenuEntry(value: 'Personal', label: 'Personal'),
              DropdownMenuEntry(value: 'General', label: 'General'),
            ],
            onSelected: (value) {
              setState(() => _filterTrainingType = value ?? 'All');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTable(BuildContext context, bool isDesktop, bool isTablet) {
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
                const SizedBox(height: 8),
                Text(
                  'Add your first member to get started',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }
        
        var members = snapshot.data!.docs.map((doc) {
          return Member.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        
        // Apply filters
        if (_searchQuery.isNotEmpty) {
          members = members.where((member) {
            return member.name.toLowerCase().contains(_searchQuery) ||
                member.phone.contains(_searchQuery);
          }).toList();
        }
        
        if (_filterStatus != 'All') {
          members = members.where((member) => member.status == _filterStatus).toList();
        }
        
        if (_filterTrainingType != 'All') {
          members = members.where((member) => member.trainingType == _filterTrainingType).toList();
        }
        
        if (members.isEmpty) {
          return Center(
            child: Text(
              'No members match your filters',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isDesktop
              ? _buildDesktopTable(members)
              : _buildMobileCards(members),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<Member> members) {
    return Card(
      elevation: 4,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dataRowMinHeight: 60,
          dataRowMaxHeight: 80,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          columns: [
            DataColumn(label: Text('Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Phone', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Plan Type', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Training Type', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Expiry Date', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Fee', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Actions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
          ],
          rows: members.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            
            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return Theme.of(context).colorScheme.primary.withOpacity(0.05);
                  }
                  return null;
                },
              ),
              cells: [
                DataCell(
                  AnimatedBuilder(
                    animation: _staggerController,
                    builder: (context, child) {
                      final delay = index * 0.05;
                      final animationValue = Curves.easeOut.transform(
                        (_staggerController.value - delay).clamp(0.0, 1.0) / (1.0 - delay),
                      );
                      
                      return Opacity(
                        opacity: animationValue,
                        child: Transform.translate(
                          offset: Offset(-20 * (1 - animationValue), 0),
                          child: child,
                        ),
                      );
                    },
                    child: Text(member.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  ),
                ),
                DataCell(Text(member.phone, style: GoogleFonts.poppins())),
                DataCell(Text(member.planType, style: GoogleFonts.poppins())),
                DataCell(Text(member.trainingType, style: GoogleFonts.poppins())),
                DataCell(
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 600 + (index * 50)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: member.status == 'Active'
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: member.status == 'Active'
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  member.status == 'Active' ? Icons.check_circle : Icons.cancel,
                                  size: 14,
                                  color: member.status == 'Active' ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  member.status,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: member.status == 'Active' ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                DataCell(Text(
                  DateFormat('MMM dd, yyyy').format(member.expiryDate),
                  style: GoogleFonts.poppins(),
                )),
                DataCell(Text('E£${member.fee.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AnimatedIconButton(
                        icon: Icons.edit,
                        color: Colors.blue,
                        onPressed: () => _showEditMemberDialog(context, member),
                        tooltip: 'Edit',
                      ),
                      const SizedBox(width: 4),
                      _AnimatedIconButton(
                        icon: Icons.refresh,
                        color: Colors.green,
                        onPressed: () => _renewMembership(member),
                        tooltip: 'Renew',
                      ),
                      const SizedBox(width: 4),
                      _AnimatedIconButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        onPressed: () => _deleteMember(member.id),
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

  Widget _buildMobileCards(List<Member> members) {
    return Column(
      children: members.asMap().entries.map((entry) {
        final index = entry.key;
        final member = entry.value;
        
        return AnimatedBuilder(
          animation: _staggerController,
          builder: (context, child) {
            final delay = index * 0.1;
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
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    member.status == 'Active'
                        ? Colors.green.withOpacity(0.05)
                        : Colors.red.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            member.name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: member.status == 'Active'
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: member.status == 'Active'
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                member.status == 'Active' ? Icons.check_circle : Icons.cancel,
                                size: 14,
                                color: member.status == 'Active' ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                member.status,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: member.status == 'Active' ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.phone, member.phone),
                    _buildInfoRow(Icons.card_membership, '${member.planType} - ${member.trainingType}'),
                    _buildInfoRow(Icons.calendar_today, 'Expires: ${DateFormat('MMM dd, yyyy').format(member.expiryDate)}'),
                    _buildInfoRow(Icons.attach_money, 'Fee: E£${member.fee.toStringAsFixed(0)}'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          onPressed: () => _showEditMemberDialog(context, member),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Renew'),
                          onPressed: () => _renewMembership(member),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                          onPressed: () => _deleteMember(member.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMemberDialog(),
    );
  }

  void _showEditMemberDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => EditMemberDialog(member: member),
    );
  }

  Future<void> _renewMembership(Member member) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    
    final newStartDate = DateTime.now();
    final newExpiryDate = member.planType == 'Monthly'
        ? newStartDate.add(const Duration(days: 30))
        : newStartDate.add(const Duration(days: 365));
    
    await firestoreService.updateDocument('members', member.id, {
      'startDate': newStartDate,
      'expiryDate': newExpiryDate,
      'status': 'Active',
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membership renewed for ${member.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteMember(String memberId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Member', style: GoogleFonts.poppins()),
        content: Text(
          'Are you sure you want to delete this member?',
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
      await firestoreService.deleteDocument('members', memberId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _AnimatedIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: Tooltip(
        message: widget.tooltip,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: _isHovered ? widget.color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(widget.icon, size: 20),
              color: widget.color,
              onPressed: widget.onPressed,
              splashRadius: 20,
            ),
          ),
        ),
      ),
    );
  }
}
