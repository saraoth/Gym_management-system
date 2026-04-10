import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/payment.dart';
import '../models/member.dart';
import '../services/firestore_service.dart';
import '../widgets/side_navigation.dart';
import '../widgets/add_payment_dialog.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen>
    with TickerProviderStateMixin {
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _reportPeriod = 'Monthly';

  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile) const SideNavigation(currentRoute: '/payments'),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (isMobile)
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {},
                          ),
                        Text(
                          'Payments & Reports',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Search
                        SizedBox(
                          width: isMobile ? 150 : 300,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search payments...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Revenue Summary Cards
                          StreamBuilder<QuerySnapshot>(
                            stream: firestoreService.getCollection('payments'),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final payments = snapshot.data!.docs
                                  .map((doc) => Payment.fromMap(
                                      doc.data() as Map<String, dynamic>, doc.id))
                                  .toList();

                              final now = DateTime.now();
                              final thisMonth = payments.where((p) =>
                                  p.paymentDate.year == now.year &&
                                  p.paymentDate.month == now.month).toList();
                              final thisYear = payments.where((p) =>
                                  p.paymentDate.year == now.year).toList();

                              final monthlyRevenue = thisMonth.fold<double>(
                                  0, (sum, p) => sum + p.amount);
                              final yearlyRevenue = thisYear.fold<double>(
                                  0, (sum, p) => sum + p.amount);
                              final pendingPayments = payments
                                  .where((p) => p.status == 'Pending')
                                  .length;
                              final overduePayments = payments
                                  .where((p) => p.status == 'Overdue')
                                  .length;

                              final cards = [
                                _buildSummaryCard(
                                  context,
                                  'Monthly Revenue',
                                  'E£${monthlyRevenue.toStringAsFixed(0)}',
                                  Icons.trending_up,
                                  Colors.green,
                                  0,
                                ),
                                _buildSummaryCard(
                                  context,
                                  'Yearly Revenue',
                                  'E£${yearlyRevenue.toStringAsFixed(0)}',
                                  Icons.account_balance_wallet,
                                  Colors.blue,
                                  1,
                                ),
                                _buildSummaryCard(
                                  context,
                                  'Pending Payments',
                                  pendingPayments.toString(),
                                  Icons.pending_actions,
                                  Colors.orange,
                                  2,
                                ),
                                _buildSummaryCard(
                                  context,
                                  'Overdue Payments',
                                  overduePayments.toString(),
                                  Icons.warning,
                                  Colors.red,
                                  3,
                                ),
                              ];

                              return Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: cards,
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Revenue Chart
                          _buildRevenueChart(firestoreService),
                          const SizedBox(height: 32),
                          // Filters and Payment Table
                          Row(
                            children: [
                              Text(
                                'Payment History',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              // Status Filter
                              DropdownButton<String>(
                                value: _statusFilter,
                                items: ['All', 'Paid', 'Pending', 'Overdue']
                                    .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _statusFilter = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildPaymentTable(firestoreService, isMobile),
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
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: Curves.elasticOut,
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddPaymentDialog(),
            );
          },
          icon: const Icon(Icons.add),
          label: Text('Add Payment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

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
      child: _AnimatedSummaryCard(
        title: title,
        value: value,
        icon: icon,
        color: color,
        isMobile: isMobile,
      ),
    );
  }

  Widget _buildRevenueChart(FirestoreService firestoreService) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Revenue Trend',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Monthly', label: Text('Monthly')),
                    ButtonSegment(value: 'Yearly', label: Text('Yearly')),
                  ],
                  selected: {_reportPeriod},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _reportPeriod = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getCollection('payments'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final payments = snapshot.data!.docs
                    .map((doc) => Payment.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                final now = DateTime.now();
                final months = List.generate(6, (i) {
                  final month = DateTime(now.year, now.month - i, 1);
                  return month;
                }).reversed.toList();

                final revenueData = months.map((month) {
                  final monthPayments = payments.where((p) =>
                      p.paymentDate.year == month.year &&
                      p.paymentDate.month == month.month).toList();
                  final revenue = monthPayments.fold<double>(
                      0, (sum, p) => sum + p.amount);
                  return {
                    'month': DateFormat('MMM').format(month),
                    'revenue': revenue,
                  };
                }).toList();

                final maxRevenue = revenueData.fold<double>(
                    0, (max, data) => data['revenue'] as double > max ? data['revenue'] as double : max);

                return SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: revenueData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final revenue = data['revenue'] as double;
                      final height = maxRevenue > 0 ? (revenue / maxRevenue) * 180 : 0;

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 800 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Opacity(
                                opacity: value,
                                child: Text(
                                  'E£${(revenue / 1000).toStringAsFixed(0)}k',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 40,
                                height: height * value,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['month'] as String,
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ],
                          );
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTable(FirestoreService firestoreService, bool isMobile) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('payments'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var payments = snapshot.data!.docs
            .map((doc) =>
                Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        // Apply filters
        if (_searchQuery.isNotEmpty) {
          payments = payments
              .where((p) =>
                  p.memberName.toLowerCase().contains(_searchQuery) ||
                  p.memberId.toLowerCase().contains(_searchQuery))
              .toList();
        }

        if (_statusFilter != 'All') {
          payments = payments.where((p) => p.status == _statusFilter).toList();
        }

        // Sort by payment date (newest first)
        payments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

        if (isMobile) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 50)),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: _buildPaymentCard(payment, theme),
              );
            },
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowMinHeight: 60,
              headingRowColor: WidgetStateProperty.all(
                theme.colorScheme.primary.withOpacity(0.1),
              ),
              columns: [
                DataColumn(label: Text('Member Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Amount', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Payment Method', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Payment Date', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Due Date', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Plan Type', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Actions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
              ],
              rows: payments.map((payment) {
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return theme.colorScheme.primary.withOpacity(0.05);
                      }
                      return null;
                    },
                  ),
                  cells: [
                    DataCell(Text(payment.memberName, style: GoogleFonts.poppins())),
                    DataCell(Text('E£${payment.amount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                    DataCell(Text(payment.paymentMethod, style: GoogleFonts.poppins())),
                    DataCell(_buildStatusChip(payment.status, theme)),
                    DataCell(Text(
                        DateFormat('dd MMM yyyy').format(payment.paymentDate), style: GoogleFonts.poppins())),
                    DataCell(Text(
                        DateFormat('dd MMM yyyy').format(payment.dueDate), style: GoogleFonts.poppins())),
                    DataCell(Text(payment.planType ?? 'N/A', style: GoogleFonts.poppins())),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (payment.status != 'Paid')
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline),
                              color: Colors.green,
                              tooltip: 'Mark as Paid',
                              onPressed: () async {
                                await firestoreService.updateDocument(
                                  'payments',
                                  payment.id,
                                  {'status': 'Paid'},
                                );
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            tooltip: 'Delete',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Payment', style: GoogleFonts.poppins()),
                                  content: Text(
                                      'Are you sure you want to delete this payment record?', style: GoogleFonts.poppins()),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await firestoreService.deleteDocument(
                                    'payments', payment.id);
                              }
                            },
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
      },
    );
  }

  Widget _buildPaymentCard(Payment payment, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              _getStatusColor(payment.status).withOpacity(0.05),
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
                children: [
                  Expanded(
                    child: Text(
                      payment.memberName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(payment.status, theme),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Amount', 'E£${payment.amount.toStringAsFixed(0)}'),
              _buildInfoRow('Payment Method', payment.paymentMethod),
              _buildInfoRow('Payment Date',
                  DateFormat('dd MMM yyyy').format(payment.paymentDate)),
              _buildInfoRow(
                  'Due Date', DateFormat('dd MMM yyyy').format(payment.dueDate)),
              _buildInfoRow('Plan Type', payment.planType ?? 'N/A'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (payment.status != 'Paid')
                    TextButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark Paid'),
                      onPressed: () async {
                        final firestoreService =
                            ref.read(firestoreServiceProvider);
                        await firestoreService.updateDocument(
                          'payments',
                          payment.id,
                          {'status': 'Paid'},
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(value, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'Paid' ? Icons.check_circle :
            status == 'Pending' ? Icons.schedule :
            Icons.warning,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _AnimatedSummaryCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isMobile;

  const _AnimatedSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isMobile,
  });

  @override
  State<_AnimatedSummaryCard> createState() => _AnimatedSummaryCardState();
}

class _AnimatedSummaryCardState extends State<_AnimatedSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.isMobile ? double.infinity : 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                widget.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 28),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            widget.value,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
