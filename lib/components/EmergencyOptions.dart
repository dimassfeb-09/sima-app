import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';
import 'package:project/services/permissionHandler.dart';
import 'package:project/views/ReportAmbulancePage.dart';
import 'package:project/views/ReportFireFighterPage.dart';
import 'package:project/views/ReportPolicePage.dart';

class EmergencyOptions extends StatelessWidget {
  PermissionHandler permissionHandler = PermissionHandler();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 169,
      width: double.infinity, // You can use double.infinity for infinite width
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOptionRow(
            iconPath: "assets/icon/protected.svg",
            label: "Laporan ke Polisi",
            buttonLabel: "Pilih",
            onTap: () async {
              bool isPermissionAllowed = await permissionHandler.makeLocationPermission();
              if (isPermissionAllowed) Get.to(() => ReportPolicePage());
            },
          ),
          const Divider(thickness: 0.3),
          _buildOptionRow(
            iconPath: "assets/icon/health.svg",
            label: "Panggil Ambulans",
            buttonLabel: "Pilih",
            onTap: () async {
              bool isPermissionAllowed = await permissionHandler.makeLocationPermission();
              if (isPermissionAllowed) Get.to(() => ReportAmbulancePage());
            },
          ),
          const Divider(thickness: 0.3),
          _buildOptionRow(
            iconPath: "assets/icon/fire.svg",
            label: "Panggil Pemadam Kebakaran",
            buttonLabel: "Pilih",
            onTap: () async {
              bool isPermissionAllowed = await permissionHandler.makeLocationPermission();
              if (isPermissionAllowed) Get.to(() => const ReportFireFighter());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required String iconPath,
    required String label,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(iconPath),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(buttonLabel),
          ),
        ),
      ],
    );
  }
}
