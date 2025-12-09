import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../components/themed_snack.dart';
import '../components/error_dialog.dart';
import '../components/coordinate_preview_map.dart';
import '../utils/marker_builder.dart';

class NewEntryPage extends StatefulWidget {
  final Landmark? existing;
  final Future<void> Function(Landmark landmark)? onSaved;

  const NewEntryPage({super.key, this.existing, this.onSaved});

  bool get isEditing => existing != null;

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final titleController = TextEditingController();
  final latController = TextEditingController();
  final lonController = TextEditingController();
  File? imageFile;
  bool locating = false;
  bool submitting = false;
  LatLng? previewLatLng;
  BitmapDescriptor? previewMarkerIcon;
  final LatLng _defaultCenter = const LatLng(23.6850, 90.3563);

  @override
  void initState() {
    super.initState();
    latController.addListener(_onLatLonChanged);
    lonController.addListener(_onLatLonChanged);
    _loadPreviewMarker();
    if (widget.isEditing) {
      final landmark = widget.existing!;
      titleController.text = landmark.title;
      latController.text = landmark.lat.toString();
      lonController.text = landmark.lon.toString();
      _onLatLonChanged();
    } else {
      _prefillLocation();
    }
  }

  @override
  void dispose() {
    latController.removeListener(_onLatLonChanged);
    lonController.removeListener(_onLatLonChanged);
    titleController.dispose();
    latController.dispose();
    lonController.dispose();
    super.dispose();
  }

  Future<void> _loadPreviewMarker() async {
    final icon = await createPreviewMarker();
    if (mounted) {
      setState(() {
        previewMarkerIcon = icon;
      });
    }
  }

  // Took help form AI to implement location detection and prefill
  Future<void> _prefillLocation() async {
    setState(() => locating = true);
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        _showError('Location permission denied');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      latController.text = position.latitude.toStringAsFixed(6);
      lonController.text = position.longitude.toStringAsFixed(6);
      _onLatLonChanged();
    } catch (e) {
      _showError('Unable to detect location: $e');
    } finally {
      if (mounted) {
        setState(() => locating = false);
      }
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  void _onLatLonChanged() {
    final lat = double.tryParse(latController.text.trim());
    final lon = double.tryParse(lonController.text.trim());
    if (lat != null && lon != null) {
      setState(() {
        previewLatLng = LatLng(lat, lon);
      });
    } else {
      if (previewLatLng != null) {
        setState(() {
          previewLatLng = null;
        });
      }
    }
  }

  Future<void> _submit() async {
    final title = titleController.text.trim();
    final lat = double.tryParse(latController.text.trim());
    final lon = double.tryParse(lonController.text.trim());

    if (title.isEmpty || lat == null || lon == null) {
      _showSnack(
        'Please fill all fields with valid values',
        type: SnackType.warning,
      );
      return;
    }

    setState(() => submitting = true);
    try {
      late final Landmark resultLandmark;
      if (widget.isEditing) {
        await ApiService.updateLandmark(
          id: widget.existing!.id,
          title: title,
          lat: lat,
          lon: lon,
        );
        resultLandmark = Landmark(
          id: widget.existing!.id,
          title: title,
          lat: lat,
          lon: lon,
          image: widget.existing!.image,
        );
      } else {
        final newId = await ApiService.createLandmark(
          title: title,
          lat: lat,
          lon: lon,
          imageFile: imageFile,
        );
        resultLandmark = Landmark(
          id: newId,
          title: title,
          lat: lat,
          lon: lon,
          image: null,
        );
      }

      if (widget.onSaved != null) {
        await widget.onSaved!(resultLandmark);
      }

      if (!mounted) return;

      _showSnack(
        widget.isEditing
            ? 'Landmark updated successfully'
            : 'Landmark added successfully',
        type: SnackType.success,
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context, resultLandmark);
      } else if (!widget.isEditing) {
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            message: e.toString(),
            onConfirm: () => Navigator.pop(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  void _resetForm() {
    titleController.clear();
    latController.clear();
    lonController.clear();
    setState(() => imageFile = null);
    _prefillLocation();
  }

  void _showSnack(String message, {SnackType type = SnackType.info}) {
    showThemedSnack(context, message, type: type);
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        message: message,
        onConfirm: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;
    final headerText = isEditing
        ? 'Editing existing landmark'
        : 'Add a new landmark';
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Landmark' : 'New Entry'),
        titleTextStyle: const TextStyle(
          color: AppTheme.yellowForeground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headerText,
              style: const TextStyle(
                color: AppTheme.yellowForeground,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CoordinatePreviewMap(
              defaultCenter: _defaultCenter,
              coordinate: previewLatLng,
              markerIcon: previewMarkerIcon,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: titleController,
              label: 'Title',
              icon: Icons.title,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: latController,
                    label: 'Latitude',
                    icon: Icons.north,
                    keyboardType: TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: lonController,
                    label: 'Longitude',
                    icon: Icons.east,
                    keyboardType: TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isEditing) _buildLockedImageSection() else _buildImagePicker(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: submitting ? null : _submit,
                icon: submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.darkBackground,
                        ),
                      )
                    : Icon(isEditing ? Icons.save : Icons.add_location_alt),
                label: Text(isEditing ? 'Update Landmark' : 'Create Landmark'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yellowForeground,
                  foregroundColor: AppTheme.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.yellowForeground, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppTheme.yellowForeground),
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo (optional)',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.yellowForeground, width: 1.5),
            ),
            child: imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_a_photo,
                        color: AppTheme.textSecondary,
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to select an image',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(imageFile!, fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedImageSection() {
    final imageUrl = widget.existing?.image;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.yellowForeground, width: 1.5),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'https://labs.anontech.info/cse489/t3/$imageUrl',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppTheme.textSecondary,
                          size: 48,
                        ),
                      );
                    },
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.image,
                    color: AppTheme.textSecondary,
                    size: 48,
                  ),
                ),
        ),
      ],
    );
  }
}
