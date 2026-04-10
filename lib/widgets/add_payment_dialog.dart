import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';
import '../services/firestore_service.dart';

class AddPaymentDialog extends ConsumerStatefulWidget {
  const AddPaymentDialog({super.key});

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMemberId;
  String _selectedMemberName = '';
  double _amount = 0;
  String _paymentMethod = 'Cash';
  String _paymentType = 'Membership';
  String _status = 'Paid';
  DateTime _paymentDate = DateTime.now();
  DateTime _dueDate = DateTime.now();
  String _planType = '';
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Payment',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Member Selection
                StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getCollection('members'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final members = snapshot.data!.docs
                        .map((doc) => Member.fromMap(
                            doc.data() as Map<String, dynamic>, doc.id))
                        .toList();

                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Member',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedMemberId,
                      items: members.map((member) {
                        return DropdownMenuItem(
                          value: member.id,
                          child: Text('${member.name} - ${member.phone}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final member = members.firstWhere((m) => m.id == value);
                        setState(() {
                          _selectedMemberId = value;
                          _selectedMemberName = member.name;
                          _amount = member.fee;
                          _planType = member.planType;
                          _dueDate = member.expiryDate;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a member';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Amount
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixText: 'E£',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _amount.toString(),
                  onChanged: (value) {
                    _amount = double.tryParse(value) ?? 0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Payment Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _paymentType,
                  items: ['Membership', 'PT Session', 'Registration', 'Other']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _paymentType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Payment Method
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  value: _paymentMethod,
                  items: ['Cash', 'Card', 'UPI', 'Bank Transfer']
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Status
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: _status,
                  items: ['Paid', 'Pending', 'Overdue']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Payment Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Payment Date'),
                  subtitle: Text(
                    '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _paymentDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _paymentDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final payment = {
                            'memberId': _selectedMemberId,
                            'memberName': _selectedMemberName,
                            'amount': _amount,
                            'paymentMethod': _paymentMethod,
                            'paymentType': _paymentType,
                            'status': _status,
                            'paymentDate': _paymentDate,
                            'dueDate': _dueDate,
                            'planType': _planType,
                            'notes': _notesController.text,
                            'createdAt': DateTime.now(),
                          };

                          await firestoreService.addDocument('payments', payment);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payment added successfully'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Add Payment'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
