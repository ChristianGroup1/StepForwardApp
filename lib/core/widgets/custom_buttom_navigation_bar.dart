import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stepforward/core/entities/buttom_navigation_bar_entity.dart';
import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';
import 'package:stepforward/core/widgets/buttom_navigation_bar_item.dart';

class CustomButtonNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  const CustomButtonNavigationBar({
    super.key,
    this.selectedIndex = 0,
    required this.onItemTapped,
  });

  @override
  State<CustomButtonNavigationBar> createState() =>
      _CustomButtonNavigationBarState();
}

class _CustomButtonNavigationBarState extends State<CustomButtonNavigationBar> {
  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      height: isDeviceInPortrait(context) ? 60.h : 50.h,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff21406c),
            Color(0xff24282F), // Purple
            Color(0xff21406c), // Pink
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: buttonNavigationBarEntityList.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return GestureDetector(
            onTap: () {
              setState(() {
                widget.onItemTapped(index);
              });
            },
            child: ButtonNavigationBarItem(
              isSelected: widget.selectedIndex == index,
              barEntity: item,
            ),
          );
        }).toList(),
      ),
    );
  }
}
