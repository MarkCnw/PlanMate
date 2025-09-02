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
  List<ActivityHistoryModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ActivityType? get selectedFilter => _selectedFilter;
  String? get selectedProjectId => _selectedProjectId;
  
  // Filtered activities
  List<ActivityHistoryModel> get filteredActivities {
    List<ActivityHistoryModel> filtered = _activities;
    
    // Filter by activity type
    if (_selectedFilter != null) {
      filtered = filtered.where((activity) => activity.type == _selectedFilter).toList();
    }
    
    // Filter by project
    if (_selectedProjectId != null && _selectedProjectId!.isNotEmpty) {
      filtered = filtered.where((activity) => activity.projectId == _selectedProjectId).toList();
    }
    
    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return filtered;
  }
  
  // Fetch activities from Firestore
  Future<void> fetchActivities({String? userId}) async {
    try {
      _setLoading(true);
      _error = null;
      
      Query query = _firestore
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .limit(100); // Limit for performance
      
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId); // ✅ เปลี่ยนจาก 'userid' เป็น 'userId'
      }
      
      final QuerySnapshot snapshot = await query.get();
      
      _activities = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ActivityHistoryModel.fromMap(data);
      }).toList();
      
      _setLoading(false);
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการโหลดประวัติ: $e';
      _setLoading(false);
    }
  }
  
  // Add new activity
  Future<void> addActivity(ActivityHistoryModel activity, {String? userId}) async {
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
  void clearFilters() {
    _selectedFilter = null;
    _selectedProjectId = null;
    notifyListeners();
  }
  
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