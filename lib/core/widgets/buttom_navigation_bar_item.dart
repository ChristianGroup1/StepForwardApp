import 'package:flutter/widgets.dart';
import 'package:stepforward/core/entities/buttom_navigation_bar_entity.dart';
import 'package:stepforward/core/widgets/active_navigation_bar_item.dart';
import 'package:stepforward/core/widgets/in_active_navigation_bar.dart';


class ButtonNavigationBarItem extends StatelessWidget {
  final bool isSelected;
  final ButtonNavigationBarEntity barEntity;
  const ButtonNavigationBarItem({super.key, required this.isSelected, required this.barEntity});

  @override
  Widget build(BuildContext context) {
    return  isSelected? ActiveNavigationItem(title: barEntity.name(context), image: barEntity.activeImage):InActiveNavigationItem(image: barEntity.inActiveImage);
  }
}