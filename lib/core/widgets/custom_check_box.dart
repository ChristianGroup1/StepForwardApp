// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class CustomCheckBox extends StatefulWidget {
//   const CustomCheckBox({
//     super.key,
//   });

//   @override
//   State<CustomCheckBox> createState() => _CustomCheckBoxState();
// }

// class _CustomCheckBoxState extends State<CustomCheckBox> {
  

//   @override
//   Widget build(BuildContext context) {
//     var cubit=context.read<SignUpCubit>();
//     return Container(
      
//       decoration: ShapeDecoration(
//         color:cubit.isTermsChecked? AppColors.primaryColor:Colors.transparent,
//           shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xffDDDFDF)),
//               borderRadius: BorderRadius.circular(8))),
//     child: GestureDetector(
//       onTap: () {
//         setState(() {
//           cubit.isTermsChecked = !cubit.isTermsChecked;
//         });
//       },
//       child: const Icon(Icons.check,color: Colors.white,)),
//     );
//   }
// }
