import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/plan.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key});

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  Plan? _selectedPlan;
  String _trainingType = 'General';
  String? _selectedTrainerId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double _calculateFee() {
    if (_selectedPlan == null) return 0;
    
    double baseFee = _selectedPlan!.price;
    
    // Add registration fee if applicable
    if (_selectedPlan!.registrationFee != null) {
      baseFee += _selectedPlan!.registrationFee!;
    }
    
    return baseFee;
  }

  DateTime _calculateExpiryDate() {
    if (_selectedPlan == null) return DateTime.now();
    
    final startDate = DateTime.now();
    
    // Handle session-based plans
    if (_selectedPlan!.sessions != null) {
      // Session-based plans expire in 30 days by default
      return startDate.add(const Duration(days: 30));
    }
    
    // Handle duration-based plans
    switch (_selectedPlan!.duration.toLowerCase()) {
      case 'day':
        return startDate.add(const Duration(days: 1));
      case 'monthly':
        return startDate.add(const Duration(days: 30));
      case '3 months':
        return startDate.add(const Duration(days: 90));
      case '6 months':
        return startDate.add(const Duration(days: 180));
      case 'yearly':
        return startDate.add(const Duration(days: 365));
      default:
        return startDate.add(const Duration(days: 30));
    }
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a membership plan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final startDate = DateTime.now();
      final expiryDate = _calculateExpiryDate();
      final fee = _calculateFee();

      await firestoreService.addDocument('members', {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'planId': _selectedPlan!.id,
        'planName': _selectedPlan!.name,
        'planType': _selectedPlan!.duration,
        'trainingType': _trainingType,
        'trainerId': _selectedTrainerId,
        'status': 'Active',
        'startDate': startDate,
        'expiryDate': expiryDate,
        'fee': fee,
        'createdAt': DateTime.now(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member added successfully'),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : size.width * 0.9,
          maxHeight: size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Member',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter member name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                StreamBuilder<QuerySnapshot>(
                  stream: ref.read(firestoreServiceProvider).getCollection('plans'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No plans available. Please create plans first.',
                                style: GoogleFonts.poppins(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final plans = snapshot.data!.docs
                        .map((doc) => Plan.fromMap(
                            doc.data() as Map<String, dynamic>, doc.id))
                        .where((plan) => plan.isActive)
                        .toList();
                    
                    if (plans.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No active plans available.',
                                style: GoogleFonts.poppins(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return DropdownButtonFormField<Plan>(
                      value: _selectedPlan,
                      decoration: const InputDecoration(
                        labelText: 'Membership Plan',
                        prefixIcon: Icon(Icons.card_membership),
                      ),
                      items: plans.map((plan) {
                        return DropdownMenuItem(
                          value: plan,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                plan.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'E£${plan.price.toStringAsFixed(0)} - ${plan.duration}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPlan = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a plan';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _trainingType,
                  decoration: const InputDecoration(
                    labelText: 'Training Type',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  items: ['General', 'Personal'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _trainingType = value!);
                  },
                ),
                const SizedBox(height: 16),
                
                if (_trainingType == 'Personal')
                  StreamBuilder<QuerySnapshot>(
                    stream: ref.read(firestoreServiceProvider).getCollection('trainers'),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      
                      final trainers = snapshot.data!.docs;
                      
                      return DropdownButtonFormField<String>(
                        value: _selectedTrainerId,
                        decoration: const InputDecoration(
                          labelText: 'Assign Trainer',
                          prefixIcon: Icon(Icons.person_pin),
                        ),
                        items: trainers.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(data['name'] ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedTrainerId = value);
                        },
                      );
                    },
                  ),
                const SizedBox(height: 24),
                
                if (_selectedPlan != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Plan: ${_selectedPlan!.name}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        Text(
                          'Duration: ${_selectedPlan!.duration}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        if (_selectedPlan!.sessions != null)
                          Text(
                            'Sessions: ${_selectedPlan!.sessions}',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        Text(
                          'Training: $_trainingType',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const Divider(height: 16),
                        if (_selectedPlan!.registrationFee != null)
                          Text(
                            'Registration Fee: E£${_selectedPlan!.registrationFee!.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        Text(
                          'Plan Fee: E£${_selectedPlan!.price.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        Text(
                          'Total Fee: E£${_calculateFee().toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Expires: ${_calculateExpiryDate().toString().split(' ')[0]}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveMember,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Add Member',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
