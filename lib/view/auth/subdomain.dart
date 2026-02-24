// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:appex_lead/component/custom_appbar.dart';
// import 'package:appex_lead/component/custom_button.dart';
// import 'package:appex_lead/component/custom_drawer.dart';
// import 'package:appex_lead/component/custom_input_field.dart';
// import 'package:appex_lead/main.dart';
// import 'package:appex_lead/utils/auth_service.dart';
// import 'package:appex_lead/utils/constants.dart';
// import 'package:appex_lead/utils/custom_toast_messages.dart';
// import 'package:appex_lead/utils/helpers.dart';
// import 'package:appex_lead/view/auth/login.dart';

// class SubdomainScreen extends StatefulWidget {
//   const SubdomainScreen({super.key});

//   @override
//   State<SubdomainScreen> createState() => _SubdomainScreenState();
// }

// class _SubdomainScreenState extends State<SubdomainScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final TextEditingController subDomainController = TextEditingController();

//   _verifySubdomain() async {
//     showLoading(message: "Verifying...");
//     var res = await api.verifySubdomain(subDomainController.text);
//     if (res == true) {
//       await AuthService.updateSubdomain(subDomainController.text);
//       Get.off(() => LoginScreen());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: colorManager.bgDark,
//       drawer: CustomDrawer(),
//       appBar: CustomAppBar(
//         // drawer button
//         leading: Padding(
//           padding: EdgeInsetsGeometry.only(left: 16, right: 10),
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 toggleDrawer(_scaffoldKey);
//               });
//             },
//             child: HugeIcon(icon: HugeIcons.strokeRoundedMenu02),
//           ),
//         ),
//         title: "Subdomain",
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           spacing: 12,
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(colorManager.appLogo, height: 160),
//             Text(
//               'Enter your subdomain to continue.',
//               style: primaryTextStyle.copyWith(fontSize: 16),
//             ),
//             CustomInputField(
//               controller: subDomainController,
//               prefixIcon: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 18),
//                 child: HugeIcon(
//                   icon: HugeIcons.strokeRoundedGlobe,
//                   color: colorManager.secondaryColor,
//                 ),
//               ),
//               label: "Subdomain",
//             ),
//             CustomButton(
//               label: "Verify",
//               onTap: () {
//                 _verifySubdomain();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
