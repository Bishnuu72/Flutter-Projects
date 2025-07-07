import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuotesDetailScreen extends StatefulWidget {
  const QuotesDetailScreen({super.key});

  @override
  State<QuotesDetailScreen> createState() => _QuotesDetailScreenState();
}

class _QuotesDetailScreenState extends State<QuotesDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset(
                          'assets/icon/chevron-backward.svg',
                          width: 40,
                          height: 40,
                          color: Colors.white,
                        )
                      ),
                      const Text(
                        'Motivation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                            ("1/15"),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const  Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        "❝The only way to do great work is to love what you do.❞",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        "- Bishnu yadav",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    Icon(Icons.swipe_up, color: Colors.white,),
                    SizedBox(height: 5,),
                    Text("Swipe up", style: TextStyle(color: Colors.white),),
                    SizedBox(height: 20,),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white, size: 30,),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 30,),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 30,),
                        onPressed: () {},
                      ),
                    ],
                  ),
                )
              ],
            ),
            Positioned(
              top: 70,
              right: 25,
              child: CircleAvatar(
                backgroundColor: Colors.grey[850],
                radius: 24,
                child: IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white,),
                  onPressed: () {},
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
