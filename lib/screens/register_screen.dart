import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manshi/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isChecked = false;
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left:35, top:85),
                child: Text("Start your wellness journey today.", style: TextStyle(
                  color: Colors.white,
                  fontSize: 33,
                )),
              ),
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.25, right:35, left:35),
                child: Column(
                  children: [
                    TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              'assets/icon/user.svg',
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                          fillColor: Colors.grey[900],
                          filled: true,
                          hintText: 'Enter your name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                    ),
                    SizedBox(
                      height:30,
                    ),
                    TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              'assets/icon/email.svg',
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        fillColor: Colors.grey[900],
                        filled: true,
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      )
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      obscureText: !isPasswordVisible,
                      style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                'assets/icon/password.svg',
                                width: 20,
                                height: 20,
                                color: Colors.white,
                              ),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset(
                                  isPasswordVisible?
                                  'assets/icon/eye-open.svg' : 'assets/icon/eye-slash.svg',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            fillColor: Colors.grey.shade900,
                            filled: true,
                            hintText: 'Enter your password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        )
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                  children: [
                                    Checkbox(
                                      value: isChecked,
                                      onChanged: (value) {
                                        setState(() {
                                          isChecked = value!;
                                        });
                                      },
                                      checkColor: Colors.white,
                                      activeColor: Colors.grey[700],
                                    ),
                                    const Text(
                                      "Remember me",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ]
                              ),
                            ]
                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'login_screen');
                            },
                            child: const Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )
                            )
                        )
                    ),
                    Container(
                        margin: EdgeInsets.only(top:20),
                        child: const Text(
                            "Or",
                            style: TextStyle(
                              color: Colors.white,
                            )
                        )
                    ),
                    Container(
                        margin: EdgeInsets.only(top:20),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                            onPressed: () {},
                            child: const Text(
                                "Google",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                )
                            )
                        )
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: Colors.white,
                                )
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, 'login_screen');
                                },
                                child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                    )
                                )
                            )
                          ]
                      ),
                    )
                  ],
                ),
              ),
            ]
        )
    );
  }
}