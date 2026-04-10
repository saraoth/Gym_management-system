import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../models/trainer.dart';

class EditTrainerDialog extends ConsumerStatefulWidget {
  final Trainer trainer;
  
  const EditTrainerDialog({super.key, required this.trainer});

  @override
  ConsumerState<EditTrainerDialog> createState() => _EditTrainerDialogState();
}

class _EditTrainerDialogState extends ConsumerState<EditTrainerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.trainer.name);
    _phoneController = TextEditingController(text: widget.trainer.phone);
    _specializationController = TextEditingController(text: widget.trainer.specialization);
    _status = widget.trainer.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _updateTrainer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);

      await firestoreService.updateDocument('trainers', widget.trainer.id, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'status': _status,
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trainer updated successfully'),
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
                      'Edit Trainer',
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
                      return 'Please enter trainer name';
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
                
                TextFormField(
                  controller: _specializationController,
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter specialization';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info),
                  ),
                  items: ['Active', 'Inactive'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _status = value!);
                  },
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateTrainer,
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
                          'Update Trainer',
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
