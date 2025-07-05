// import 'package:flutter/material.dart';
// import 'package:manshi/dashboard_screen.dart';
//
// class LoginScreen extends  StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           child: SizedBox(
//             width: double.infinity,
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 spacing: 20,
//                 children: [
//                   Text(
//                     'Login',
//                     style:TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 32,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                   Text(
//                     'Welcome to wellness App',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w400,
//                       fontSize: 20,
//                       letterSpacing: 2,
//                     ),
//                   ),
//
//                   TextFormField(
//                     controller: _emailController,
//                     validator: (String? value) {
//                       if ((value ?? '').isEmpty) {
//                         return 'Email is required';
//                       }
//                     },
//                     decoration: InputDecoration(
//                       hintText: 'Enter your email',
//                       label: Text('Email', style: TextStyle(fontSize: 20)),
//                     ),
//                   ),
//
//                   TextFormField(
//                     controller: _passwordController,
//                     validator: (String? value) {
//                       if ((value ?? '').isEmpty) {
//                         return 'Password is required';
//                       }
//                     },
//                     decoration: InputDecoration(
//                       hintText: 'Enter your password',
//                       label: Text('Password', style: TextStyle(fontSize: 20)),
//                     ),
//                   ),
//
//                   TextButton(
//                     onPressed: () {
//                       if (_formKey.currentState != null &&
//                           _formKey.currentState!.validate()) {
//                         _formKey.currentState!.save();
//                         print(
//                           "email: ${_emailController.text}, password: ${_passwordController.text}",
//                         );
//
//                         Navigator.of(context).pushReplacement(
//                           MaterialPageRoute(
//                             builder: (ctx) {
//                               return DashboardScreen(
//                                 dashboardViewModel: DashboardViewModel(
//                                   email: _emailController.text,
//                                   password: _passwordController.text,
//                                 ),
//                               );
//                             },
//                           ),
//                         );
//                       }
//                     },
//                     child: Text('Login', style: TextStyle(fontSize: 20)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
