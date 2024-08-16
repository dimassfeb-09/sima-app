import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/Toast.dart';

class ReportAmbulanceModel {
  String title;
  String description;
  String? status;
  double latitude;
  double longitude;
  int? userId;
  List<String>? nearby;
  String? address;
  String? createdAt;

  ReportAmbulanceModel({
    required this.title,
    required this.description,
    this.status,
    required this.latitude,
    required this.longitude,
    this.userId,
    this.nearby,
    this.address,
    this.createdAt,
  });

  // Convert a ReportAmbulanceModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status ?? 'pending',
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'nearby': nearby,
      'address': address,
    };
  }

  factory ReportAmbulanceModel.fromMap(Map<String, dynamic> map) {
    return ReportAmbulanceModel(
      title: map['title'],
      description: map['description'],
      status: map['status'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      userId: map['user_id'],
      nearby: List<String>.from(map['nearby'] ?? []),
      address: map['address'] ?? '',
      createdAt: map['created_at'],
    );
  }

  static List<ReportAmbulanceModel> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => ReportAmbulanceModel.fromMap(map)).toList();
  }

  Future<void> insertReport() async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('report_ambulance').insert(toMap());
    } catch (e) {
      ToastUtils.showError("Gagal mengirim laporan $e");
    }
  }
}
