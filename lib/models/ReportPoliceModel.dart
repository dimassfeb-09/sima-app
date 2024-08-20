import 'package:project/helpers/format_report_date.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/Toast.dart';

class ReportPoliceModel {
  String title;
  String description;
  String? status;
  double latitude;
  double longitude;
  int userId;
  List<String>? nearby;
  String? address;
  String? createdAt;
  String? imageUrl;

  ReportPoliceModel({
    required this.title,
    required this.description,
    this.status,
    required this.latitude,
    required this.longitude,
    required this.userId,
    this.nearby,
    this.address,
    this.createdAt,
    this.imageUrl,
  });

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
      'image_url': imageUrl,
    };
  }

  factory ReportPoliceModel.fromMap(Map<String, dynamic> map) {
    return ReportPoliceModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Tidak diketahui',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      userId: map['user_id'] ?? '',
      nearby: List<String>.from(map['nearby'] ?? []),
      address: map['address'] ?? 'Alamat tidak diketahui',
      createdAt: formatReportDate(map['created_at']),
      imageUrl: map['image_url'] ?? '',
    );
  }

  static List<ReportPoliceModel> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => ReportPoliceModel.fromMap(map)).toList();
  }

  Future<void> insertReport() async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('report_police').insert(toMap());
    } catch (e) {
      ToastUtils.showError("Gagal mengirim laporan $e");
    }
  }
}
