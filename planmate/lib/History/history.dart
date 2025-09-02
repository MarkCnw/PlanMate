



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planmate/Domain/Activity/activity_type.dart';
import 'package:planmate/provider/activity_log_provider.dart';
import 'package:provider/provider.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityLogProvider>(
      builder: (context, p, _) {
        if (p.loading) return const Center(child: CircularProgressIndicator());
        if (p.error != null) return Center(child: Text(p.error!));
        if (p.items.isEmpty) return const Center(child: Text('No history yet'));
        return ListView.builder(
          itemCount: p.items.length,
          itemBuilder: (c, i) {
            final x = p.items[i];
            final icon = switch (x.type) {
              ActivityType.taskCompleted => Icons.check_circle,
              ActivityType.taskCreated  => Icons.add_circle,
              ActivityType.taskDeleted  => Icons.delete,
              ActivityType.projectCreated => Icons.folder_open,
              ActivityType.projectUpdated => Icons.edit,
              ActivityType.projectDeleted => Icons.delete_forever,
            };
            return ListTile(
              leading: Icon(icon, color: Colors.deepPurple),
              title: Text(x.title),
              subtitle: Text('${x.type.name} • ${DateFormat('dd MMM yyyy, HH:mm').format(x.timestamp)}'),
            );
          },
        );
      },
    );
  }
}
