import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:confab/colors.dart';
import 'package:confab/form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

late var curQuestion = "";
late var curTip = "";

var allQues = [];
var smallQues = [];
var casualQues = [];
var deepQues = [];
var partyQues = [];
var tips = [];
final bgColorsArray = [
  CustomColors.bg1,
  CustomColors.bg2,
  CustomColors.bg3,
  CustomColors.bg4
];
late var bgColor = bgColorsArray[Random().nextInt(4)];

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
      if (mounted) Navigator.pushReplacement(context, createRoute(Home()));
    });
  }

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    double begin = 1;
    double end = 0;
    const curve = Curves.ease;
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
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
              return const MaterialApp(home: Text("Something Went Wrong"));
            }

            if (snapshot.connectionState == ConnectionState.done) {
              FirebaseFirestore.instance
                  .collection('questions')
                  .get()
                  .then((QuerySnapshot querySnapshot) {
                if (querySnapshot.docs.isNotEmpty) {
                  final allData =
                      querySnapshot.docs.map((doc) => doc.data()).toList();
                  smallQues = allData[0]['small'];
                  casualQues = allData[0]['casual'];
                  deepQues = allData[0]['deep'];
                  partyQues = allData[0]['party'];
                  tips = allData[1]['deep'];
                  allQues = smallQues + casualQues + deepQues + partyQues;
                  curQuestion = allQues[Random().nextInt(allQues.length)];
                  curTip = tips[Random().nextInt(tips.length)];
                  navigate();
                }
              });
            }

            return const SplashScreenCustom();
          },
        ),
      ),
    );
  }
}

Route createRoute(Widget widget) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 400),
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
  var activeVal = 0;
  var screenWidth;
  var menuColor1 = Colors.black;
  var menuColor2 = Colors.black38;

  var menuColor3 = Colors.black38;

  var menuColor4 = Colors.black38;
  var menuColor5 = Colors.black38;

  void updateMenu(value) {
    switch (value) {
      case 1:
        setState(() {
          menuColor1 = Colors.black;
          menuColor2 = Colors.black38;
          menuColor3 = Colors.black38;
          menuColor4 = Colors.black38;
          menuColor5 = Colors.black38;
        });
        break;
      case 2:
        setState(() {
          menuColor1 = Colors.black38;
          menuColor2 = Colors.black;
          menuColor3 = Colors.black38;
          menuColor4 = Colors.black38;
          menuColor5 = Colors.black38;
        });
        break;
      case 3:
        setState(() {
          menuColor1 = Colors.black38;
          menuColor2 = Colors.black38;
          menuColor3 = Colors.black;
          menuColor4 = Colors.black38;
          menuColor5 = Colors.black38;
        });
        break;
      case 4:
        setState(() {
          menuColor1 = Colors.black38;
          menuColor2 = Colors.black38;
          menuColor3 = Colors.black38;
          menuColor4 = Colors.black;
          menuColor5 = Colors.black38;
        });
        break;
      case 5:
        setState(() {
          menuColor1 = Colors.black38;
          menuColor2 = Colors.black38;
          menuColor3 = Colors.black38;
          menuColor4 = Colors.black38;
          menuColor5 = Colors.black;
        });
        break;
    }
  }

  void setBgColor() {
    var prev = bgColorsArray.indexOf(bgColor);
    var next;
    do {
      next = Random().nextInt(4);
    } while (next == prev);
    setState(() {
      bgColor = bgColorsArray[next];
    });
  }

  void changeTip() {
    var prev = tips.indexOf(curTip);
    var next;
    do {
      next = Random().nextInt(tips.length);
    } while (next == prev);
    setState(() {
      curTip = tips[next];
    });
  }

  void changeQuestion(category, gen) {
    var array = [];
    if (category == 2) {
      array = smallQues;
    } else if (category == 5) {
      array = deepQues;
    } else if (category == 3) {
      array = casualQues;
    } else if (category == 4) {
      array = partyQues;
    } else {
      array = allQues;
    }

    var prev = array.indexOf(curQuestion);
    var next;
    do {
      next = Random().nextInt(array.length);
    } while (next == prev);
    setState(() {
      curQuestion = array[next];

      if (curQuestion.length < 80)
        questionFontSize = screenWidth * 0.1;
      else if (curQuestion.length > 80 && curQuestion.length < 90)
        questionFontSize = screenWidth * 0.09;
      else if (curQuestion.length > 90) questionFontSize = screenWidth * 0.085;
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

    if (curQuestion.length < 80)
      questionFontSize = screenWidth * 0.1;
    else if (curQuestion.length > 80 && curQuestion.length < 90)
      questionFontSize = screenWidth * 0.09;
    else if (curQuestion.length > 90) questionFontSize = screenWidth * 0.085;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
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
                  "Confab",
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
                          changeTip();

                          setBgColor();
                          switch (value) {
                            case 1:
                              setState(() {
                                menuColor1 = Colors.black;
                                menuColor2 = Colors.black38;
                                menuColor3 = Colors.black38;
                                menuColor4 = Colors.black38;
                                menuColor5 = Colors.black38;
                              });
                              break;
                            case 2:
                              setState(() {
                                menuColor1 = Colors.black38;
                                menuColor2 = Colors.black;
                                menuColor3 = Colors.black38;
                                menuColor4 = Colors.black38;
                                menuColor5 = Colors.black38;
                              });
                              break;
                            case 3:
                              setState(() {
                                menuColor1 = Colors.black38;
                                menuColor2 = Colors.black38;
                                menuColor3 = Colors.black;
                                menuColor4 = Colors.black38;
                                menuColor5 = Colors.black38;
                              });
                              break;
                            case 4:
                              setState(() {
                                menuColor1 = Colors.black38;
                                menuColor2 = Colors.black38;
                                menuColor3 = Colors.black38;
                                menuColor4 = Colors.black;
                                menuColor5 = Colors.black38;
                              });
                              break;
                            case 5:
                              setState(() {
                                menuColor1 = Colors.black38;
                                menuColor2 = Colors.black38;
                                menuColor3 = Colors.black38;
                                menuColor4 = Colors.black38;
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
                              horizontal: 0.037 * screenWidth, vertical: 15.5),
                          decoration: const BoxDecoration(
                              color: Colors.white24,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6))),
                          child: SizedBox(
                            width: 0.0576 * screenWidth,
                            height: 0.0576 * screenWidth,
                            child: Image(
                              image: AssetImage('images/category_icon.png'),
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
                                changeTip();

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
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              (curQuestion),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  height: 1.5,
                                  fontWeight: FontWeight.w700,
                                  fontSize: questionFontSize,
                                  color: Colors.white),
                            ),
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
                )
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
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 3),
                      child: ElevatedButton(
                        onPressed: () {
                          setBgColor();
                          changeQuestion(activeVal, true);
                          changeTip();
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
                              Navigator.of(context).push(createRoute(FormPage(
                                stateValue: 0,
                              )))
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
            )
          ],
        ),
      ),
    );
  }
}
