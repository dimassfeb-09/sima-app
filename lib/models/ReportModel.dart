import 'package:here_sdk/core.dart';

class ReportModel {
  final String title;
  final String description;
  final GeoCoordinates coordinates;
  final String createdAt;
  final String location;
  final String status;
  final String imageUrl;

  const ReportModel({
    required this.title,
    required this.description,
    required this.coordinates,
    required this.createdAt,
    required this.location,
    required this.status,
    required this.imageUrl,
  });
}
