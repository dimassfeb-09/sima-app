import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/Reports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'User.dart' as usr;

class HistoryReportModel {
  String uid = "";
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  HistoryReportModel() {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    uid = firebaseAuth.currentUser!.uid;
  }

  Future<List<Reports>?> getReport(String type) async {
    try {
      usr.User user = usr.User();
      int? userId = await user.getUserIdByUID(uid);
      if (userId == null) return null;
      final response = await _supabaseClient
          .from("reports")
          .select("*")
          .eq('user_id', userId)
          .eq("type", type)
          .order('id', ascending: false);

      List<Reports> reports = Reports.fromList(response);
      print(reports[0]);
      return reports;
    } catch (e) {
      print('Error fetching report police: $e');
      return [];
    }
  }
}
