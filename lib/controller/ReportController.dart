import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/models/Organizations.dart';
import '../components/Toast.dart';

class ReportController extends GetxController {
  final Rx<Organizations?> organization = Rx<Organizations?>(null);

  Future<void> fetchReportAssignments(int reportId) async {
    try {
      final supabase = Supabase.instance.client;

      var response =
          await supabase.from('report_assignments').select("organization_id").eq('report_id', reportId).single();
      final organizationId = response['organization_id'];

      response = await supabase.from('organizations').select("*").eq('id', organizationId).single();
      final data = response as Map<String, dynamic>?; // Ensure data is properly cast
      if (data != null) {
        organization.value = Organizations.fromMap(data);
      } else {
        ToastUtils.showError('No data found for the provided report ID.');
      }
    } catch (e) {
      // Handle the error, e.g., show a toast message
      ToastUtils.showError('Error fetching report assignments: ${e.toString()}');
    }
  }
}
