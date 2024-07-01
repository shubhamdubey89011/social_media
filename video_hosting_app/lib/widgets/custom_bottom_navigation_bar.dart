import 'package:flutter/material.dart';
import 'package:corp_tale/constants/color_const.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: ColorConstants.blue1,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: '',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.amber[800],
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
    );
  }
}
