import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/marker_builder.dart';
import '../components/landmark_bottom_sheet.dart';
import '../components/error_dialog.dart';
import 'new_entry_page.dart';
import '../components/themed_snack.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  Set<Marker> markers = {};
  List<Landmark> landmarks = [];
  bool isLoading = true;
  bool locating = false;
  BitmapDescriptor? customMarkerIcon;
  BitmapDescriptor? userMarkerIcon;
  Position? userPosition;
  StreamSubscription<Position>? positionSub;

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
    userMarkerIcon = await createUserLocationMarker();
    await reloadLandmarks();
    await _startLocationUpdates();
  }

  Future<void> reloadLandmarks() async {
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
        showThemedSnack(context, 'Error: $e', type: SnackType.error);
      }
    }
  }

  void _createMarkers() {
    final newMarkers = <Marker>{};
    for (final landmark in landmarks) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(landmark.id.toString()),
          position: LatLng(landmark.lat, landmark.lon),
          icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => _showLandmarkSheet(landmark),
        ),
      );
    }
    if (userPosition != null) {
      newMarkers.add(_buildUserMarker(userPosition!));
    }
    markers = newMarkers;
  }

  void _showLandmarkSheet(Landmark landmark) {
    showModalBottomSheet(
      context: context,
      builder: (context) => LandmarkBottomSheet(
        landmark: landmark,
        onEdit: () {
          Navigator.pop(context);
          _openEdit(landmark);
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
      await reloadLandmarks();
      if (mounted) {
        showThemedSnack(
          context,
          'Landmark deleted successfully',
          type: SnackType.success,
          duration: const Duration(seconds: 2),
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
    _mapController = controller;
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.complete(controller);
    }
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: bangladeshCenter, zoom: 7),
      ),
    );
  }

  Future<void> focusOn(Landmark landmark) async {
    final controller = _mapController ?? await _controllerCompleter.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(landmark.lat, landmark.lon), zoom: 14),
      ),
    );
  }

  Future<void> _startLocationUpdates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return;
    }

    positionSub?.cancel();
    positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((pos) {
          setState(() {
            userPosition = pos;
            _createMarkers();
          });
        });
  }

  Future<void> _goToMyLocation() async {
    setState(() => locating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          showThemedSnack(
            context,
            'Location service disabled',
            type: SnackType.warning,
          );
        }
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        if (mounted) {
          showThemedSnack(
            context,
            'Location permission denied',
            type: SnackType.warning,
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      userPosition = pos;
      _createMarkers();
      final controller = _mapController ?? await _controllerCompleter.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 14),
        ),
      );
    } catch (e) {
      if (mounted) {
        showThemedSnack(
          context,
          'Failed to get location: $e',
          type: SnackType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => locating = false);
      }
    }
  }

  Marker _buildUserMarker(Position pos) {
    return Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(pos.latitude, pos.longitude),
      icon:
          userMarkerIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      zIndexInt: 9999,
      anchor: const Offset(0.5, 0.9),
    );
  }

  Future<void> _openEdit(Landmark landmark) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewEntryPage(
          existing: landmark,
          onSaved: (lm) async {
            await reloadLandmarks();
          },
        ),
      ),
    );
    if (result is Landmark) {
      await reloadLandmarks();
    }
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
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: bangladeshCenter,
                    zoom: 7,
                  ),
                  markers: markers,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  style: darkMapStyle,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: locating ? null : _goToMyLocation,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.yellowForeground,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: locating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.yellowForeground,
                                ),
                              )
                            : const Icon(
                                Icons.my_location,
                                color: AppTheme.yellowForeground,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    positionSub?.cancel();
    super.dispose();
  }
}
