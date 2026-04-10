import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/guest.dart';
import '../services/firestore_service.dart';
import '../widgets/convert_guest_dialog.dart';
import 'main_layout.dart';

class GuestDetailPage extends ConsumerWidget {
  final String guestId;

  const GuestDetailPage({super.key, required this.guestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return MainLayout(
      currentRoute: '/guests',
      child: Container(
        color: const Color(0xFF000000),
        child: StreamBuilder<DocumentSnapshot>(
          stream: firestoreService.getDocument('guests', guestId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'Guest not found',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              );
            }

            final guest = Guest.fromMap(
              snapshot.data!.data() as Map<String, dynamic>,
              snapshot.data!.id,
            );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, guest),
                  _buildContent(context, guest, firestoreService),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Guest guest) {
    final statusColor = _getStatusColor(guest.status);

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
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Back to Guests',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                child: Text(
                  guest.name[0].toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B82F6),
                  ),
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
                          guest.name,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            guest.status.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Guest ID: ${guest.id}',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (guest.status != 'Converted')
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConvertGuestDialog(guest: guest),
                    );
                  },
                  icon: const Icon(Icons.person_add, size: 18),
                  label: Text(
                    'Convert to Member',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Guest guest, FirestoreService firestoreService) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            title: 'Contact Information',
            child: Column(
              children: [
                _buildInfoRow(Icons.email, 'Email', guest.email),
                _buildInfoRow(Icons.phone, 'Phone', guest.phone),
                _buildInfoRow(Icons.source, 'Source', guest.source),
                _buildInfoRow(Icons.calendar_today, 'Visit Date', _formatDate(guest.visitDate)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'Interest & Follow-up',
            child: Column(
              children: [
                _buildInfoRow(Icons.fitness_center, 'Visit Type', guest.visitType),
                _buildInfoRow(
                  Icons.event,
                  'Follow-up Date',
                  guest.followUpDate != null ? _formatDate(guest.followUpDate!) : 'Not set',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return const Color(0xFF3B82F6);
      case 'Contacted':
        return const Color(0xFFF59E0B);
      case 'Visited':
        return const Color(0xFFA855F7);
      case 'Converted':
        return const Color(0xFF10B981);
      case 'Lost':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
