import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';
import '../models/trainer.dart';
import '../services/firestore_service.dart';

class CheckInDialog extends ConsumerStatefulWidget {
  const CheckInDialog({super.key});

  @override
  ConsumerState<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends ConsumerState<CheckInDialog> {
  String? _selectedMemberId;
  String _activityType = 'Gym';
  String? _selectedTrainerId;
  String? _className;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Check In Member',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Member Selection
            Text(
              'Select Member',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getCollection('members'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final members = snapshot.data!.docs
                    .map((doc) => Member.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        ))
                    .where((m) => m.status == 'Active')
                    .toList();

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMemberId,
                      isExpanded: true,
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Choose a member',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: GoogleFonts.inter(color: Colors.white),
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      items: members.map((member) {
                        return DropdownMenuItem<String>(
                          value: member.id,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${member.name} - ${member.phone}',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMemberId = value;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Activity Type
            Text(
              'Activity Type',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _activityType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: GoogleFonts.inter(color: Colors.white),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  items: ['Gym', 'Class', 'PT Session'].map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          type,
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _activityType = value!;
                      if (_activityType != 'PT Session') {
                        _selectedTrainerId = null;
                      }
                      if (_activityType != 'Class') {
                        _className = null;
                      }
                    });
                  },
                ),
              ),
            ),
            
            // PT Session - Trainer Selection
            if (_activityType == 'PT Session') ...[
              const SizedBox(height: 20),
              Text(
                'Select Trainer',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getCollection('trainers'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final trainers = snapshot.data!.docs
                      .map((doc) => Trainer.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          ))
                      .where((t) => t.status == 'active')
                      .toList();

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTrainerId,
                        isExpanded: true,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Choose a trainer',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                        dropdownColor: const Color(0xFF1A1A1A),
                        style: GoogleFonts.inter(color: Colors.white),
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        items: trainers.map((trainer) {
                          return DropdownMenuItem<String>(
                            value: trainer.id,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                trainer.name,
                                style: GoogleFonts.inter(color: Colors.white),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTrainerId = value;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
            
            // Class - Class Name
            if (_activityType == 'Class') ...[
              const SizedBox(height: 20),
              Text(
                'Class Name',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _className = value;
                  });
                },
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter class name',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
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
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Check In',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckIn() async {
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member')),
      );
      return;
    }

    if (_activityType == 'PT Session' && _selectedTrainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a trainer for PT session')),
      );
      return;
    }

    if (_activityType == 'Class' && (_className == null || _className!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter class name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      
      // Get member details
      final memberDoc = await firestoreService.getDocument('members', _selectedMemberId!);
      final memberData = memberDoc.data() as Map<String, dynamic>;
      final memberName = memberData['name'] ?? '';
      
      // Get trainer name if PT session
      String? trainerName;
      if (_activityType == 'PT Session' && _selectedTrainerId != null) {
        final trainerDoc = await firestoreService.getDocument('trainers', _selectedTrainerId!);
        final trainerData = trainerDoc.data() as Map<String, dynamic>;
        trainerName = trainerData['name'] ?? '';
      }
      
      // Create attendance record
      await firestoreService.addDocument('attendance', {
        'memberId': _selectedMemberId,
        'memberName': memberName,
        'checkInTime': Timestamp.now(),
        'checkOutTime': null,
        'activityType': _activityType,
        'trainerId': _selectedTrainerId,
        'trainerName': trainerName,
        'className': _className,
        'duration': null,
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$memberName checked in successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
