import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confab/colors.dart';
import 'package:confab/form.dart';
import 'package:confab/shareSheet.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

late var curQuestion = {};
late var curTip = "";
late var curCateg = "";
var allQues = [];
var smallQues = [];
var casualQues = [];
var deepQues = [];
var partyQues = [];
var tips = {};
var ques = {};
var categs = ["small", "casual", "deep", "party"];
final bgColorsArray = [
  CustomColors.bg1,
  CustomColors.bg2,
  CustomColors.bg3,
  CustomColors.bg4,
  CustomColors.bg5
];
late var bgColor = bgColorsArray[Random().nextInt(5)];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Confab',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          backgroundColor: bgColor,
          fontFamily: 'Nunito',
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => App(),
          '/home': (context) => Home(),
          '/form': (context) => FormPage(stateValue: 0),
          '/success': (context) => SuccessPage()
        });
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  double opacityLevel = 1.0;
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void navigate() {
    _controller.forward();

    Timer(Duration(milliseconds: 400), () {
      if (mounted) Navigator.pushReplacement(context, createRoute(Home(), 300));
    });
  }

  late AnimationController _controller;
  late Animation<double> _animation;

  void getTip() {
    curTip = tips[curCateg][Random().nextInt(tips[curCateg].length)];
  }

  Future<bool> internetStatus() async {
    bool hasConnection;
    try {
      await FirebaseFirestore.instance
          .runTransaction((Transaction tx) {})
          .timeout(Duration(seconds: 5));
      hasConnection = true;
    } on PlatformException catch (_) {
      hasConnection = false;
    } on TimeoutException catch (_) {
      hasConnection = false;
    } catch (_) {
      hasConnection = false;
    }
    return hasConnection;
  }

  @override
  void initState() {
    super.initState();
    double begin = 1;
    double end = 0;
    const curve = Curves.ease;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween(begin: begin, end: end)
        .chain(CurveTween(curve: curve))
        .animate(_controller);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: FadeTransition(
        opacity: _animation,
        child: FutureBuilder(
          // Initialize FlutterFire:
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return const MaterialApp(home: Text("Something Went Wrong"));
            }

            if (snapshot.connectionState == ConnectionState.done) {
              internetStatus().then((value) {
                if (!value) {
                  print("no internet");
                }
              });
              FirebaseFirestore.instance
                  .collection('questions')
                  .get()
                  .then((QuerySnapshot querySnapshot) {
                if (querySnapshot.docs.isNotEmpty) {
                  final allData =
                      querySnapshot.docs.map((doc) => doc.data()).toList();
                  ques['small'] = allData[0]['small'];
                  ques['casual'] = allData[0]['casual'];
                  ques['deep'] = allData[0]['deep'];
                  ques['party'] = allData[0]['party'];
                  tips['small'] = allData[1]['small'];
                  tips['casual'] = allData[1]['casual'];
                  tips['deep'] = allData[1]['deep'];
                  tips['party'] = allData[1]['party'];
                  curCateg = categs[Random().nextInt(categs.length)];
                  curQuestion =
                      ques[curCateg][Random().nextInt(ques[curCateg].length)];
                  getTip();
                  navigate();
                }
              });
            }
            print(snapshot.toString());
            return const SplashScreenCustom();
          },
        ),
      ),
    );
  }
}

Route createRoute(Widget widget, var dur) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: dur),
    pageBuilder: (context, animation, secondaryAnimation) => widget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      double begin = 0;
      double end = 1;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return FadeTransition(
        opacity: animation.drive(tween),
        child: child,
      );
    },
  );
}

