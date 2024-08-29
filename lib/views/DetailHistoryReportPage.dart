import 'package:flutter/material.dart';
import 'package:project/components/BadgeStatus.dart';
import 'package:project/components/CardImageView.dart';
import 'package:project/components/HereMap.dart';
import 'package:project/models/ReportModel.dart';
import 'package:get/get.dart';

import '../controller/ReportController.dart';

class DetailHistoryReportPage extends StatelessWidget {
  final ReportModel reportModel;
  final ReportController reportController = Get.put(ReportController());

  DetailHistoryReportPage({
    required this.reportModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    reportController.fetchReportAssignments(reportModel.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail History Report"),
      ),
      body: Obx(() {
        final organizations = reportController.organization.value;

        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: HereMapCustom(
                geoCoordinates: reportModel.coordinates.obs,
                streetName: reportModel.location.obs,
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ditangani",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(organizations?.name ?? 'Sedang mengambil data...')
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Unit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(organizations?.instanceType.capitalizeFirst ?? 'Sedang mengambil data...')
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
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
                    "Gambar Kejadian",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CardImageView(imageUrl: reportModel.imageUrl),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }
}
