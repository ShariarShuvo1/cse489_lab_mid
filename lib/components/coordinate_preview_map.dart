import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';

class CoordinatePreviewMap extends StatefulWidget {
  final LatLng defaultCenter;
  final LatLng? coordinate;
  final BitmapDescriptor? markerIcon;
  final VoidCallback? onLocatePressed;
  final ValueChanged<LatLng>? onTap;
  final bool isLocating;

  const CoordinatePreviewMap({
    super.key,
    required this.defaultCenter,
    required this.coordinate,
    required this.markerIcon,
    this.onLocatePressed,
    this.onTap,
    this.isLocating = false,
  });

  @override
  State<CoordinatePreviewMap> createState() => _CoordinatePreviewMapState();
}

class _CoordinatePreviewMapState extends State<CoordinatePreviewMap> {
  GoogleMapController? controller;
  final Completer<GoogleMapController> _controllerCompleter = Completer();

  // Took help from AI to create custom dark map style with theme colors
  static const String _darkMapStyle = '''[
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
  void didUpdateWidget(CoordinatePreviewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coordinate != oldWidget.coordinate &&
        widget.coordinate != null) {
      _animateTo(widget.coordinate!);
    }
  }

  Future<void> _animateTo(LatLng target) async {
    final map = controller ?? await _controllerCompleter.future;
    await map.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initial = widget.coordinate ?? widget.defaultCenter;
    final markerIcon = widget.markerIcon;
    final Set<Marker> markers = {};
    if (widget.coordinate != null && markerIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('preview_marker'),
          position: widget.coordinate!,
          icon: markerIcon,
        ),
      );
    }
    // Taken help from AI to design the map preview container
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.yellowForeground, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 180,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initial,
                  zoom: 11,
                ),
                style: _darkMapStyle,
                onMapCreated: (ctrl) async {
                  controller = ctrl;
                  _controllerCompleter.complete(ctrl);
                },
                onTap: (pos) {
                  if (widget.onTap != null) widget.onTap!(pos);
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                buildingsEnabled: false,
                trafficEnabled: false,
                indoorViewEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                markers: markers,
              ),
              if (widget.onLocatePressed != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.isLocating ? null : widget.onLocatePressed,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.yellowForeground,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: widget.isLocating
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
        ),
      ),
    );
  }
}
