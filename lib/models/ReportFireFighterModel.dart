import 'package:project/components/Toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/format_report_date.dart';

class ReportFireFighterModel {
  final String title;
  final String description;
  final String? status;
  final double latitude;
  final double longitude;
  final int userId;
  final List<String>? nearby;
  final String? imageUrl;
  final String? address;
  final String? createdAt;

  ReportFireFighterModel({
    required this.title,
    required this.description,
    this.status = 'pending',
    required this.latitude,
    required this.longitude,
    required this.userId,
    this.nearby,
    required this.imageUrl,
    this.address,
    this.createdAt,
  });

  /// Converts the ReportFireFighterModel instance into a Map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status ?? 'pending',
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'nearby': nearby,
      'image_url': imageUrl,
      'address': address,
    };
  }

  factory ReportFireFighterModel.fromMap(Map<String, dynamic> map) {
    return ReportFireFighterModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Tidak diketahui',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      userId: map['user_id'] ?? '',
      nearby: List<String>.from(map['nearby'] ?? []),
      address: map['address'] ?? 'Alamat tidak diketahui',
      imageUrl: map['image_url'] ?? '',
      createdAt: formatReportDate(map['created_at']),
    );
  }

  static List<ReportFireFighterModel> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => ReportFireFighterModel.fromMap(map)).toList();
  }

  Future<void> insertReport() async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('report_firefighter').insert(toMap());
    } catch (e) {
      ToastUtils.showError("Gagal mengirim laporan $e");
    }
  }
}
