// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:stepforward/core/helper_functions/is_device_in_portrait.dart';

// class CustomBottomNavigationBarDecoration extends StatelessWidget {
//   final Widget child;
//   const CustomBottomNavigationBarDecoration({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isDeviceInPortrait(context) ? 70.h : 120.h,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [
//             Color(0xFF0F2027),
//             Color(0xFF203A43),
//             Color(0xFF2C5364),
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0xFF00FFAA), // A neon green glow
//             offset: Offset(0, -2),
//             blurRadius: 20,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//         child: child,
//       ),
//     );
//   }
// }
