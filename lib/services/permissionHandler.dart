import 'package:permission_handler/permission_handler.dart';
import 'package:project/components/Toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class PermissionHandler {
  Future<void> makePhoneCallPermission(String phoneNumber) async {
    final PermissionStatus permissionStatus = await Permission.phone.request();

    if (permissionStatus.isGranted) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ToastUtils.showError('Could not launch phone dialer.');
      }
    } else if (permissionStatus.isDenied) {
      ToastUtils.showError('Phone permission is required to make calls.');
    } else if (permissionStatus.isPermanentlyDenied) {
      ToastUtils.showError('Please enable phone permission in settings.');
      openAppSettings();
    }
  }

  Future<bool> makeLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ToastUtils.showError('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ToastUtils.showError('Location permission is required to use this feature.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ToastUtils.showError('Please enable location permission in settings.');
      await openAppSettings();
      return false;
    }

    return true;
  }

  Future<bool> makeCameraPermission() async {
    final PermissionStatus permissionStatus = await Permission.camera.request();

    if (permissionStatus.isGranted) {
      return true;
    } else if (permissionStatus.isDenied) {
      ToastUtils.showError('Camera permission is required to use this feature.');
      return false;
    } else if (permissionStatus.isPermanentlyDenied) {
      ToastUtils.showError('Please enable camera permission in settings.');
      await openAppSettings();
      return false;
    }

    return false;
  }
}
