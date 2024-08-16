import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/CardItemReport.dart';
import 'package:project/models/HistoryReportModel.dart';
import 'package:project/utils/colors.dart';

class HistoryPage extends StatelessWidget {
  final HistoryReportModel _historyReportModel = HistoryReportModel();
  final RxString _selectedReportType = 'ambulance'.obs;
  final Rx<Future<List<dynamic>?>> _reportFuture = Rx<Future<List<dynamic>?>>(Future.value([]));

  void _loadReports() {
    switch (_selectedReportType.value) {
      case 'police':
        _reportFuture.value = _historyReportModel.getReportPolice();
        break;
      case 'firefighter':
        _reportFuture.value = _historyReportModel.getReportFireFighter();
        break;
      default:
        _reportFuture.value = _historyReportModel.getReportAmbulance();
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadReports();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    _selectedReportType.value = 'ambulance';
                    _loadReports();
                  },
                  child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _selectedReportType.value == 'ambulance' ? blueAccent : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Ambulance',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    _selectedReportType.value = 'police';
                    _loadReports();
                  },
                  child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _selectedReportType.value == 'police' ? blueAccent : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Police',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    _selectedReportType.value = 'firefighter';
                    _loadReports();
                  },
                  child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _selectedReportType.value == 'firefighter' ? blueAccent : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Firefighter',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                return FutureBuilder<List<dynamic>?>(
                  future: _reportFuture.value,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No reports found.'));
                    } else {
                      final reports = snapshot.data!;
                      return ListView.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          print(report.createdAt);
                          DateTime parsedDate = DateTime.parse(report.createdAt);
                          String formattedDate =
                              "${parsedDate.toLocal().toIso8601String().split('T')[0]} ${parsedDate.toLocal().hour.toString().padLeft(2, '0')}:${parsedDate.toLocal().minute.toString().padLeft(2, '0')}";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: CardItemReport(
                              title: report.title,
                              createdAt: formattedDate, // Adjust this if you have actual timestamps
                              location: report.address, // Adjust this if you have actual location
                              status: report.status ?? "Pending",
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
