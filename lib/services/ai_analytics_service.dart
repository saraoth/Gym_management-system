import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';
import '../models/trainer.dart';
import '../models/workout_class.dart';

class AIAnalyticsService {
  // Predict member churn based on activity patterns
  Future<Map<String, dynamic>> predictMemberChurn(String memberId, List<Map<String, dynamic>> attendanceHistory) async {
    // Simple ML-like algorithm: analyze attendance frequency
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    
    final recentAttendance = attendanceHistory.where((record) {
      final date = (record['date'] as Timestamp).toDate();
      return date.isAfter(last30Days);
    }).length;
    
    // Calculate churn risk score (0-100)
    double churnScore = 0;
    
    // Factor 1: Low attendance (40% weight)
    if (recentAttendance < 4) {
      churnScore += 40;
    } else if (recentAttendance < 8) {
      churnScore += 20;
    }
    
    // Factor 2: Declining trend (30% weight)
    final last15Days = now.subtract(const Duration(days: 15));
    final veryRecentAttendance = attendanceHistory.where((record) {
      final date = (record['date'] as Timestamp).toDate();
      return date.isAfter(last15Days);
    }).length;
    
    if (veryRecentAttendance < recentAttendance / 2) {
      churnScore += 30;
    }
    
    // Factor 3: Random variation for demo (30% weight)
    churnScore += Random().nextDouble() * 30;
    
    String riskLevel;
    String recommendation;
    
    if (churnScore > 70) {
      riskLevel = 'High';
      recommendation = 'Immediate intervention needed. Contact member and offer personalized training plan.';
    } else if (churnScore > 40) {
      riskLevel = 'Medium';
      recommendation = 'Monitor closely. Consider sending engagement email or special offer.';
    } else {
      riskLevel = 'Low';
      recommendation = 'Member is engaged. Continue current approach.';
    }
    
    return {
      'churnScore': churnScore.toInt(),
      'riskLevel': riskLevel,
      'recommendation': recommendation,
      'attendanceLast30Days': recentAttendance,
    };
  }
  
  // Analyze attendance patterns
  Map<String, dynamic> analyzeAttendancePatterns(List<Map<String, dynamic>> attendanceRecords) {
    if (attendanceRecords.isEmpty) {
      return {
        'peakDay': 'N/A',
        'peakTime': 'N/A',
        'averageDaily': 0,
        'trend': 'No data',
      };
    }
    
    // Count attendance by day of week
    final dayCount = <String, int>{};
    final timeCount = <String, int>{};
    
    for (var record in attendanceRecords) {
      final date = (record['date'] as Timestamp).toDate();
      final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
      dayCount[dayName] = (dayCount[dayName] ?? 0) + 1;
      
      final hour = date.hour;
      String timeSlot;
      if (hour < 12) {
        timeSlot = 'Morning (6-12)';
      } else if (hour < 17) {
        timeSlot = 'Afternoon (12-17)';
      } else {
        timeSlot = 'Evening (17-22)';
      }
      timeCount[timeSlot] = (timeCount[timeSlot] ?? 0) + 1;
    }
    
    final peakDay = dayCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final peakTime = timeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    // Calculate trend
    final now = DateTime.now();
    final last30Days = attendanceRecords.where((r) {
      final date = (r['date'] as Timestamp).toDate();
      return date.isAfter(now.subtract(const Duration(days: 30)));
    }).length;
    
    final previous30Days = attendanceRecords.where((r) {
      final date = (r['date'] as Timestamp).toDate();
      return date.isAfter(now.subtract(const Duration(days: 60))) &&
             date.isBefore(now.subtract(const Duration(days: 30)));
    }).length;
    
    String trend;
    if (last30Days > previous30Days * 1.1) {
      trend = 'Increasing';
    } else if (last30Days < previous30Days * 0.9) {
      trend = 'Decreasing';
    } else {
      trend = 'Stable';
    }
    
    return {
      'peakDay': peakDay,
      'peakTime': peakTime,
      'averageDaily': (attendanceRecords.length / 30).toStringAsFixed(1),
      'trend': trend,
      'dayDistribution': dayCount,
      'timeDistribution': timeCount,
    };
  }
  
