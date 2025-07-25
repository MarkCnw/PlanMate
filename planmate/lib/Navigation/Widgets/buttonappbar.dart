import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planmate/Navigation/Widgets/buidnavitem.dart';

class ButtomAppBar extends StatelessWidget {
  final int selectIndex;
  final Function(int) onItemTapped;

  const ButtomAppBar({
    super.key,
    required this.selectIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 10,
      color: Colors.white,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItemWidget(
              icon: FontAwesomeIcons.house,
              label: 'Home',
              isSelected: selectIndex == 0,
              onTap: () => onItemTapped(0),
            ),
            NavItemWidget(
              icon: FontAwesomeIcons.magnifyingGlass,
              label: 'Search',
              isSelected: selectIndex == 1,
              onTap: () => onItemTapped(1),
            ),
            const SizedBox(width: 40), // ช่องเว้นกลาง (สำหรับ FAB)
            NavItemWidget(
              icon: FontAwesomeIcons.clockRotateLeft,
              label: 'History',
              isSelected: selectIndex == 3,
              onTap: () => onItemTapped(3),
            ),
            NavItemWidget(
              icon: FontAwesomeIcons.user,
              label: 'Profile',
              isSelected: selectIndex == 4,
              onTap: () => onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}
