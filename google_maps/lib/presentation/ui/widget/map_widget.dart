import 'package:flutter/material.dart';
import 'package:google_maps_app/presentation/ui/components/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  const new({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const Expanded(child: ColoredBox(color: Color(0xFFF2F5F7))),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: Places.openingCamera,
                markers: {
                  Marker(
                    markerId: MarkerId("marker"),
                    position: Places.all.first.position,
                    infoWindow: InfoWindow(title: Places.all.first.name),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
