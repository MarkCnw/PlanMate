import 'package:flutter/material.dart';
import 'package:planmate/CreateProject/Presentation/createproject_screeen.dart';
import 'package:planmate/History/Presentation/history_screen.dart';
import 'package:planmate/Home/presentation/home.dart';
import 'package:planmate/Navigation/Widgets/buttonappbar.dart';
import 'package:planmate/Navigation/Widgets/customfab.dart';
import 'package:planmate/Profile/Presentation/profile.screen.dart';
import 'package:planmate/Search/Presentation/search_screen.dart';
import 'package:planmate/test.dart';


class CustomBottomNavBarApp extends StatefulWidget {
  const CustomBottomNavBarApp({super.key});

  @override
  State<CustomBottomNavBarApp> createState() =>
      _CustomBottomNavBarAppState();
}

class _CustomBottomNavBarAppState extends State<CustomBottomNavBarApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    // SearchScreen(),
    Test(),
    CreateProjectScreen(),
    Test(),
    // HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: CustomFAB(onPressed: () => _onItemTapped(2)),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: ButtomAppBar(
        selectIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
