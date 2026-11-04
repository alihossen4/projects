import 'package:google_maps_flutter/google_maps_flutter.dart';

class Landmark {
  const Landmark({
    required this.id,
    required this.name,
    required this.position,
    required this.fact,
  });

  final String id;
  final String name;
  final LatLng position;
  final String fact;
}

class Places {
  static const Landmark parliament = Landmark(
    id: "parliament",
    name: "National Parliament",
    position: LatLng(23.2625, 90.3783),
    fact: "Jatiya Sangsad Bhaban",
  );
  static const Landmark shahidMinar = Landmark(
    id: "shahid_minar",
    name: "Shahid Minar",
    position: LatLng(23.7271, 90.3967),
    fact: "Remembers The Language Movement",
  );

  static const List<Landmark> all = [parliament, shahidMinar];

  static const CameraPosition openingCamera = CameraPosition(
    target: LatLng(23.740, 90.400),
    zoom: 12,
  );
}
