import 'package:flutter/material.dart';
import 'package:planmate/History/Models/activity_history_model.dart';
import 'package:planmate/History/Provider/history_provider.dart';
import 'package:provider/provider.dart';
import 'package:planmate/provider/auth_provider.dart';
import 'package:planmate/History/Widgets/history_filter_bar.dart';
import 'package:planmate/History/Widgets/history_list_view.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivities();
    });
  }

  void _loadActivities() {
    final authProvider = context.read<AuthProvider>();
    final historyProvider = context.read<HistoryProvider>();
    
    // ✅ เปลี่ยนจาก authProvider.user เป็น authProvider.currentUser
    if (authProvider.currentUser != null) {
      historyProvider.fetchActivities(userId: authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf9f4ef),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf9f4ef),
        elevation: 0,
        title: const Text(
          'ประวัติกิจกรรม',
          style: TextStyle(
            color: Color(0xFF001858),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF001858),
            ),
            onPressed: _loadActivities,
          ),
        ],
      ),
body: Column(
  children: [
    // Filter Bar
      const HistoryFilterBar(),
    
    // Activities List
      Expanded(
        child: Consumer<HistoryProvider>(
          builder: (context, historyProvider, child) {
            if (historyProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8B5CF6),
                ),
              );
            }

            if (historyProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      historyProvider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadActivities,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                      ),
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              );
            }

            final activities = historyProvider.filteredActivities;

            if (activities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      historyProvider.selectedFilter != null || 
                      historyProvider.selectedProjectId != null
                          ? 'ไม่พบกิจกรรมที่ตรงกับตัวกรอง'
                          : 'ยังไม่มีประวัติกิจกรรม',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const HistoryListView();
          },
        ),
      ),
  ],
),
// เพิ่มในหน้า HistoryScreen เพื่อทดสอบ
floatingActionButton: FloatingActionButton(
  onPressed: () async {
    print('🧪 Testing: Creating sample activity');
    
    try {
      final authProvider = context.read<AuthProvider>();
      final historyProvider = context.read<HistoryProvider>();
      
      if (authProvider.currentUser == null) {
        print('❌ No user logged in');
        return;
      }
      
      // สร้าง activity ทดสอบ
      final activity = ActivityHistoryModel.create(
        type: ActivityType.create,
        projectId: 'test_project_123',
        description: 'ทดสอบสร้างกิจกรรม',
        userId: authProvider.currentUser!.uid,
      );
      
      print('🧪 Activity data: ${activity.toMap()}');
      
      await historyProvider.addActivity(activity);
      print('✅ Test activity added successfully');
      
    } catch (e) {
      print('❌ Error adding test activity: $e');
    }
  },
  backgroundColor: Colors.purple,
  child: const Icon(Icons.add),
),
    );
  }
}