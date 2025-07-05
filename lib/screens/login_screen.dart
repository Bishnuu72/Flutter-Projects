import 'package:flutter/material.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left:80, top:150),
            child: Text("Welcome Back!", style: TextStyle(
              color: Colors.white,
              fontSize: 33,
            )),
          ),
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.3, right:35, left:35),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    fillColor: Colors.grey[900],
                    filled: true,
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  decoration: InputDecoration(
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
                      const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.white),
                      )
                    ]
                  )
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
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
                )
              ],
            ),
          ),
        ]
      )
    );
  }
}
