import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:project/services/user_location.dart';

class HereMapCustom extends StatelessWidget {
  final Rx<GeoCoordinates> geoCoordinates;
  RxBool isLoading = true.obs;
  RxString streetName = ''.obs;
  RxBool isConfirmed = false.obs;

  HereMapCustom({
    Key? key,
    required this.geoCoordinates,
    required this.streetName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Obx(() {
            return Container(
              height: 300,
              child: Stack(
                children: [
                  HereMap(
                    onMapCreated: _onMapCreated,
                  ),
                  isLoading.value ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink()
                ],
              ),
            );
          }),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
          color: Colors.white,
          width: double.infinity,
          child: Row(
            children: [
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lokasi Kejadian",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => geoCoordinates.value.latitude == 0.0 || geoCoordinates.value.longitude == 0.0
                        ? const Text("Loading...")
                        : Text(
                            "${geoCoordinates.value.latitude}, ${geoCoordinates.value.longitude}",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      streetName.value.isEmpty ? "Loading..." : streetName.value,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _onMapCreated(HereMapController? hereMapController) async {
    if (hereMapController == null) {
      debugPrint('Map controller is null');
      isLoading.value = false;
      return;
    }

    hereMapController.mapScene.loadSceneForMapScheme(
      MapScheme.normalDay,
      (MapError? error) async {
        if (error == null) {
          debugPrint('Map loaded successfully');

          UserLocation userLocation = UserLocation();
          Position position = await userLocation.getCurrentLocation();
          geoCoordinates.value = GeoCoordinates(position.latitude, position.longitude);
          _centerMapOnCurrentLocation(hereMapController, geoCoordinates.value);

          MapImage markerImage = MapImage.withFilePathAndWidthAndHeight(
            "assets/image/marker_map.png",
            50,
            50,
          );

          MapMarker marker = MapMarker(geoCoordinates.value, markerImage);
          hereMapController.mapScene.addMapMarker(marker);

          await _reverseGeocode(geoCoordinates.value);

          isLoading.value = false;
        } else {
          debugPrint('Map failed to load: ${error.toString()}');
          isLoading.value = false;
        }
      },
    );
  }

  Future<void> _reverseGeocode(GeoCoordinates coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);

      streetName.value =
          "${placemarks.first.street}, ${placemarks.first.subLocality}\n${placemarks.first.locality}, ${placemarks.first.postalCode}.";
    } catch (e) {
      debugPrint('Failed to reverse geocode: $e');
      streetName.value = "Error fetching address";
    }
  }

  Future<void> _centerMapOnCurrentLocation(HereMapController hereMapController, GeoCoordinates geoCoordinates) async {
    try {
      MapMeasure mapMeasure = MapMeasure(MapMeasureKind.distance, 1000);
      hereMapController.camera.lookAtPointWithMeasure(geoCoordinates, mapMeasure);
    } catch (e) {
      debugPrint('Failed to get current location: $e');
    }
  }
}
