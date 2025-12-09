class Landmark {
  final int id;
  final String title;
  final double lat;
  final double lon;
  final String? image;

  Landmark({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    this.image,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    final lat = json['lat'];
    final lon = json['lon'];
    return Landmark(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      lat: lat is num ? lat.toDouble() : double.tryParse(lat.toString()) ?? 0.0,
      lon: lon is num ? lon.toDouble() : double.tryParse(lon.toString()) ?? 0.0,
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'lat': lat,
    'lon': lon,
    'image': image,
  };
}