  // Recommend classes for a member based on their activity
  List<Map<String, dynamic>> recommendClasses(
    Member member,
    List<WorkoutClass> availableClasses,
    List<Map<String, dynamic>> attendanceHistory,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    // Analyze member's preferred time slots
    final timePreferences = <String, int>{};
    for (var record in attendanceHistory) {
      final date = (record['date'] as Timestamp).toDate();
      final hour = date.hour;
      String timeSlot;
      if (hour < 12) {
        timeSlot = 'morning';
      } else if (hour < 17) {
        timeSlot = 'afternoon';
      } else {
        timeSlot = 'evening';
      }
      timePreferences[timeSlot] = (timePreferences[timeSlot] ?? 0) + 1;
    }
    
    final preferredTime = timePreferences.isNotEmpty
        ? timePreferences.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'morning';
    
    // Score each class
    for (var workoutClass in availableClasses) {
      if (workoutClass.enrolled >= workoutClass.capacity) continue;
      
      double score = 50; // Base score
      
      // Time preference match (30 points)
      final classHour = workoutClass.startTime.hour;
      if ((preferredTime == 'morning' && classHour < 12) ||
          (preferredTime == 'afternoon' && classHour >= 12 && classHour < 17) ||
          (preferredTime == 'evening' && classHour >= 17)) {
        score += 30;
      }
      
      // Difficulty match (20 points)
      if (member.trainingType == 'Personal' && workoutClass.difficulty == 'Advanced') {
        score += 20;
      } else if (member.trainingType == 'General' && workoutClass.difficulty == 'Beginner') {
        score += 20;
      }
      
      // Availability (20 points)
      final availabilityRatio = (workoutClass.capacity - workoutClass.enrolled) / workoutClass.capacity;
      score += availabilityRatio * 20;
      
      // Random factor for variety (10 points)
      score += Random().nextDouble() * 10;
      
      recommendations.add({
        'class': workoutClass,
        'score': score.toInt(),
        'reason': _getRecommendationReason(score, preferredTime, workoutClass),
      });
    }
    
    // Sort by score and return top 5
    recommendations.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return recommendations.take(5).toList();
  }
  
  String _getRecommendationReason(double score, String preferredTime, WorkoutClass workoutClass) {
    if (score > 80) {
      return 'Perfect match for your schedule and fitness level';
    } else if (score > 60) {
      return 'Good fit based on your $preferredTime preference';
    } else {
      return 'Available class that matches your training type';
    }
  }
  
  // Predict revenue trends
  Map<String, dynamic> predictRevenueTrends(List<Map<String, dynamic>> paymentHistory) {
    if (paymentHistory.length < 3) {
      return {
        'nextMonthPrediction': 0,
        'confidence': 'Low',
        'trend': 'Insufficient data',
      };
    }
    
    // Calculate average monthly revenue
    final monthlyRevenue = <int, double>{};
    for (var payment in paymentHistory) {
      final date = (payment['paymentDate'] as Timestamp).toDate();
      final monthKey = date.year * 12 + date.month;
      monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + (payment['amount'] as num).toDouble();
    }
    
    final revenues = monthlyRevenue.values.toList();
    final avgRevenue = revenues.reduce((a, b) => a + b) / revenues.length;
    
    // Simple linear trend
    double trend = 0;
    if (revenues.length >= 2) {
      trend = (revenues.last - revenues.first) / revenues.length;
    }
    
    final prediction = avgRevenue + trend;
    final confidence = revenues.length >= 6 ? 'High' : 'Medium';
    
    String trendDescription;
    if (trend > avgRevenue * 0.05) {
      trendDescription = 'Growing';
    } else if (trend < -avgRevenue * 0.05) {
      trendDescription = 'Declining';
    } else {
      trendDescription = 'Stable';
    }
    
    return {
      'nextMonthPrediction': prediction.toInt(),
      'confidence': confidence,
      'trend': trendDescription,
      'averageMonthly': avgRevenue.toInt(),
    };
  }
}
