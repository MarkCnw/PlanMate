import 'package:flutter/foundation.dart';
import 'package:planmate/Domain/Activity/activity_log.dart';
import 'package:planmate/Domain/usecases/watch_activity_logs.dart';



class ActivityLogProvider extends ChangeNotifier {
  final WatchActivityLogs watch;
  ActivityLogProvider(this.watch) { _sub(); }

  List<ActivityLog> _items = [];
  bool _loading = true; String? _error;
  List<ActivityLog> get items => _items;
  bool get loading => _loading; String? get error => _error;

  void _sub() {
    watch().listen((data){
      _items = data; _loading = false; _error = null; notifyListeners();
    }, onError: (e){
      _loading = false; _error = e.toString(); notifyListeners();
    });
  }
}
