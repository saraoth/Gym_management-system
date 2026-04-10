import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';
import '../services/firestore_service.dart';
import '../widgets/add_payment_dialog.dart';
import 'main_layout.dart';

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  String _searchQuery = '';
  String _filterType = 'All';
  String _filterMethod = 'All';

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return MainLayout(
      currentRoute: '/payments',
      child: Container(
        color: const Color(0xFF000000),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getCollection('payments'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                      ),
                    );
                  }

                  final payments = snapshot.data!.docs
                      .map((doc) => Payment.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          ))
                      .toList();

                  return Column(
                    children: [
                      _buildStats(payments),
                      _buildFilters(),
                      Expanded(child: _buildPaymentsList(payments)),
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
                    'Payments',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track all payments and financial transactions',
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
                    builder: (context) => const AddPaymentDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  'Record Payment',
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

  Widget _buildStats(List<Payment> payments) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    final completedPayments = payments.where((p) => p.status == 'Paid').toList();
    final monthlyPayments = completedPayments.where((p) => p.paymentDate.isAfter(monthStart)).toList();
    
    final totalRevenue = completedPayments.fold<double>(0, (sum, p) => sum + p.amount);
    final monthlyRevenue = monthlyPayments.fold<double>(0, (sum, p) => sum + p.amount);
    final pendingPayments = payments.where((p) => p.status == 'Pending').length;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Revenue',
              '${totalRevenue.toStringAsFixed(0)} EGP',
              'All time',
              const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Monthly Revenue',
              '${monthlyRevenue.toStringAsFixed(0)} EGP',
              'This month',
              const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total Payments',
              completedPayments.length.toString(),
              'Completed',
              const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pending',
              pendingPayments.toString(),
              'Awaiting',
              const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color color) {
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
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _buildFilterDropdown(
            'Type',
            _filterType,
            ['All', 'Membership', 'PT Session', 'Registration', 'Other'],
            (value) => setState(() => _filterType = value!),
          ),
          const SizedBox(width: 12),
          _buildFilterDropdown(
            'Method',
            _filterMethod,
            ['All', 'Cash', 'Card', 'Bank Transfer', 'Mobile Payment'],
            (value) => setState(() => _filterMethod = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: const Color(0xFF1A1A1A),
        underline: const SizedBox(),
        style: GoogleFonts.inter(color: Colors.white),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text('$label: $item'),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentsList(List<Payment> payments) {
    var filteredPayments = payments;

    if (_filterType != 'All') {
      filteredPayments = filteredPayments.where((p) => p.paymentType == _filterType).toList();
    }

    if (_filterMethod != 'All') {
      filteredPayments = filteredPayments.where((p) => p.paymentMethod == _filterMethod).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredPayments = filteredPayments.where((p) {
        return p.memberName.toLowerCase().contains(query) ||
            p.memberId.toLowerCase().contains(query);
      }).toList();
    }

    filteredPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    if (filteredPayments.isEmpty) {
      return Center(
        child: Text(
          'No payments found',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = filteredPayments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final statusColor = payment.status == 'Paid'
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
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
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.payment,
                color: Color(0xFF3B82F6),
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
                        payment.memberName,
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
                          payment.status.toUpperCase(),
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
                    '${payment.paymentType} • ${payment.paymentMethod}',
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
                  '${payment.amount.toStringAsFixed(0)} EGP',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(payment.paymentDate),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
