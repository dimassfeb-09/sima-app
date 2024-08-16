import 'package:flutter/material.dart';
import 'package:project/services/permissionHandler.dart';

class EmergencyCellularButton extends StatefulWidget {
  final String label;
  final String phoneNumber;
  final Color backgroundColor;
  final Color textColor;

  const EmergencyCellularButton({
    Key? key,
    required this.label,
    required this.phoneNumber,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  _EmergencyCellularButtonState createState() => _EmergencyCellularButtonState();
}

class _EmergencyCellularButtonState extends State<EmergencyCellularButton> {
  final PermissionHandler _permissionHandler = PermissionHandler();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _permissionHandler.makePhoneCallPermission(widget.phoneNumber),
      style: TextButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Text(
        "${widget.label} (${widget.phoneNumber})",
        style: TextStyle(color: widget.textColor),
      ),
    );
  }
}
