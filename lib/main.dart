import 'package:flutter/material.dart';
import 'pages/map_page.dart';
import 'pages/records_page.dart';
import 'pages/new_entry_page.dart';
import 'theme/app_theme.dart';

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
      const RecordsPage(),
      NewEntryPage(onSaved: _handleSaved),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Overview'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt),
            label: 'New Entry',
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaved() async {
    await _mapKey.currentState?.reloadLandmarks();
    if (mounted) {
      setState(() => _selectedIndex = 0);
    }
  }
}
