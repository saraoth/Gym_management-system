import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plan.dart';
import '../services/firestore_service.dart';
import '../widgets/side_navigation.dart';
import '../widgets/add_plan_dialog.dart';
import '../widgets/edit_plan_dialog.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  String _searchQuery = '';
  String _durationFilter = 'All';
  String _trainingFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile) const SideNavigation(currentRoute: '/plans'),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (isMobile)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {},
                        ),
                      Text(
                        'Membership Plans',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Search
                      SizedBox(
                        width: isMobile ? 150 : 300,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search plans...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                        // Filters
                        Row(
                          children: [
                            Text(
                              'Filter by:',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(width: 16),
                            DropdownButton<String>(
                              value: _durationFilter,
                              items: ['All', 'Day', 'Sessions', 'Monthly', '3 Months', '6 Months', 'Yearly']
                                  .map((duration) => DropdownMenuItem(
                                        value: duration,
                                        child: Text(duration),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _durationFilter = value!;
                                });
                              },
                            ),
                            const SizedBox(width: 16),
                            DropdownButton<String>(
                              value: _trainingFilter,
                              items: ['All', 'Personal', 'General', 'Equipment Only', 'Equipment + Classes']
                                  .map((training) => DropdownMenuItem(
                                        value: training,
                                        child: Text(training),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _trainingFilter = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Plans Grid
                        StreamBuilder<QuerySnapshot>(
                          stream: firestoreService.getCollection('plans'),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            var plans = snapshot.data!.docs
                                .map((doc) => Plan.fromMap(
                                    doc.data() as Map<String, dynamic>, doc.id))
                                .toList();

                            // Apply filters
                            if (_searchQuery.isNotEmpty) {
                              plans = plans
                                  .where((p) =>
                                      p.name.toLowerCase().contains(_searchQuery))
                                  .toList();
                            }

                            if (_durationFilter != 'All') {
                              plans = plans
                                  .where((p) => p.duration == _durationFilter)
                                  .toList();
                            }

                            if (_trainingFilter != 'All') {
                              plans = plans
                                  .where((p) => p.trainingType == _trainingFilter)
                                  .toList();
                            }

                            if (plans.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.card_membership,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No plans found',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 1 : 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: isMobile ? 1.2 : 0.7,
                              ),
                              itemCount: plans.length,
                              itemBuilder: (context, index) {
                                final plan = plans[index];
                                return _buildPlanCard(plan, theme, firestoreService);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddPlanDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Plan'),
      ),
    );
  }

  Widget _buildPlanCard(Plan plan, ThemeData theme, FirestoreService firestoreService) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            showDialog(
                              context: context,
                              builder: (context) => EditPlanDialog(plan: plan),
                            );
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              plan.isActive ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(plan.isActive ? 'Deactivate' : 'Activate'),
                          ],
                        ),
                        onTap: () async {
                          await firestoreService.updateDocument(
                            'plans',
                            plan.id,
                            {'isActive': !plan.isActive},
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Plan'),
                              content: const Text(
                                  'Are you sure you want to delete this plan?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await firestoreService.deleteDocument('plans', plan.id);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Price
              Text(
                'E£${plan.price.toStringAsFixed(0)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                plan.sessions != null 
                    ? '${plan.sessions} sessions'
                    : 'per ${plan.duration.toLowerCase()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              // Training Type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  plan.trainingType,
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (plan.includesClasses)
                    _buildBadge('Classes', Icons.fitness_center, Colors.green, theme),
                  if (plan.includesEquipment)
                    _buildBadge('Equipment', Icons.sports_gymnastics, Colors.blue, theme),
                  if (plan.ptSessions > 0)
                    _buildBadge('${plan.ptSessions} PT', Icons.person, Colors.orange, theme),
                  if (plan.friendInvitations > 0)
                    _buildBadge('${plan.friendInvitations} Invites', Icons.people, Colors.purple, theme),
                ],
              ),
              const SizedBox(height: 16),
              if (plan.registrationFee != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.payment, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'Registration: E£${plan.registrationFee!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Features
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plan.features.length,
                  itemBuilder: (context, index) {
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
                          Expanded(
                            child: Text(
                              plan.features[index],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: plan.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      plan.isActive ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: plan.isActive ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      plan.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: plan.isActive ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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

  Widget _buildBadge(String label, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
