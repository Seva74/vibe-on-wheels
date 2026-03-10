class LocationModel {
  final String address;
  final double lat;
  final double lng;

  const LocationModel({
    required this.address,
    required this.lat,
    required this.lng,
  });

  double getDistanceTo(LocationModel other) {
    final dlat = lat - other.lat;
    final dlng = lng - other.lng;
    return ((dlat * dlat + dlng * dlng) * 111).abs();
  }
}
