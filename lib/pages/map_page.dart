import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/marker_builder.dart';
import '../components/landmark_bottom_sheet.dart';
import '../components/error_dialog.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  List<Landmark> landmarks = [];
  bool isLoading = true;
  Landmark? selectedLandmark;
  BitmapDescriptor? customMarkerIcon;

  final LatLng bangladeshCenter = const LatLng(23.6850, 90.3563);

  // Took help from AI to create custom dark map style with theme colors
  static const String darkMapStyle = '''[
      {
        "elementType": "geometry",
        "stylers": [{"color": "#212121"}]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#757575"}]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [{"color": "#212121"}]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [{"color": "#ffd700"}, {"weight": 1.5}]
      },
      {
        "featureType": "administrative",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#ffd700"}]
      },
      {
        "featureType": "administrative.country",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#ffd700"}]
      },
      {
        "featureType": "administrative.province",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#d4a500"}]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [{"color": "#17263c"}]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#515c6d"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [{"color": "#38414e"}]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#9ca5af"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [{"color": "#4a5568"}]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#757575"}]
      },
      {
        "featureType": "transit",
        "elementType": "geometry",
        "stylers": [{"color": "#38414e"}]
      }
    ]''';

  @override
  void initState() {
    super.initState();
    _initializeMarkerIcon();
  }

  Future<void> _initializeMarkerIcon() async {
    customMarkerIcon = await createCustomMarker();
    await _loadLandmarks();
  }

  Future<void> _loadLandmarks() async {
    try {
      final loadedLandmarks = await ApiService.fetchLandmarks();
      setState(() {
        landmarks = loadedLandmarks;
        _createMarkers();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppTheme.yellowForeground,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: AppTheme.cardBackground,
            margin: const EdgeInsets.all(12),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(
                color: AppTheme.yellowForeground,
                width: 1.5,
              ),
            ),
          ),
        );
      }
    }
  }

  void _createMarkers() {
    markers.clear();
    for (final landmark in landmarks) {
      markers.add(
        Marker(
          markerId: MarkerId(landmark.id.toString()),
          position: LatLng(landmark.lat, landmark.lon),
          icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => _showLandmarkSheet(landmark),
        ),
      );
    }
  }

  void _showLandmarkSheet(Landmark landmark) {
    showModalBottomSheet(
      context: context,
      builder: (context) => LandmarkBottomSheet(
        landmark: landmark,
        onEdit: () {
          Navigator.pop(context);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteLandmark(landmark.id);
        },
      ),
    );
  }

  Future<void> _deleteLandmark(int id) async {
    try {
      await ApiService.deleteLandmark(id);
      await _loadLandmarks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.yellowForeground,
                ),
                SizedBox(width: 12),
                Expanded(child: Text('Landmark deleted successfully')),
              ],
            ),
            backgroundColor: AppTheme.cardBackground,
            margin: EdgeInsets.all(12),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            message: 'Failed to delete: $e',
            onConfirm: () => Navigator.pop(context),
          ),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmarks Map'),
        titleTextStyle: const TextStyle(
          color: AppTheme.yellowForeground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.yellowForeground,
              ),
            )
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: bangladeshCenter,
                zoom: 7,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              style: darkMapStyle,
            ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
