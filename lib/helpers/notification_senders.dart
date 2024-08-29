import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Nearby.dart';

Future<void> sendNotificationInsertData({
  required int reportId,
  required String title,
  required String description,
  required Nearby? nearby,
}) async {
  Supabase supabase = Supabase.instance;

  if (nearby?.organizationId == null) {
    return;
  }

  try {
    final channelId = 'report-${nearby?.organizationId}';
    await supabase.client.channel(channelId).sendBroadcastMessage(
      event: 'new-report',
      payload: {
        'report_id': reportId,
        'title': title,
        'description': description,
      },
    );
  } catch (e) {
    throw Exception('Error sending notification: $e');
  }
}
