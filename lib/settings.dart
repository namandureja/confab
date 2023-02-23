import 'package:confab/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class settings extends StatefulWidget {
  final Function(bool, int) notifyParent;

  const settings({Key? key, required this.notifyParent}) : super(key: key);

  @override
  _settingsState createState() => _settingsState();
}

class _settingsState extends State<settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: (() {
                  pageViewController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease);
                }),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: screenWidth >= 830 ? 60 : 0,
                    ),
                    const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "Settings",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth >= 830 ? 60 : 0),
                child: const Text(
                  "NSFW Questions",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ),
              Switch(
                value: nsfw,
                onChanged: (bool status) async {
                  widget.notifyParent(status, 2);

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('nsfw', status);
                },
                activeColor: const Color(0xFFE9E9E9),
                activeTrackColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white54,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth >= 830 ? 60 : 0),
                child: const Text(
                  "Haptic Feedback",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ),
              Switch(
                value: haptic,
                onChanged: (bool status) async {
                  setState(() {
                    widget.notifyParent(status, 0);
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('haptic', haptic);
                },
                activeColor: const Color(0xFFE9E9E9),
                activeTrackColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white54,
              ),
              const SizedBox(
                height: 20,
              ),
            ]),
      )),
    );
  }
}
