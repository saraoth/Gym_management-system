import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedPlans() async {
  final firestore = FirebaseFirestore.instance;
  final plansCollection = firestore.collection('plans');

  // Check if plans already exist
  final existingPlans = await plansCollection.get();
  if (existingPlans.docs.isNotEmpty) {
    print('Plans already exist. Skipping seed.');
    return;
  }

  final plans = [
    {
      'name': 'Day Use',
      'price': 100.0,
      'duration': 'Day',
      'trainingType': 'General',
      'features': [
        'Single day entry',
        'Access to all equipment',
        'Locker facilities',
      ],
      'isActive': true,
      'createdAt': DateTime.now(),
      'sessions': null,
      'includesClasses': false,
      'includesEquipment': true,
      'ptSessions': 0,
      'friendInvitations': 0,
      'registrationFee': null,
    },
    {
      'name': '12 Sessions / Month',
      'price': 400.0,
      'duration': 'Sessions',
      'trainingType': 'General',
      'features': [
        '12 sessions per month',
        'All classes included',
        'Flexible scheduling',
        'Valid for 30 days',
      ],
      'isActive': true,
      'createdAt': DateTime.now(),
      'sessions': 12,
      'includesClasses': true,
      'includesEquipment': true,
      'ptSessions': 0,
      'friendInvitations': 0,
      'registrationFee': null,
    },
    {
      'name': 'Monthly Equipment Only',
      'price': 500.0,
      'duration': 'Monthly',
      'trainingType': 'Equipment Only',
      'features': [
        'Full month access',
        'All gym equipment',
        'Locker facilities',
        'Unlimited visits',
      ],
      'isActive': true,
      'createdAt': DateTime.now(),
      'sessions': null,
      'includesClasses': false,
      'includesEquipment': true,
      'ptSessions': 0,
      'friendInvitations': 0,
      'registrationFee': null,
    },
    {
      'name': 'Monthly Equipment + Classes',
      'price': 650.0,
      'duration': 'Monthly',
      'trainingType': 'Equipment + Classes',
      'features': [
        'Full month access',
        'All gym equipment',
        'All classes included',
        'Unlimited visits',
        'Priority class booking',
      ],
      'isActive': true,
      'createdAt': DateTime.now(),
      'sessions': null,
      'includesClasses': true,
      'includesEquipment': true,
      'ptSessions': 0,
      'friendInvitations': 0,
      'registrationFee': null,
    },
    {
      'name': '3-Month Subscription',
      'price': 1400.0,
      'duration': '3 Months',
      'trainingType': 'Equipment + Classes',
      'features': [
        '3 months full access',
        'All gym equipment',
        'All classes included',
        '1 personal training session',
        '2 friend invitations',
        'Nutrition consultation',
      ],
      'isActive': true,
      'createdAt': DateTime.now(),
      'sessions': null,
      'includesClasses': true,
      'includesEquipment': true,
      'ptSessions': 1,
      'friendInvitations': 2,
      'registrationFee': 300.0,
    },
    {
      'name': '6-Month Subscription',
      'price': 2400.0,
      'duration': '6 Months',
      'trainingType': 'Equipment + Classes',
      'features': [
        '6 months full access',
        'All gym equipment',
        'All classes included',
        '2 personal training sessions',
        '4 friend invitations',
        'Monthly body composition analysis',
        'Nutrition consultation',
        'Priority support',
      ],
      'isActive': true,
      'createdAt': DateTime.now(),
      'sessions': null,
      'includesClasses': true,
      'includesEquipment': true,
      'ptSessions': 2,
      'friendInvitations': 4,
      'registrationFee': 300.0,
    },
  ];

  for (final plan in plans) {
    await plansCollection.add(plan);
    print('Added plan: ${plan['name']}');
  }

  print('Successfully seeded ${plans.length} plans!');
}
