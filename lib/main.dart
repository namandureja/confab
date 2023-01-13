import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confab/colors.dart';
import 'package:confab/form.dart';
import 'package:confab/settings.dart';
import 'package:confab/shareSheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
var debateQues = [];
var casualQues = [];
var deepQues = [];
var partyQues = [];
var tips = {};
var ques = {};
bool haptic = true, nsfw = false, tutorial = true, tipsState = false;
var categs = ["debate", "casual", "deep", "party"];
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

  Widget getConstWidget(widget) {
    return MaterialApp(
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.3);
        return MediaQuery(
          child: widget,
          data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
        );
      },
    );
  }

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
          scrollbarTheme: ScrollbarThemeData(
              thickness: MaterialStateProperty.all(6),
              thumbColor: MaterialStateProperty.all(Colors.white24),
              radius: const Radius.circular(10),
              minThumbLength: 100),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => App(),
          '/home': (context) => getConstWidget(const Home()),
          '/form': (context) => getConstWidget(const FormPage(stateValue: 0)),
          '/success': (context) => getConstWidget(SuccessPage())
        });
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

bool networkStatus = false;

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

  Future<bool> getPref() async {
    final prefs = await SharedPreferences.getInstance();

    haptic = prefs.getBool('haptic') ?? true;
    tipsState = prefs.getBool('tips') ?? false;
    tutorial = prefs.getBool("tutorial") ?? true;
    nsfw = prefs.getBool("nsfw") ?? false;
    if (!nsfw) {
      ques['debate'] = ques['debate'].where((i) => !i['nsfw']).toList();
      ques['casual'] = ques['casual'].where((i) => !i['nsfw']).toList();
      ques['deep'] = ques['deep'].where((i) => !i['nsfw']).toList();
      ques['party'] = ques['party'].where((i) => !i['nsfw']).toList();
    }
    return true;
  }

  void setupApp() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("hello") == true) {
      _initialization.then((value) {
        hasNetwork().then((value) {
          networkStatus = value;
          FirebaseFirestore.instance
              .collection('questions')
              .get()
              .then((QuerySnapshot querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              final List allData =
                  querySnapshot.docs.map((doc) => doc.data()).toList();
              ques['debate'] = (allData[0] as dynamic)['debate'];
              ques['casual'] = (allData[0] as dynamic)['casual'];
              ques['deep'] = (allData[0] as dynamic)['deep'];
              ques['party'] = (allData[0] as dynamic)['party'];
              tips['debate'] = (allData[1] as dynamic)['debate'];
              tips['casual'] = (allData[1] as dynamic)['casual'];
              tips['deep'] = (allData[1] as dynamic)['deep'];
              tips['party'] = (allData[1] as dynamic)['party'];
              curCateg = categs[Random().nextInt(categs.length)];
              curQuestion =
                  ques[curCateg][Random().nextInt(ques[curCateg].length)];
              getTip();
              getPref().then((bool success) {
                navigate();
              });
            }
          });
        });
      });
    } else {
      _initialization.then((value) {
        hasNetwork().then((value) {
          if (value) {
            FirebaseFirestore.instance
                .collection('questions')
                .get()
                .then((QuerySnapshot querySnapshot) async {
              if (querySnapshot.docs.isNotEmpty) {
                final List allData =
                    querySnapshot.docs.map((doc) => doc.data()).toList();
                ques['debate'] = (allData[0] as dynamic)['debate'];
                ques['casual'] = (allData[0] as dynamic)['casual'];
                ques['deep'] = (allData[0] as dynamic)['deep'];
                ques['party'] = (allData[0] as dynamic)['party'];
                tips['debate'] = (allData[1] as dynamic)['debate'];
                tips['casual'] = (allData[1] as dynamic)['casual'];
                tips['deep'] = (allData[1] as dynamic)['deep'];
                tips['party'] = (allData[1] as dynamic)['party'];
                curCateg = categs[Random().nextInt(categs.length)];
                curQuestion =
                    ques[curCateg][Random().nextInt(ques[curCateg].length)];
                getTip();
                final prefs = await SharedPreferences.getInstance();
                if (prefs.getBool("hello") == null) {
                  await prefs.setBool("hello", true);
                }
                getPref().then((bool success) {
                  navigate();
                });
              }
            });
          } else {
            showDialog(
                context: context,
                builder: (context) => AnimatedOpacity(
                      opacity: 1,
                      duration: Duration(milliseconds: 400),
                      child: Container(
                          color: Colors.black26,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.only(bottom: 28, top: 24),
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Unable to load questions',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 23.0,
                                        decoration: TextDecoration.none),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Please check your internet\nconnection.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Nunito',
                                        color: Colors.black,
                                        fontSize: 19.0,
                                        decoration: TextDecoration.none),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      setupApp();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 9),
                                      child: Text(
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
                    ));
          }
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AnimatedOpacity(
                  opacity: 1,
                  duration: Duration(milliseconds: 400),
                  child: Container(
                      color: Colors.black26,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.only(bottom: 28, top: 24),
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
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Unable to load questions',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontSize: 23.0,
                                    decoration: TextDecoration.none),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Please check your internet\nconnection.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Nunito',
                                    color: Colors.black,
                                    fontSize: 19.0,
                                    decoration: TextDecoration.none),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Restart.restartApp();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(14)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 9),
                                  child: Text(
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
                ));
      });
    }
  }

  late Future showError;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setupApp();
    return Scaffold(
      backgroundColor: bgColor,
      body: FadeTransition(opacity: _animation, child: SplashScreenCustom()),
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

final pageViewController = PageController(initialPage: 0);

class SplashScreenCustom extends StatelessWidget {
  const SplashScreenCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
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
              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 32),
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

var screenWidth;

class _HomeState extends State<Home> with TickerProviderStateMixin {
  GlobalKey<_HomeState> _myKey = GlobalKey();
  var questionFontSize;
  var activeVal = 1;
  var isVisible = false;
  PanelController _pc = new PanelController();
  var menuColor1 = Colors.black;
  var menuColor2 = Colors.black54;
  var menuColor3 = Colors.black54;
  late ValueSetter<bool> progressSetter = (value) {
    setState(() {
      isVisible = value;
    });
  };
  var menuColor4 = Colors.black54;
  var menuColor5 = Colors.black54;
  void generatePressed() {
    setBgColor();
    if (haptic) HapticFeedback.lightImpact();
    changeQuestion(activeVal, true);
  }

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
        category = "casual";
        break;
      case 3:
        category = "debate";
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
      array = ques['debate'] + ques['deep'] + ques['party'] + ques['casual'];
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

  refresh(bool status, int key) {
    if (key == 0) {
      setState(() {
        haptic = status;
      });
    } else if (key == 1) {
      setState(() {
        tipsState = status;
      });
    } else if (key == 2) {
      setState(() {
        nsfw = status;
      });
    }
  }

  late TabController _tabController;
  late Widget widget3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!networkStatus) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 1500),
          backgroundColor: Colors.white,
          content: Text(
            'Please check your internet connection.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Lato', fontSize: 16, color: bgColor),
          ),
        ));
      }
    });
    timeDilation = 2;
    _tabController = TabController(length: 5, vsync: this);
  }

  final myScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    timeDilation = 1;

    screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 830) {
      widget3 = Container(
          width: screenWidth > 530
              ? screenWidth < 830
                  ? 500
                  : 360
              : screenWidth,
          child: Stack(children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                "Confab",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 32),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    pageViewController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 13,
                        right: screenWidth > 530 ? 15 : screenWidth * 0.048),
                    child: Container(
                      child: SizedBox(
                        width: 23,
                        height: 23,
                        child: Image(
                          image: AssetImage('images/settings.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ))
          ]));
    } else {
      widget3 = Container(
        width: double.infinity,
        color: Colors.white24,
        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Confab",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 26),
            ),
            Spacer(),
            Icon(
              Icons.info_outline,
              size: 30,
              color: Colors.white,
            ),
            SizedBox(
              width: 6,
            ),
            Text(
              "Learn More",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 17),
            ),
          ],
        ),
      );
    }

    return PageView(controller: pageViewController, children: [
      Scaffold(
          backgroundColor: bgColor,
          body: SlidingUpPanel(
            body: Builder(builder: (BuildContext context) {
              return SafeArea(
                  child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  int sensitivity = 4;
                  if (details.delta.dy > sensitivity) {
                    // Down Swipe
                  } else if (details.delta.dy < -sensitivity) {
                    // Up Swipe
                    _pc.open();
                  }
                },
                child: Stack(
                  children: <Widget>[
                    // Positioned(
                    //   child: Icon(
                    //     Icons.settings_outlined,
                    //     color: Colors.white,
                    //     size: 40,
                    //   ),
                    //   right: 0,
                    //   top: 0,
                    // ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: screenWidth > 830
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: screenWidth > 830 ? 0 : 15,
                          width: double.infinity,
                        ),
                        widget3,
                        SizedBox(
                          height: screenWidth > 830 ? 32 : 12,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: screenWidth > 830
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: screenWidth > 830 ? 60 : 0,
                              ),
                              PopupMenuButton<int>(
                                enableFeedback: haptic,
                                tooltip: "",
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: menuColor1),
                                    ),
                                  ),
                                  PopupMenuItem(
                                      value: 2,
                                      child: Container(
                                        width: screenWidth * 0.27,
                                        child: Text(
                                          "Casual",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: menuColor2),
                                        ),
                                      )),
                                  PopupMenuItem(
                                    value: 3,
                                    child: Text(
                                      "Debate",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: menuColor3),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 4,
                                    child: Text(
                                      "Party",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: menuColor4),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 5,
                                    child: Text(
                                      "Deep",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: menuColor5),
                                    ),
                                  ),
                                ],
                                initialValue: 1,
                                offset: Offset(0, 74),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.9, vertical: 15.5),
                                  decoration: const BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: Image(
                                      image: AssetImage(
                                          'images/category_icon.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                child: Container(
                                  color: Colors.transparent,
                                  width: screenWidth > 530
                                      ? screenWidth < 830
                                          ? 395
                                          : 457
                                      : 0.75 *
                                          MediaQuery.of(context).size.width,
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
                                                  fontSize: 18),
                                            )),
                                        Tab(
                                            child: Text(
                                          "Casual",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
                                        )),
                                        Tab(
                                            child: Text(
                                          "Debate",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
                                        )),
                                        Tab(
                                            child: Text(
                                          "Party",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
                                        )),
                                        Tab(
                                            child: Text(
                                          "Deep",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
                                        )),
                                      ],
                                      unselectedLabelColor: Colors.white70,
                                      indicatorColor: Colors.white,
                                      labelColor: Colors.white,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      indicatorWeight: 3.0,
                                      isScrollable: true,
                                      labelPadding: EdgeInsets.only(
                                          left: screenWidth > 830 ? 20 : 14,
                                          right: screenWidth > 830 ? 20 : 14),
                                      controller: _tabController,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Scrollbar(
                            controller: myScrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: myScrollController,
                              scrollDirection: Axis.vertical,
                              physics: BouncingScrollPhysics(),
                              child: Container(
                                color: bgColor,
                                width: screenWidth > 530
                                    ? screenWidth < 830
                                        ? 500
                                        : screenWidth * 0.85
                                    : double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth > 830 ? 60 : 20,
                                    vertical: 0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              fontSize: 30,
                                              color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Visibility(
                                        visible: tipsState,
                                        child: Text(
                                          (curTip),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.white,
                                              height: 1.5,
                                              fontSize: 18.5,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                        homeButtons(callback: (bool val) {
                          if (val) {
                            generatePressed();
                          } else {
                            _pc.open();
                          }
                        })
                      ],
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Visibility(
                        visible: isVisible,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Visibility(
                        visible: screenWidth > 830 ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            "© 2022 Dx2 Studios",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 20),
                          ),
                        ),
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
            maxHeight: 340,
            backdropColor: Colors.black,
            backdropOpacity: 0.65,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          )),
      settings(
        notifyParent: refresh,
      )
    ]);
  }
}

