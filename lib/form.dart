import 'dart:async';

import 'package:confab/main.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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

  void submitClicked() {
    FocusScope.of(context).unfocus();
    if (qController.text.isNotEmpty && selectedValue != null) {
      setState(() {
        isError = false;
      });
      var docRef;
      if (selectedValue == "Casual") {
        docRef = "casual";
      } else if (selectedValue == "Debate") {
        docRef = "debate";
      } else if (selectedValue == "Party") {
        docRef = "party";
      } else {
        docRef = "deep";
      }
      hasNetwork().then((value) {
        if (value) {
          setState(() {
            isVisible = true;
          });
          updateUser(docRef);
        } else {
          showDialog(
            useSafeArea: true,
            context: context,
            builder: (context) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  color: Colors.black26,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 28, top: 24),
                      width: screenWidth * 0.9,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.sentiment_dissatisfied_rounded,
                            color: bgColor,
                            size: 45,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Can't submit question",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: 23.0,
                                decoration: TextDecoration.none),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Please check your internet\nconnection.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Nunito',
                                color: Colors.black,
                                fontSize: 19.0,
                                decoration: TextDecoration.none),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              submitClicked();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 9),
                              child: const Text(
                                'Retry',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Nunito',
                                  decoration: TextDecoration.none,
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
            ),
          );
        }
      });
    } else {
      setState(() {
        isError = true;
      });
    }
  }

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
      Navigator.of(context).pushReplacement(createRoute(SuccessPage(), 300));
    }).catchError((error) => {});
  }

  Future<bool> hasNetwork() async {
    if (kIsWeb) {
      return true;
    }
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      return true;
    } else {
      return false;
    }
  }

  String? selectedValue;
  List<String> items = ['Casual', 'Debate', 'Deep', 'Party'];
  TextEditingController qController = new TextEditingController();

  List<DropdownMenuItem<String>> _addDividersAfterItems(List items, value) {
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
              fontSize: 17, fontWeight: FontWeight.w600, color: color),
        ),
      ));
    }
    return _menuItems;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.stateValue == 0) {
        Timer(const Duration(milliseconds: 300), () {
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

  late Widget widget1;

  @override
  Widget build(BuildContext context) {
    widget1 = Container();
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 830)
      widget1 = Container(
        width: double.infinity,
        color: Colors.white24,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Confab",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 26),
            ),
            const Spacer(),
            const Icon(
              Icons.info_outline,
              size: 30,
              color: Colors.white,
            ),
            const SizedBox(
              width: 6,
            ),
            const Text(
              "Learn More",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 17),
            ),
          ],
        ),
      );
    return WillPopScope(
        onWillPop: () {
          setState(() {
            pageOpacity = 0;
          });
          Timer(const Duration(milliseconds: 350), () {
            Navigator.pop(context, false);
          });

          //we need to return a future
          return Future.value(false);
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
              backgroundColor: bgColor,
              body: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: pageOpacity,
                child: SafeArea(
                  child: Stack(children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: screenWidth > 830 ? 0 : 21,
                              right: screenWidth > 830 ? 0 : 21),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              widget1,
                              const SizedBox(
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
                                      setState(() {
                                        pageOpacity = 0;
                                      });
                                      Timer(const Duration(milliseconds: 250),
                                          () {
                                        Navigator.pop(context, false);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                      size: 27,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Suggestion Form",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth > 830 ? 60 : 0),
                                child: const Text(
                                  "Suggest stuff to talk about in any social situation you can think of!",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth > 830 ? 60 : 0),
                                child: const Text(
                                  "Category",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 13,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth > 830 ? 60 : 0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    hint: const DropdownMenuItem<String>(
                                      value: "Select a category",
                                      child: Text(
                                        "Select a category",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black45),
                                      ),
                                    ),
                                    icon: const Icon(
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
                                    buttonPadding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    buttonHeight: screenWidth > 830 ? 40 : 50,
                                    buttonWidth: screenWidth > 830
                                        ? screenWidth * 0.35
                                        : double.infinity,
                                    itemHeight: 40,
                                    focusColor: Colors.white,
                                    itemPadding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    dropdownWidth: MediaQuery.of(context)
                                                .size
                                                .width >
                                            830
                                        ? MediaQuery.of(context).size.width *
                                            0.35
                                        : (MediaQuery.of(context).size.width -
                                            42),
                                    offset: const Offset(0, -6),
                                    buttonElevation: 0,
                                    dropdownElevation: 4,
                                    dropdownDecoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screenWidth > 830 ? 25 : 15,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth > 830 ? 60 : 0),
                                child: const Text(
                                  "Question",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 13,
                              ),
                              Container(
                                width: screenWidth > 830
                                    ? screenWidth * 0.6
                                    : double.infinity,
                                margin: EdgeInsets.only(
                                    left: screenWidth > 830 ? 60 : 0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 19),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                height: screenWidth > 830
                                    ? MediaQuery.of(context).size.height < 645
                                        ? MediaQuery.of(context).size.height *
                                            0.041 *
                                            5
                                        : MediaQuery.of(context).size.height *
                                            0.046 *
                                            5
                                    : MediaQuery.of(context).size.height < 645
                                        ? MediaQuery.of(context).size.height *
                                            0.051 *
                                            5
                                        : MediaQuery.of(context).size.height *
                                            0.066 *
                                            5,
                                child: TextField(
                                  textInputAction: TextInputAction.done,
                                  controller: qController,
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                  maxLines: 10,
                                  decoration: new InputDecoration.collapsed(
                                      hintStyle: const TextStyle(
                                          fontSize: 20, color: Colors.black26),
                                      hintText:
                                          'Example: Who is your favorite anime character?'),
                                ),
                              ),
                              SizedBox(
                                height: screenWidth > 830
                                    ? MediaQuery.of(context).size.height * 0.1
                                    : MediaQuery.of(context).size.height * 0.08,
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: screenWidth > 830 ? 60 : 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    submitClicked();
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
                                        screenWidth > 830
                                            ? 300
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                1,
                                        60),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
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
                                    mainAxisAlignment: screenWidth > 830
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      SizedBox(
                                        width: screenWidth > 830 ? 60 : 0,
                                      ),
                                      const Icon(Icons.error_outline_rounded,
                                          color: Colors.white),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      const Text(
                                        "Please fill all fields.",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
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
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Visibility(
                        visible: screenWidth > 830 ? true : false,
                        child: const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text(
                            "Made with <3 by Naman and Ishaan",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 20),
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
              )),
        ));
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(milliseconds: 300), () {
        setState(() {
          opacity = 1;
        });
      });
    });
  }

  late Widget widget3;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 830) {
      widget3 = const Padding(
        padding: EdgeInsets.only(top: 10),
        child: const Text(
          "Confab",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 32),
        ),
      );
    } else {
      widget3 = Container(
        width: double.infinity,
        color: Colors.white24,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Confab",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 26),
            ),
            const Spacer(),
            const Icon(
              Icons.info_outline,
              size: 30,
              color: Colors.white,
            ),
            const SizedBox(
              width: 6,
            ),
            const Text(
              "Learn More",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 17),
            ),
          ],
        ),
      );
    }

    var ht = MediaQuery.of(context).size.height;

    Widget widget1 = Container();
    if (MediaQuery.of(context).size.width > 830)
      widget1 = Container(
        margin: const EdgeInsets.only(top: 26),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    opacity = 0;
                  });
                  Timer(const Duration(milliseconds: 400), () {
                    Navigator.pop(context, false);
                  });
                },
                child: Text(
                  'Go Back',
                  style: TextStyle(
                      color: bgColor,
                      fontSize: MediaQuery.of(context).size.width > 412
                          ? 20
                          : MediaQuery.of(context).size.width * 0.05),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  shadowColor: Colors.transparent,
                  primary: Colors.white,
                  splashFactory: NoSplash.splashFactory,
                  minimumSize: Size(
                      MediaQuery.of(context).size.width > 530
                          ? MediaQuery.of(context).size.width < 830
                              ? 500
                              : 360
                          : MediaQuery.of(context).size.width,
                      60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                )),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    opacity = 0;
                  });
                  Timer(const Duration(milliseconds: 300), () {
                    Navigator.of(context).pushReplacement(
                        createRoute(const FormPage(stateValue: 1), 300));
                  });
                },
                child: Text(
                  'Suggest another question',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width > 412
                          ? 20
                          : MediaQuery.of(context).size.width * 0.05),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  shadowColor: Colors.transparent,
                  primary: Colors.white24,
                  splashFactory: NoSplash.splashFactory,
                  minimumSize: Size(
                      MediaQuery.of(context).size.width > 530
                          ? MediaQuery.of(context).size.width < 830
                              ? 500
                              : 360
                          : MediaQuery.of(context).size.width,
                      60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                )),
          ]),
        ),
      );

    return WillPopScope(
      onWillPop: () {
        setState(() {
          opacity = 0;
        });
        Timer(const Duration(milliseconds: 300), () {
          Navigator.pop(context, false);
        });

        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: opacity,
          child: SafeArea(
              child: Stack(children: <Widget>[
            Align(alignment: Alignment.topCenter, child: widget3),
            Positioned(
                left: 0,
                right: 0,
                top: ht > 710
                    ? MediaQuery.of(context).size.width > 830
                        ? ht * 0.28
                        : ht * 0.35
                    : ht < 614
                        ? ht * 0.25
                        : ht * 0.31,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 70, color: Colors.white),
                  const SizedBox(height: 15),
                  const Text(
                    "Response Submitted",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 30),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    "Your question will be reviewed and \nadded soon.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: 17),
                  ),
                  widget1
                ])),
            Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible:
                      MediaQuery.of(context).size.width > 830 ? false : true,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 21, right: 21, top: 0, bottom: 30),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              opacity = 0;
                            });
                            Timer(const Duration(milliseconds: 400), () {
                              Navigator.pop(context, false);
                            });
                          },
                          child: Text(
                            'Go Back',
                            style: TextStyle(
                                color: bgColor,
                                fontSize: MediaQuery.of(context).size.width >
                                        412
                                    ? 20
                                    : MediaQuery.of(context).size.width * 0.05),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            shadowColor: Colors.transparent,
                            primary: Colors.white,
                            splashFactory: NoSplash.splashFactory,
                            minimumSize: Size(
                                MediaQuery.of(context).size.width > 530
                                    ? MediaQuery.of(context).size.width < 830
                                        ? 500
                                        : 360
                                    : MediaQuery.of(context).size.width,
                                60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              opacity = 0;
                            });
                            Timer(const Duration(milliseconds: 300), () {
                              Navigator.of(context).pushReplacement(createRoute(
                                  const FormPage(stateValue: 1), 300));
                            });
                          },
                          child: Text(
                            'Suggest another question',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width >
                                        412
                                    ? 20
                                    : MediaQuery.of(context).size.width * 0.05),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            shadowColor: Colors.transparent,
                            primary: Colors.white24,
                            splashFactory: NoSplash.splashFactory,
                            minimumSize: Size(
                                MediaQuery.of(context).size.width > 530
                                    ? MediaQuery.of(context).size.width < 830
                                        ? 500
                                        : 360
                                    : MediaQuery.of(context).size.width,
                                60),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                          )),
                    ]),
                  ),
                ))
          ])),
        ),
      ),
    );
  }
}
