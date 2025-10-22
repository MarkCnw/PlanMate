import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planmate/History/Models/activity_history_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class HistoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ActivityHistoryModel> _activities = [];
  bool _isLoading = false;
  String? _error;
  ActivityType? _selectedFilter;
  String? _selectedProjectId;

  // Getters
  // Removed duplicate filteredActivities getter with debug logs to resolve name conflict.
  bool get isLoading => _isLoading;
  String? get error => _error;
  ActivityType? get selectedFilter => _selectedFilter;
  String? get selectedProjectId => _selectedProjectId;

  // Filtered activities
  List<ActivityHistoryModel> get filteredActivities {
    List<ActivityHistoryModel> filtered = _activities;

    // Filter by activity type
    if (_selectedFilter != null) {
      filtered =
          filtered
              .where((activity) => activity.type == _selectedFilter)
              .toList();
    }

    // Filter by project
    if (_selectedProjectId != null && _selectedProjectId!.isNotEmpty) {
      filtered =
          filtered
              .where(
                (activity) => activity.projectId == _selectedProjectId,
              )
              .toList();
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  // Fetch activities from Firestore
  // ใน history_provider.dart - เพิ่ม debug logging

  Future<void> fetchActivities({String? userId}) async {
    try {
      _setLoading(true);
      _error = null;

      print('🔍 DEBUG: Starting fetchActivities');
      print('🔍 DEBUG: userId = $userId');
      print(
        '🔍 DEBUG: currentUser = ${FirebaseAuth.instance.currentUser?.uid}',
      );

      Query query = _firestore.collection('activities');

      // ✅ where ต้องมาก่อน orderBy
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
        print('🔍 DEBUG: Added where clause for userId');
      }

      // ❌ ลบ orderBy ออกชั่วคราวเพื่อหลีกเลี่ยงปัญหา index
      query = query.orderBy('timestamp', descending: true).limit(100);
      query = query.limit(100);

      print('🔍 DEBUG: Executing query...');
      final QuerySnapshot snapshot = await query.get();
      print('🔍 DEBUG: Query completed');
      print('🔍 DEBUG: Found ${snapshot.docs.length} documents');

      // Debug: แสดงข้อมูลแต่ละ document
      for (var doc in snapshot.docs) {
        print('🔍 DEBUG: Document ${doc.id}: ${doc.data()}');
      }

      _activities =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print('🔍 DEBUG: Parsing document: $data');
            return ActivityHistoryModel.fromMap(data);
          }).toList();

      // เรียงลำดับใน Dart
      _activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      print(
        '🔍 DEBUG: Successfully loaded ${_activities.length} activities',
      );
      _setLoading(false);
    } catch (e) {
      print('❌ DEBUG: Error in fetchActivities: $e');
      _error = 'เกิดข้อผิดพลาดในการโหลดประวัติ: $e';
      _setLoading(false);
    }
  }

  // Add new activity
  Future<void> addActivity(
    ActivityHistoryModel activity, {
    String? userId,
  }) async {
    try {
      final data = activity.toMap();

      await _firestore.collection('activities').doc(activity.id).set(data);

      // Add to local list and sort
      _activities.insert(0, activity);
      _activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการบันทึกประวัติ: $e';
      notifyListeners();
    }
  }

  // Set filter
  void setFilter(ActivityType? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Set project filter
  void setProjectFilter(String? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  // Clear all filters
  // void clearFilters() {
  //   _selectedFilter = null;
  //   _selectedProjectId = null;
  //   notifyListeners();
  // }

  // Refresh activities
  Future<void> refreshActivities({String? userId}) async {
    await fetchActivities(userId: userId);
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper method to create and add activity
  static Future<void> logActivity({
    required BuildContext context,
    required ActivityType type,
    required String projectId,
    String? taskId,
    required String description,
    Map<String, dynamic>? metadata,
    String? userId,
  }) async {
    final historyProvider = context.read<HistoryProvider>();

    final activity = ActivityHistoryModel.create(
      type: type,
      projectId: projectId,
      taskId: taskId,
      description: description,
      metadata: metadata,
      userId: userId, // ✅ ส่ง userId
    );

    await historyProvider.addActivity(activity);
  }
}
