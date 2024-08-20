import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/models/ReportModel.dart';
import 'package:project/views/DetailHistoryReportPage.dart';

import '../helpers/capitalize_each_word.dart';
import 'BadgeStatus.dart';

class CardItemReport extends StatelessWidget {
  final ReportModel reportModel;

  const CardItemReport({
    super.key,
    required this.reportModel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => DetailHistoryReportPage(reportModel: reportModel)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizeEachWord(reportModel.title),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                Text(
                  reportModel.createdAt,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              reportModel.location,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            Text(
              "${reportModel.coordinates.latitude}, ${reportModel.coordinates.longitude}",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            BadgeStatus(status: reportModel.status),
          ],
        ),
      ),
    );
  }
}