class SplashScreenCustom extends StatelessWidget {
  const SplashScreenCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
        ),
        Text(
          "Confab",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.095),
        ),
      ],
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  var questionFontSize;
  var activeVal = 1;
  var isVisible = false;
  var screenWidth;
  PanelController _pc = new PanelController();
  var menuColor1 = Colors.black;
  var menuColor2 = Colors.black54;
  var menuColor3 = Colors.black54;
  late ValueSetter<bool> progressSetter = (value) {
    print("object");
    setState(() {
      isVisible = value;
    });
  };
  var menuColor4 = Colors.black54;
  var menuColor5 = Colors.black54;

  void updateMenu(value) {
    switch (value) {
      case 1:
        setState(() {
          menuColor1 = Colors.black;
          menuColor2 = Colors.black54;
          menuColor3 = Colors.black54;
          menuColor4 = Colors.black54;
          menuColor5 = Colors.black54;
        });
        break;
      case 2:
        setState(() {
          menuColor1 = Colors.black54;
          menuColor2 = Colors.black;
          menuColor3 = Colors.black54;
          menuColor4 = Colors.black54;
          menuColor5 = Colors.black54;
        });
        break;
      case 3:
        setState(() {
          menuColor1 = Colors.black54;
          menuColor2 = Colors.black54;
          menuColor3 = Colors.black;
          menuColor4 = Colors.black54;
          menuColor5 = Colors.black54;
        });
        break;
      case 4:
        setState(() {
          menuColor1 = Colors.black54;
          menuColor2 = Colors.black54;
          menuColor3 = Colors.black54;
          menuColor4 = Colors.black;
          menuColor5 = Colors.black54;
        });
        break;
      case 5:
        setState(() {
          menuColor1 = Colors.black54;
          menuColor2 = Colors.black54;
          menuColor3 = Colors.black54;
          menuColor4 = Colors.black54;
          menuColor5 = Colors.black;
        });
        break;
    }
  }

  void setBgColor() {
    var prev = bgColorsArray.indexOf(bgColor);
    var next;
    do {
      next = Random().nextInt(5);
    } while (next == prev);
    setState(() {
      bgColor = bgColorsArray[next];
    });
  }

  void changeTip() {
    var prev = tips[curQuestion['category']].indexOf(curTip);
    var next;
    do {
      next = Random().nextInt(tips[curQuestion['category']].length);
    } while (next == prev);
    setState(() {
      curTip = tips[curQuestion['category']][next];
    });
  }

  void changeQuestion(val, gen) {
    var category = "";
    switch (val) {
      case 1:
        category = "all";
        break;
      case 2:
        category = "small";
        break;
      case 3:
        category = "casual";
        break;
      case 4:
        category = 'party';
        break;
      case 5:
        category = "deep";
        break;
    }
    var array = [];
    if (category != "all") {
      array = ques[category];
    } else {
      array = ques['small'] + ques['deep'] + ques['party'] + ques['casual'];
    }
    var prev =
        array.indexWhere((element) => element['text'] == curQuestion['text']);
    var next;
    do {
      next = Random().nextInt(array.length);
    } while (next == prev);
    setState(() {
      curQuestion = array[next];
      changeTip();
    });
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    timeDilation = 2;
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1;

    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: bgColor,
        body: SlidingUpPanel(
          body: Builder(builder: (BuildContext context) {
            return SafeArea(
                child: GestureDetector(
              onVerticalDragUpdate: (details) {
                int sensitivity = 8;
                if (details.delta.dy > sensitivity) {
                  // Down Swipe
                } else if (details.delta.dy < -sensitivity) {
                  // Up Swipe
                  _pc.open();
                }
              },
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                        width: double.infinity,
                      ),
                      Text(
                        "Confab" +
                            MediaQuery.of(context).textScaleFactor.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: screenWidth * 0.095),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            PopupMenuButton<int>(
                              onSelected: (value) {
                                if (value == activeVal) return;

                                activeVal = value;
                                _tabController.animateTo(value - 1);
                                changeQuestion(value, false);

                                setBgColor();
                                switch (value) {
                                  case 1:
                                    setState(() {
                                      menuColor1 = Colors.black;
                                      menuColor2 = Colors.black54;
                                      menuColor3 = Colors.black54;
                                      menuColor4 = Colors.black54;
                                      menuColor5 = Colors.black54;
                                    });
                                    break;
                                  case 2:
                                    setState(() {
                                      menuColor1 = Colors.black54;
                                      menuColor2 = Colors.black;
                                      menuColor3 = Colors.black54;
                                      menuColor4 = Colors.black54;
                                      menuColor5 = Colors.black54;
                                    });
                                    break;
                                  case 3:
                                    setState(() {
                                      menuColor1 = Colors.black54;
                                      menuColor2 = Colors.black54;
                                      menuColor3 = Colors.black;
                                      menuColor4 = Colors.black54;
                                      menuColor5 = Colors.black54;
                                    });
                                    break;
                                  case 4:
                                    setState(() {
                                      menuColor1 = Colors.black54;
                                      menuColor2 = Colors.black54;
                                      menuColor3 = Colors.black54;
                                      menuColor4 = Colors.black;
                                      menuColor5 = Colors.black54;
                                    });
                                    break;
                                  case 5:
                                    setState(() {
                                      menuColor1 = Colors.black54;
                                      menuColor2 = Colors.black54;
                                      menuColor3 = Colors.black54;
                                      menuColor4 = Colors.black54;
                                      menuColor5 = Colors.black;
                                    });
                                    break;
                                }
                              },
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0))),
                              padding: EdgeInsets.only(left: 10, right: 100),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: Text(
                                    "All",
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.048,
                                        fontWeight: FontWeight.w600,
                                        color: menuColor1),
                                  ),
                                ),
                                PopupMenuItem(
                                    value: 2,
                                    child: Container(
                                      width: screenWidth * 0.27,
                                      child: Text(
                                        "Small Talk",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.048,
                                            fontWeight: FontWeight.w600,
                                            color: menuColor2),
                                      ),
                                    )),
                                PopupMenuItem(
                                  value: 3,
                                  child: Text(
                                    "Casual",
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.048,
                                        fontWeight: FontWeight.w600,
                                        color: menuColor3),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 4,
                                  child: Text(
                                    "Party",
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.048,
                                        fontWeight: FontWeight.w600,
                                        color: menuColor4),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 5,
                                  child: Text(
                                    "Deep",
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.048,
                                        fontWeight: FontWeight.w600,
                                        color: menuColor5),
                                  ),
                                ),
                              ],
                              initialValue: 1,
                              offset: Offset(0, 74),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0.037 * screenWidth,
                                    vertical: 15.5),
                                decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6))),
                                child: SizedBox(
                                  width: 0.0576 * screenWidth,
                                  height: 0.0576 * screenWidth,
                                  child: Image(
                                    image:
                                        AssetImage('images/category_icon.png'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 0.03 * MediaQuery.of(context).size.width,
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6))),
                              child: Container(
                                color: Colors.transparent,
                                width: 0.75 * MediaQuery.of(context).size.width,
                                child: Center(
                                  child: TabBar(
                                    physics: BouncingScrollPhysics(),
                                    onTap: (value) {
                                      if (value == (activeVal - 1)) return;
                                      activeVal = value + 1;
                                      changeQuestion(value + 1, false);

                                      setBgColor();
                                      updateMenu(value + 1);
                                    },
                                    tabs: [
                                      Tab(
                                          height: 50,
                                          child: Text(
                                            "All",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: screenWidth * 0.046),
                                          )),
                                      Tab(
                                          child: Text(
                                        "Small Talk",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: screenWidth * 0.046),
                                      )),
                                      Tab(
                                          child: Text(
                                        "Casual",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: screenWidth * 0.046),
                                      )),
                                      Tab(
                                          child: Text(
                                        "Party",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: screenWidth * 0.046),
                                      )),
                                      Tab(
                                          child: Text(
                                        "Deep",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: screenWidth * 0.046),
                                      )),
                                    ],
                                    unselectedLabelColor: Colors.white70,
                                    indicatorColor: Colors.white,
                                    labelColor: Colors.white,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    indicatorWeight: 3.0,
                                    isScrollable: true,
                                    labelPadding:
                                        EdgeInsets.only(left: 14, right: 14),
                                    controller: _tabController,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.52,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: BouncingScrollPhysics(),
                          child: Container(
                            color: bgColor,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                      onLongPress: () {
                                        _pc.open();
                                      },
                                      child: AutoSizeText(
                                        (curQuestion['text']),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            height: 1.5,
                                            fontWeight: FontWeight.w700,
                                            fontSize: screenWidth * 0.1,
                                            color: Colors.white),
                                        maxLines: 5,
                                      )),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    ("Tip: " + curTip),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.white,
                                        height: 1.5,
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: bgColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(width: screenWidth),
                          Container(
                            padding:
                                EdgeInsets.only(left: 20, right: 20, bottom: 3),
                            child: ElevatedButton(
                              onPressed: () {
                                setBgColor();
                                HapticFeedback.vibrate();
                                changeQuestion(activeVal, true);
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      'images/shape.png',
                                      color: bgColor,
                                    ),
                                    SizedBox(width: 15),
                                    Text(
                                      'Generate New Question',
                                      style: TextStyle(
                                          color: bgColor,
                                          fontSize: screenWidth * 0.05),
                                    )
                                  ]),
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                shadowColor: Colors.transparent,
                                primary: Colors.white,
                                splashFactory: NoSplash.splashFactory,
                                minimumSize: Size(screenWidth, 60),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32.0)),
                              ),
                            ),
                          ),
                          GestureDetector(
                              onTap: () => {
                                    Navigator.of(context).push(createRoute(
                                        FormPage(
                                          stateValue: 0,
                                        ),
                                        300))
                                  },
                              child: Container(
                                width: screenWidth,
                                decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25))),
                                margin: const EdgeInsets.only(
                                    left: 20, top: 20, right: 20, bottom: 30),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Suggest a question",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                      )
                                    ]),
                              ))
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Visibility(
                      visible: isVisible,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ));
          }),
          controller: _pc,
          panel: shareSheet(pc: _pc, call: progressSetter),
          renderPanelSheet: true,
          backdropEnabled: true,
          minHeight: 0,
          maxHeight: 440,
          backdropColor: Colors.black,
          backdropOpacity: 0.65,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ));
  }
}
