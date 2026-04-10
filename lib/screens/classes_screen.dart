import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../widgets/side_navigation.dart';
import '../models/workout_class.dart';

class ClassesScreen extends ConsumerStatefulWidget {
  const ClassesScreen({super.key});

  @override
  ConsumerState<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends ConsumerState<ClassesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  String _selectedDay = 'Monday';
  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

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
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 600 && size.width <= 1200;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop || isTablet) const SideNavigation(currentRoute: '/classes'),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWeekSelector(),
                          const SizedBox(height: 24),
                          _buildClassSchedule(isDesktop, isTablet),
                          const SizedBox(height: 32),
                          _buildUpcomingClasses(),
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
          onPressed: () => _showAddClassDialog(context),
          icon: const Icon(Icons.add),
          label: Text(
            'Add Class',
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
            'Workout & Classes',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final animationValue = Curves.easeOut.transform(_staggerController.value);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Day',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _weekDays.map((day) {
                  final isSelected = day == _selectedDay;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(
                      milliseconds: 400 + (_weekDays.indexOf(day) * 50),
                    ),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: _DayChip(
                      day: day,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedDay = day;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassSchedule(bool isDesktop, bool isTablet) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('classes'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        var classes = snapshot.data!.docs.map((doc) {
          return WorkoutClass.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // Filter by selected day
        classes = classes.where((c) {
          final dayName = DateFormat('EEEE').format(c.startTime);
          return dayName == _selectedDay;
        }).toList();

        // Sort by start time
        classes.sort((a, b) => a.startTime.compareTo(b.startTime));

        if (classes.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule for $_selectedDay',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isDesktop ? 1.3 : (isTablet ? 1.2 : 1.5),
              ),
              itemCount: classes.length,
              itemBuilder: (context, index) {
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
                  child: _ClassCard(workoutClass: classes[index]),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingClasses() {
    final firestoreService = ref.read(firestoreServiceProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getCollection('classes'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        var classes = snapshot.data!.docs.map((doc) {
          return WorkoutClass.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // Get upcoming classes (next 24 hours)
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(hours: 24));
        classes = classes.where((c) {
          return c.startTime.isAfter(now) && c.startTime.isBefore(tomorrow);
        }).toList();

        classes.sort((a, b) => a.startTime.compareTo(b.startTime));

        if (classes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Classes (Next 24 Hours)',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...classes.map((workoutClass) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(-20 * (1 - value), 0),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: _UpcomingClassCard(workoutClass: workoutClass),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No classes scheduled for $_selectedDay',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new class to get started',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddClassDialog(),
    );
  }
}

class _DayChip extends StatefulWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DayChip> createState() => _DayChipState();
}

class _DayChipState extends State<_DayChip>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    )
                  : null,
              color: widget.isSelected
                  ? null
                  : (_isHovered
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.grey[200]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              widget.day,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                color: widget.isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends StatefulWidget {
  final WorkoutClass workoutClass;

  const _ClassCard({required this.workoutClass});

  @override
  State<_ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<_ClassCard>
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
    final timeFormat = DateFormat('h:mm a');
    final difficultyColor = _getDifficultyColor(widget.workoutClass.difficulty);

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
        child: Card(
          elevation: _isHovered ? 12 : 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  difficultyColor.withOpacity(0.05),
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
                          widget.workoutClass.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: difficultyColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          widget.workoutClass.difficulty,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: difficultyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        widget.workoutClass.trainerName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${timeFormat.format(widget.workoutClass.startTime)} - ${timeFormat.format(widget.workoutClass.endTime)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.workoutClass.enrolled}/${widget.workoutClass.capacity}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      if (widget.workoutClass.enrolled < widget.workoutClass.capacity)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Available',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Full',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _UpcomingClassCard extends StatelessWidget {
  final WorkoutClass workoutClass;

  const _UpcomingClassCard({required this.workoutClass});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.fitness_center,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          workoutClass.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${timeFormat.format(workoutClass.startTime)} • ${workoutClass.trainerName}',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${workoutClass.enrolled}/${workoutClass.capacity}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'enrolled',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddClassDialog extends ConsumerStatefulWidget {
  const _AddClassDialog({super.key});

  @override
  ConsumerState<_AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends ConsumerState<_AddClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _trainerController = TextEditingController();
  
  String _selectedDifficulty = 'Beginner';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _trainerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Class', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _trainerController,
                decoration: const InputDecoration(
                  labelText: 'Trainer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                  border: OutlineInputBorder(),
                ),
                items: ['Beginner', 'Intermediate', 'Advanced']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(_startTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (time != null) {
                    setState(() => _startTime = time);
                  }
                },
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(_endTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                  );
                  if (time != null) {
                    setState(() => _endTime = time);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final firestoreService = ref.read(firestoreServiceProvider);
              
              final startDateTime = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _startTime.hour,
                _startTime.minute,
              );
              
              final endDateTime = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _endTime.hour,
                _endTime.minute,
              );
              
              final newClass = WorkoutClass(
                id: '',
                name: _nameController.text,
                trainerId: '', // Can be linked to actual trainer later
                trainerName: _trainerController.text,
                description: _descriptionController.text,
                startTime: startDateTime,
                endTime: endDateTime,
                capacity: int.parse(_capacityController.text),
                enrolled: 0,
                difficulty: _selectedDifficulty,
                tags: [], // Empty tags list, can be added later
              );
              
              await firestoreService.addDocument('classes', newClass.toMap());
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class added successfully')),
                );
              }
            }
          },
          child: const Text('Add Class'),
        ),
      ],
    );
  }
}
