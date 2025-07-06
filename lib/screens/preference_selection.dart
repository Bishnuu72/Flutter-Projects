import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PreferenceSelection extends StatefulWidget {
  const PreferenceSelection({super.key});

  @override
  State<PreferenceSelection> createState() => _PreferenceSelectionState();
}

class _PreferenceSelectionState extends State<PreferenceSelection> {
  final List<String> topics = [
    "Hard Times",
    "Working out",
    "Productivity",
    "Self-esteem",
    "Achieving goals",
    "Inspiration",
    "Letting go",
    "Love",
    "Relationships",
    "Faith & Spirituality",
    "Positive thinking",
    "Stress & Anxiety",
  ];

  final Set<String> selectedTopics = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, 'login_screen');
                },
                child: SvgPicture.asset(
                  'assets/icon/chevron-backward.svg',
                  height: 40,
                  width: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                "Select all topics that motivates you",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount:2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3,
                  children: topics.map((topic) {
                    final isSelected = selectedTopics.contains(topic);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if(isSelected) {
                            selectedTopics.remove(topic);
                          }else{
                            selectedTopics.add(topic);
                          }
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.grey[900],
                          borderRadius: BorderRadius.circular(10),
                          // border: Border.all(color: Colors.red),
                        ),
                        child:Text(
                          topic,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "dashboard_screen");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
