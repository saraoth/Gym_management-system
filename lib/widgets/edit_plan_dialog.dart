import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plan.dart';
import '../services/firestore_service.dart';

class EditPlanDialog extends ConsumerStatefulWidget {
  final Plan plan;

  const EditPlanDialog({super.key, required this.plan});

  @override
  ConsumerState<EditPlanDialog> createState() => _EditPlanDialogState();
}

class _EditPlanDialogState extends ConsumerState<EditPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  final _featureController = TextEditingController();
  late String _duration;
  late String _trainingType;
  late List<String> _features;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan.name);
    _priceController = TextEditingController(text: widget.plan.price.toString());
    _duration = widget.plan.duration;
    _trainingType = widget.plan.trainingType;
    _features = List.from(widget.plan.features);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _featureController.dispose();
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
                  'Edit Plan',
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
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
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
                  items: ['Monthly', 'Yearly']
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
                // Training Type
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Training Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _trainingType,
                  items: ['Personal', 'General']
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

                          final updatedPlan = {
                            'name': _nameController.text,
                            'price': double.parse(_priceController.text),
                            'duration': _duration,
                            'trainingType': _trainingType,
                            'features': _features,
                          };

                          await firestoreService.updateDocument(
                            'plans',
                            widget.plan.id,
                            updatedPlan,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Plan updated successfully'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Update Plan'),
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
