import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:project/components/BadgeStatus.dart';
import 'package:project/components/CardImageView.dart';
import 'package:project/components/HereMap.dart';
import 'package:project/models/ReportModel.dart';
import 'package:get/get.dart'; // Add this if you haven't already

class DetailHistoryReportPage extends StatelessWidget {
  final ReportModel reportModel;

  const DetailHistoryReportPage({
    required this.reportModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Convert coordinates and location into Rx types
    final Rx<GeoCoordinates> geoCoordinates = reportModel.coordinates.obs;
    final RxString streetName = reportModel.location.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail History Report"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: CardImageView(imageUrl: reportModel.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: HereMapCustom(
              geoCoordinates: geoCoordinates,
              streetName: streetName,
              editableStreet: false,
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                BadgeStatus(status: reportModel.status),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Jenis Insiden",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(reportModel.title),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Deskripsi Insiden",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  reportModel.description,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
