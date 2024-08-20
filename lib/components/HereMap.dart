import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:project/services/user_location.dart';

class HereMapCustom extends StatelessWidget {
  final Rx<GeoCoordinates> geoCoordinates;
  final RxBool isLoading = true.obs;
  final RxString streetName;
  final RxBool isConfirmed = false.obs;
  final bool editableStreet;

  final TextEditingController streetNameController = TextEditingController();

  HereMapCustom({
    Key? key,
    required this.geoCoordinates,
    required this.streetName,
    this.editableStreet = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ever(streetName, (String value) {
      streetNameController.text = value;
    });

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 0.3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                HereMap(
                  onMapCreated: _onMapCreated,
                ),
                if (isLoading.value) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Lokasi Kejadian",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Obx(
                  () => geoCoordinates.value.latitude == 0.0 || geoCoordinates.value.longitude == 0.0
                      ? const Text("Sedang mengambil titik koordinat..")
                      : Text(
                          "${geoCoordinates.value.latitude}, ${geoCoordinates.value.longitude}",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                ),
                const SizedBox(height: 10),
                editableStreet
                    ? Obx(
                        () => Stack(
                          children: [
                            TextField(
                              controller: streetNameController,
                              enabled: isConfirmed.value,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(right: 50, left: 10),
                                border: const OutlineInputBorder(),
                                hintText: streetName.value.isEmpty ? 'Sedang mengambil alamat..' : '',
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: IconButton(
                                icon: Icon(
                                  isConfirmed.value ? Icons.cancel : Icons.edit,
                                ),
                                onPressed: () {
                                  isConfirmed.value = !isConfirmed.value;
                                  if (isConfirmed.value) {
                                    streetNameController.text = streetName.value;
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    : Text(streetName.value),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
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
          "${placemarks.first.street}, ${placemarks.first.subLocality}, ${placemarks.first.locality}, ${placemarks.first.postalCode}.";
    } catch (e) {
      debugPrint('Failed to reverse geocode: $e');
      streetName.value = "Error fetching address";
    }
  }

  Future<void> _centerMapOnCurrentLocation(HereMapController hereMapController, GeoCoordinates geoCoordinates) async {
    try {
      MapMeasure mapMeasure = MapMeasure(MapMeasureKind.distance, 700);
      hereMapController.camera.lookAtPointWithMeasure(geoCoordinates, mapMeasure);
    } catch (e) {
      debugPrint('Failed to get current location: $e');
    }
  }
}
