import 'dart:async';
import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'new_entry_page.dart';

class RecordsPage extends StatefulWidget {
  final Future<void> Function(Landmark landmark)? onFocus;

  const RecordsPage({super.key, this.onFocus});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  List<Landmark> landmarks = [];
  bool isLoading = true;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadLandmarks();
  }

  Future<void> _loadLandmarks() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.fetchLandmarks();
      if (mounted) {
        setState(() {
          landmarks = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnack('Failed to load records: $e');
      }
    }
  }

  Future<void> _refresh() async {
    setState(() => isRefreshing = true);
    await _loadLandmarks();
    if (mounted) setState(() => isRefreshing = false);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.yellowForeground),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.cardBackground,
        margin: const EdgeInsets.all(12),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppTheme.yellowForeground, width: 1.5),
        ),
      ),
    );
  }

  Future<void> _delete(int id) async {
    try {
      await ApiService.deleteLandmark(id);
      await _loadLandmarks();
      if (mounted) {
        _showSnack('Deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Delete failed: $e');
      }
    }
  }

  Future<void> _edit(Landmark landmark) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewEntryPage(
          existing: landmark,
          onSaved: (lm) async {
            await _loadLandmarks();
          },
        ),
      ),
    );
    if (result is Landmark) {
      await _loadLandmarks();
    }
  }

  Widget _buildCard(Landmark landmark) {
    final subtitle =
        '${landmark.lat.toStringAsFixed(4)}, ${landmark.lon.toStringAsFixed(4)}';
    final imageUrl = landmark.image != null && landmark.image!.isNotEmpty
        ? 'https://labs.anontech.info/cse489/t3/${landmark.image}'
        : null;

    return Card(
      color: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.yellowForeground, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 80,
            height: 56,
            color: Colors.black,
            child: imageUrl == null
                ? const Icon(Icons.photo, color: AppTheme.textSecondary)
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: AppTheme.textSecondary,
                    ),
                  ),
          ),
        ),
        title: Text(
          landmark.title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.yellowForeground,
        ),
        onTap: () async {
          if (widget.onFocus != null) {
            await widget.onFocus!(landmark);
          }
        },
      ),
    );
  }

  Widget _buildList() {
    if (landmarks.isEmpty) {
      return const Center(
        child: Text(
          'No records yet',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.yellowForeground,
      backgroundColor: AppTheme.cardBackground,
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: landmarks.length,
        itemBuilder: (context, index) {
          final item = landmarks[index];
          return Dismissible(
            key: ValueKey(item.id),
            background: _buildSwipeBackground(
              alignment: Alignment.centerLeft,
              icon: Icons.edit,
              label: 'Edit',
              color: AppTheme.successGreen,
            ),
            secondaryBackground: _buildSwipeBackground(
              alignment: Alignment.centerRight,
              icon: Icons.delete_outline,
              label: 'Delete',
              color: AppTheme.errorRed,
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _edit(item);
                return false;
              } else {
                await _delete(item.id);
                return true;
              }
            },
            child: _buildCard(item),
          );
        },
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withAlpha((0.14 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
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
          : _buildList(),
    );
  }
}
