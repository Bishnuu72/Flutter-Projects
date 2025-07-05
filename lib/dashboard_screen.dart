// import 'package:flutter/material.dart';
//
// class DashboardViewModel {
//   final String email;
//   final String password;
//
//   DashboardViewModel({required this.email, required this.password});
// }
//
// class DashboardScreen extends StatelessWidget {
//   final DashboardViewModel dashboardViewModel;
//
//   const DashboardScreen({super.key, required this.dashboardViewModel});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Dashboard'),
//         // automaticallyImplyLeading: false,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         spacing: 10,
//         children: [
//           Text("email: ${dashboardViewModel.email}"),
//           Text("password: ${dashboardViewModel.password}"),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('Go Back'),
//           ),
//         ],
//       ),
//     );
//   }
// }
