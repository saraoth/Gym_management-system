import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';

class AddPlanDialog extends ConsumerStatefulWidget {
  const AddPlanDialog({super.key});

  @override
  ConsumerState<AddPlanDialog> createState() => _AddPlanDialogState();
}

class _AddPlanDialogState extends ConsumerState<AddPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _featureController = TextEditingController();
  final _sessionsController = TextEditingController();
  final _ptSessionsController = TextEditingController(text: '0');
  final _friendInvitationsController = TextEditingController(text: '0');
  final _registrationFeeController = TextEditingController();
  
  String _duration = 'Monthly';
  String _trainingType = 'General';
  final List<String> _features = [];
  bool _includesClasses = false;
  bool _includesEquipment = true;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _featureController.dispose();
    _sessionsController.dispose();
    _ptSessionsController.dispose();
    _friendInvitationsController.dispose();
    _registrationFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Plan',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Plan Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Plan Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter plan name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (EGP)',
                    border: OutlineInputBorder(),
                    prefixText: 'E£',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Duration
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    border: OutlineInputBorder(),
                  ),
                  value: _duration,
                  items: ['Day', 'Sessions', 'Monthly', '3 Months', '6 Months', 'Yearly']
                      .map((duration) => DropdownMenuItem(
                            value: duration,
                            child: Text(duration),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _duration = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_duration == 'Sessions')
                  Column(
                    children: [
                      TextFormField(
                        controller: _sessionsController,
                        decoration: const InputDecoration(
                          labelText: 'Number of Sessions',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (_duration == 'Sessions' && (value == null || value.isEmpty)) {
                            return 'Please enter number of sessions';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                // Training Type
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Training Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _trainingType,
                  items: ['Personal', 'General', 'Equipment Only', 'Equipment + Classes']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _trainingType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Includes Classes'),
                  value: _includesClasses,
                  onChanged: (value) {
                    setState(() {
                      _includesClasses = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Includes Equipment Access'),
                  value: _includesEquipment,
                  onChanged: (value) {
                    setState(() {
                      _includesEquipment = value ?? true;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ptSessionsController,
                  decoration: const InputDecoration(
                    labelText: 'Personal Training Sessions',
                    border: OutlineInputBorder(),
                    helperText: 'Number of included PT sessions',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _friendInvitationsController,
                  decoration: const InputDecoration(
                    labelText: 'Friend Invitations',
                    border: OutlineInputBorder(),
                    helperText: 'Number of friend invitations included',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _registrationFeeController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Fee (Optional)',
                    border: OutlineInputBorder(),
                    prefixText: 'E£',
                    helperText: 'One-time registration fee (Gaid)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Features
                Text(
                  'Features',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _featureController,
                        decoration: const InputDecoration(
                          hintText: 'Add a feature',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: theme.colorScheme.primary,
                      onPressed: () {
                        if (_featureController.text.isNotEmpty) {
                          setState(() {
                            _features.add(_featureController.text);
                            _featureController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_features.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: _features.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(feature)),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    _features.remove(feature);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
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
                          if (_features.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please add at least one feature'),
                              ),
                            );
                            return;
                          }

                          final plan = {
                            'name': _nameController.text,
                            'price': double.parse(_priceController.text),
                            'duration': _duration,
                            'trainingType': _trainingType,
                            'features': _features,
                            'isActive': true,
                            'createdAt': DateTime.now(),
                            'sessions': _duration == 'Sessions' && _sessionsController.text.isNotEmpty
                                ? int.parse(_sessionsController.text)
                                : null,
                            'includesClasses': _includesClasses,
                            'includesEquipment': _includesEquipment,
                            'ptSessions': int.tryParse(_ptSessionsController.text) ?? 0,
                            'friendInvitations': int.tryParse(_friendInvitationsController.text) ?? 0,
                            'registrationFee': _registrationFeeController.text.isNotEmpty
                                ? double.parse(_registrationFeeController.text)
                                : null,
                          };

                          await firestoreService.addDocument('plans', plan);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Plan added successfully'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Add Plan'),
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
