import 'package:flutter/material.dart';
import 'package:planmate/CreateProject/Presentation/createproject_screeen.dart';
import 'package:planmate/History/Presentation/history_screen.dart';
import 'package:planmate/Home/presentation/home.dart';
import 'package:planmate/Navigation/Widgets/buttonappbar.dart';
import 'package:planmate/Navigation/Widgets/customfab.dart';
import 'package:planmate/Profile/Presentation/profile.screen.dart';
import 'package:planmate/Search/Presentation/search_screen.dart';



class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() =>
      _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    CreateProjectScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: ButtomAppBar(
        selectIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
