import 'dart:async';
import 'dart:ui';

import 'package:confab/colors.dart';
import 'package:confab/main.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPage extends StatefulWidget {
  final int stateValue;

  const FormPage({Key? key, required this.stateValue}) : super(key: key);
  // Create the initialization Future outside of `build`:
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  bool isVisible = false;
  bool isError = false;
  double pageOpacity = 0;
  late var screenWidth;

  Future<void> updateUser(docref) {
    return FirebaseFirestore.instance
        .collection('suggestions')
        .doc(docref)
        .update({
      'questions': FieldValue.arrayUnion([qController.text])
    }).then((value) {
      setState(() {
        isVisible = false;
      });
      Navigator.of(context).pushReplacement(createRoute(SuccessPage(), 400));
    }).catchError((error) => {});
  }

  String? selectedValue;
  List<String> items = ['Casual', 'Small Talk', 'Deep', 'Party'];
  TextEditingController qController = new TextEditingController();

  List<DropdownMenuItem<String>> _addDividersAfterItems(
      List<String> items, value) {
    var index = items.indexOf(value);
    var color = Colors.black38;
    List<DropdownMenuItem<String>> _menuItems = [];
    for (var item in items) {
      if (items.indexOf(item) == index)
        color = Colors.black;
      else
        color = Colors.black45;
      _menuItems.add(DropdownMenuItem<String>(
        value: item,
        child: Text(
          item,
          style: TextStyle(
              fontSize: screenWidth * 0.046,
              fontWeight: FontWeight.w600,
              color: color),
        ),
      ));
    }
    return _menuItems;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.stateValue == 0) {
        Timer(Duration(milliseconds: 300), () {
          setState(() {
            pageOpacity = 1;
          });
        });
      } else {
        setState(() {
          pageOpacity = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () {
          setState(() {
            pageOpacity = 0;
          });
          Timer(Duration(milliseconds: 350), () {
            Navigator.pop(context, false);
          });

          //we need to return a future
          return Future.value(false);
        },
        child: Scaffold(
            backgroundColor: bgColor,
            body: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: pageOpacity,
              child: SafeArea(
                child: Stack(children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Container(
                        padding: EdgeInsets.only(left: 21, right: 21),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: screenWidth * 0.06,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      pageOpacity = 0;
                                    });
                                    Timer(Duration(milliseconds: 350), () {
                                      Navigator.pop(context, false);
                                    });
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
                                  "Suggestion Form",
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.055,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: screenWidth * 0.05,
                            ),
                            Text(
                              "Suggest stuff to talk about in any social situation you can think of!",
                              style: TextStyle(
                                  fontSize: screenWidth * 0.051,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: screenWidth * 0.055,
                            ),
                            Text(
                              "Category",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.054,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 13,
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                hint: DropdownMenuItem<String>(
                                  value: "Select a category",
                                  child: Text(
                                    "Select a category",
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.046,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black45),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 25,
                                ),
                                items: _addDividersAfterItems(
                                    items, selectedValue),
                                value: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value as String;
                                  });
                                },
                                buttonDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                buttonPadding:
                                    EdgeInsets.only(left: 20, right: 20),
                                buttonHeight: 50,
                                buttonWidth: double.infinity,
                                itemHeight: 40,
                                focusColor: Colors.white,
                                itemPadding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                itemWidth:
                                    (MediaQuery.of(context).size.width - 42),
                                offset: Offset(0, -6),
                                buttonElevation: 0,
                                dropdownElevation: 4,
                                dropdownDecoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Question",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.054,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 13,
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 19),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              height: MediaQuery.of(context).size.height *
                                  0.066 *
                                  5,
                              child: TextField(
                                controller: qController,
                                scrollPhysics: BouncingScrollPhysics(),
                                style: TextStyle(
                                    fontSize: screenWidth * 0.055,
                                    color: Colors.black),
                                maxLines: 6,
                                decoration: new InputDecoration.collapsed(
                                    hintStyle: TextStyle(
                                        fontSize: screenWidth * 0.055,
                                        color: Colors.black26),
                                    hintText:
                                        'Example: Who is your favorite anime character?'),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.08,
                            ),
                            Container(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (qController.text.isNotEmpty &&
                                      selectedValue != null) {
                                    setState(() {
                                      isVisible = true;
                                      isError = false;
                                    });
                                    var docRef;
                                    if (selectedValue == "Casual") {
                                      docRef = "casual";
                                    } else if (selectedValue == "Small Talk") {
                                      docRef = "small";
                                    } else if (selectedValue == "Party") {
                                      docRef = "party";
                                    } else {
                                      docRef = "deep";
                                    }
                                    updateUser(docRef);
                                  } else {
                                    setState(() {
                                      isError = true;
                                    });
                                  }
                                },
                                child: Text(
                                  'Submit',
                                  style:
                                      TextStyle(color: bgColor, fontSize: 20),
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  shadowColor: Colors.transparent,
                                  primary: Colors.white,
                                  splashFactory: NoSplash.splashFactory,
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 1,
                                      60),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.025,
                            ),
                            Visibility(
                                visible: isError,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Icon(Icons.error_outline_rounded,
                                        color: Colors.white),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Please fill all fields.",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: screenWidth * 0.045),
                                    )
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Visibility(
                      visible: isVisible,
                      child: CircularProgressIndicator(color: bgColor),
                    ),
                  ),
                ]),
              ),
            )));
  }
}

class SuccessPage extends StatefulWidget {
  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Timer(Duration(milliseconds: 400), () {
        setState(() {
          opacity = 1;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        setState(() {
          opacity = 0;
        });
        Timer(Duration(milliseconds: 400), () {
          Navigator.pop(context, false);
        });

        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: AnimatedOpacity(
          duration: Duration(milliseconds: 400),
          opacity: opacity,
          child: SafeArea(
              child: Stack(children: <Widget>[
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 23),
                  child: Text(
                    "Confab",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.095),
                  ),
                )),
            Align(
                alignment: Alignment.center,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Icon(Icons.check_circle_outline_rounded,
                      size: 70, color: Colors.white),
                  SizedBox(height: 15),
                  Text(
                    "Response Submitted",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.08),
                  ),
                  SizedBox(height: 13),
                  Text(
                    "Your question will be reviewed and \nadded soon.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.046),
                  ),
                ])),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 21, vertical: 22),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            opacity = 0;
                          });
                          Timer(Duration(milliseconds: 400), () {
                            Navigator.pop(context, false);
                          });
                        },
                        child: Text(
                          'Go Back',
                          style: TextStyle(
                              color: bgColor,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          shadowColor: Colors.transparent,
                          primary: Colors.white,
                          splashFactory: NoSplash.splashFactory,
                          minimumSize:
                              Size(MediaQuery.of(context).size.width, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.052,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            opacity = 0;
                          });
                          Timer(Duration(milliseconds: 400), () {
                            Navigator.of(context).pushReplacement(
                                createRoute(FormPage(stateValue: 1), 400));
                          });
                        },
                        child: Text(
                          'Suggest another question',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          shadowColor: Colors.transparent,
                          primary: Colors.white24,
                          splashFactory: NoSplash.splashFactory,
                          minimumSize:
                              Size(MediaQuery.of(context).size.width, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                        )),
                  ]),
                ))
          ])),
        ),
      ),
    );
  }
}
