import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/ReportPoliceModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ReportAmbulanceModel.dart';
import 'ReportFireFighterModel.dart';
import 'User.dart' as usr;

class HistoryReportModel {
  String uid = "";
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  HistoryReportModel() {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    uid = firebaseAuth.currentUser!.uid;
  }

  Future<List<ReportPoliceModel>?> getReportPolice() async {
    try {
      usr.User user = usr.User();
      int? userId = await user.getUserIdByUID(uid);
      if (userId == null) return null;
      final response =
          await _supabaseClient.from("report_police").select().eq('user_id', userId).order('id', ascending: false);
      List<ReportPoliceModel> reportPoliceModel = ReportPoliceModel.fromList(response);
      return reportPoliceModel;
    } catch (e) {
      print('Error fetching report police: $e');
      return [];
    }
  }

  Future<List<ReportAmbulanceModel>?> getReportAmbulance() async {
    try {
      usr.User user = usr.User();
      int? userId = await user.getUserIdByUID(uid);
      if (userId == null) return null;
      final response = await _supabaseClient.from("report_ambulance").select().eq('user_id', userId).order(
            'id',
            ascending: false,
          );

      List<ReportAmbulanceModel> reportAmbulanceModel = ReportAmbulanceModel.fromList(response);
      return reportAmbulanceModel;
    } catch (e) {
      print('Error fetching report Ambulance: $e');
      return [];
    }
  }

  Future<List<ReportFireFighterModel>?> getReportFireFighter() async {
    try {
      usr.User user = usr.User();
      int? userId = await user.getUserIdByUID(uid);
      if (userId == null) return null;
      final response = await _supabaseClient.from("report_firefighter").select().eq('user_id', userId).order(
            'id',
            ascending: false,
          );

      List<ReportFireFighterModel> reportFireFighterModel = ReportFireFighterModel.fromList(response);
      return reportFireFighterModel;
    } catch (e) {
      print('Error fetching report FireFighter: $e');
      return [];
    }
  }
}
