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
              SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: screenWidth > 830 ? 60 : 0,
                  ),
                  GestureDetector(
                    onTap: () {
                      pageViewController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Settings",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth > 830 ? 60 : 0),
                child: Text(
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: Duration(milliseconds: 1200),
                    backgroundColor: Colors.white,
                    content: Text(
                      'You need to restart the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Lato', fontSize: 16, color: bgColor),
                    ),
                  ));

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('nsfw', status);
                },
                activeColor: Color(0xFFE9E9E9),
                activeTrackColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white54,
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth > 830 ? 60 : 0),
                child: Text(
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
                activeColor: Color(0xFFE9E9E9),
                activeTrackColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white54,
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth > 830 ? 60 : 0),
                child: Text(
                  "Tips",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ),
              Switch(
                value: tipsState,
                onChanged: (bool status) async {
                  widget.notifyParent(status, 1);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('tips', tipsState);
                },
                activeColor: Color(0xFFE9E9E9),
                activeTrackColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white54,
              ),
              // SizedBox(
              //   height: 20,
              // ),
              // Padding(
              //   padding: EdgeInsets.only(left: screenWidth > 830 ? 60 : 0),
              //   child: Text(
              //     "Tutorial",
              //     style: TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.w400,
              //         color: Colors.white),
              //   ),
              // ),
              // Switch(
              //   value: tutorial,
              //   onChanged: (bool status) async {
              //     setState(() {
              //       if (status)
              //         tutorial = true;
              //       else
              //         tutorial = false;
              //     });
              //     final prefs = await SharedPreferences.getInstance();
              //     await prefs.setBool('tutorial', tutorial);
              //   },
              //   activeColor: Color(0xFFE9E9E9),
              //   activeTrackColor: Colors.white,
              //   inactiveThumbColor: Colors.white,
              //   inactiveTrackColor: Colors.white54,
              // )
            ]),
      )),
    );
  }
}
