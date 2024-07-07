import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

void showLocationPickerModal(
    BuildContext context, TextEditingController controller) async {
  try {
    List<Location> locations = await locationFromAddress(controller.text);
    var lat = locations[0].latitude;
    var lon = locations[0].longitude;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(lat, lon),
              initialZoom: 17.0,
              onTap: (tapPosition, point) {
                controller.text = '${point.latitude}, ${point.longitude}';
                Navigator.pop(context);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 150.0,
                    height: 150.0,
                    point: LatLng(lat, lon),
                    child: const Icon(
                      Icons.location_pin,
                      color: Color.fromARGB(255, 226, 17, 2),
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors',
                      onTap: () => null),
                ],
              )
            ],
          ),
        );
      },
    );
  } catch (e) {
    print('Error: $e');
  }
}
