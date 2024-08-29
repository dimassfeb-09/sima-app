import 'package:project/models/Organizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/Toast.dart';
import '../helpers/format_report_date.dart';

class Reports {
  int? id;
  String title;
  String description;
  String? status;
  double latitude;
  double longitude;
  int? userId;
  String? address;
  String? createdAt;
  String? imageUrl;
  String type;

  Reports({
    this.id,
    required this.title,
    required this.description,
    this.status,
    required this.latitude,
    required this.longitude,
    this.userId,
    this.address,
    this.createdAt,
    this.imageUrl,
    required this.type,
  });

  // Convert a Reports into a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status ?? 'pending',
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'address': address,
      'image_url': imageUrl,
      'type': type,
    };
  }

  factory Reports.fromMap(Map<String, dynamic> map) {
    return Reports(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Tidak diketahui',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      userId: map['user_id'] ?? '',
      address: map['address'] ?? 'Alamat tidak diketahui',
      imageUrl: map['image_url'] ?? '',
      type: map['type'] ?? '',
      createdAt: formatReportDate(map['created_at']),
    );
  }

  static List<Reports> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => Reports.fromMap(map)).toList();
  }

  Future<int?> insertReport() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('reports').insert(toMap()).select().single();
      return response['id'] as int?;
    } catch (e) {
      ToastUtils.showError("Gagal mengirim laporan $e");
    }

    return null;
  }
}
