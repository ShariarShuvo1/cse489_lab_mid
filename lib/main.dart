import 'package:flutter/material.dart';
import 'pages/map_page.dart';
import 'pages/records_page.dart';
import 'pages/new_entry_page.dart';
import 'theme/app_theme.dart';
import 'models/landmark.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<MapPageState> _mapKey = GlobalKey<MapPageState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MapPage(key: _mapKey),
      RecordsPage(onFocus: _focusOnLandmark),
      NewEntryPage(onSaved: _handleSaved),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildCustomNav(),
    );
  }

  Widget _buildCustomNav() {
    return SafeArea(
      child: Container(
        color: AppTheme.cardBackground,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            _navTab(Icons.public, 'Overview', 0),
            _navTab(Icons.library_books, 'Records', 1),
            _navTab(Icons.add_location_alt, 'New Entry', 2),
          ],
        ),
      ),
    );
  }

  Widget _navTab(IconData icon, String label, int index) {
    final bool selected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = index);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.yellowForeground
                : AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected
                    ? AppTheme.darkBackground
                    : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppTheme.darkBackground
                      : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSaved(Landmark landmark) async {
    await _mapKey.currentState?.reloadLandmarks();
    if (mounted) {
      setState(() => _selectedIndex = 0);
    }
    await Future.delayed(const Duration(milliseconds: 50));
    await _mapKey.currentState?.focusOn(landmark);
  }

  Future<void> _focusOnLandmark(Landmark landmark) async {
    if (mounted) {
      setState(() => _selectedIndex = 0);
    }
    await Future.delayed(const Duration(milliseconds: 50));
    await _mapKey.currentState?.focusOn(landmark);
  }
}
