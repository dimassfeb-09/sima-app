import 'package:here_sdk/core.dart';
import 'package:project/models/Organizations.dart';

class ReportModel {
  final int id;
  final String title;
  final String description;
  final GeoCoordinates coordinates;
  final String createdAt;
  final String location;
  final String status;
  final String imageUrl;
  final Organizations? organizations;

  const ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coordinates,
    required this.createdAt,
    required this.location,
    required this.status,
    required this.imageUrl,
    this.organizations,
  });
}