class homeButtons extends StatelessWidget {
  DrawerCallback callback;
  homeButtons({Key? key, required this.callback}) : super(key: key);
  late Widget widget;
  @override
  Widget build(BuildContext context) {
    widget = Container();
    if (screenWidth > 830) {
      widget = Container(
        width: 120,
        height: 2,
        margin: EdgeInsets.only(bottom: 50, left: 71, top: 4),
        color: Colors.white,
      );
    }
    // TODO: implement build
    return Container(
      color: bgColor,
      child: Column(
        crossAxisAlignment: screenWidth > 830
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: screenWidth),
          Container(
            height: 60,
            width: screenWidth > 530
                ? screenWidth < 830
                    ? 540
                    : 550
                : screenWidth,
            padding: EdgeInsets.only(
                left: screenWidth > 830 ? 60 : 20,
                right: 20,
                bottom: 0,
                top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      callback(true);
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
                            'Generate New',
                            style: TextStyle(
                                color: bgColor,
                                fontSize: screenWidth > 412
                                    ? 20
                                    : screenWidth * 0.05),
                          )
                        ]),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(double.infinity, double.maxFinite),
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      primary: Colors.white,
                      splashFactory: NoSplash.splashFactory,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    callback(false);
                  },
                  child: Container(
                    height: double.maxFinite,
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.8, vertical: 14.8),
                    decoration: const BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: SizedBox(
                      width: 23,
                      height: 23,
                      child: Image(
                        image: AssetImage('images/share_1.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
              onTap: () => {
                    Navigator.of(context).push(createRoute(
                        const FormPage(
                          stateValue: 0,
                        ),
                        300))
                  },
              child: Container(
                width: screenWidth > 530
                    ? screenWidth < 830
                        ? 500
                        : 360
                    : screenWidth,
                decoration: BoxDecoration(
                    color:
                        screenWidth > 830 ? Colors.transparent : Colors.white24,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                margin: EdgeInsets.only(
                    left: screenWidth > 830 ? 0 : 20,
                    top: 14,
                    right: 20,
                    bottom: screenWidth > 830 ? 0 : 20),
                padding: EdgeInsets.only(
                    left: screenWidth > 830 ? 0 : 15,
                    right: 15,
                    top: screenWidth > 830 ? 0 : 8,
                    bottom: screenWidth > 830 ? 0 : 8),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Suggest a question",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  screenWidth > 412 ? 20 : screenWidth * 0.05,
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
                ),
              )),
          widget
        ],
      ),
    );
  }
}
