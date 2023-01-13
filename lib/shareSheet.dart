import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confab/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:social_share/social_share.dart';

class shareSheet extends StatefulWidget {
  shareSheet({Key? key, required this.pc, required this.call})
      : super(key: key);
  late PanelController pc;
  late ValueSetter<bool> call;
  @override
  _shareSheetState createState() => _shareSheetState();
}

class _shareSheetState extends State<shareSheet> {
  ScreenshotController screenshotController = ScreenshotController();
  late double pixelRatio;
  Map<dynamic, dynamic>? list;
  Future<void> _capturePng(padding, callback) async {
    screenshotController
        .captureFromWidget(
            Container(
                width: 250,
                // color: Colors.white,
                height: 250,
                child: Container(
                    padding:
                        const EdgeInsets.only(top: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(8),
                      // border: Border.all(
                      //     color: Colors.white,
                      //     width: 4,
                      //     style: BorderStyle.solid),
                      // adow: [
                      //   BoxShadow(
                      //       cboxSholor: Colors.black.withOpacity(0.2),
                      //       offset: Offset.zero,
                      //       blurRadius: 15,
                      //       spreadRadius: 1)
                      // ],
                      color: bgColor,
                    ),
                    child: Stack(children: <Widget>[
                      AutoSizeText(
                        (curQuestion['text']),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                            fontSize: curQuestion['text'].length < 30 ? 32 : 25,
                            fontFamily: 'Nunito',
                            color: Colors.white),
                        maxLines: 4,
                      ),
                      const Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Confab",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              )))
                    ]))),
            pixelRatio: pixelRatio * 2.5)
        .then((capturedImage) async {
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/confab.png').create();
      await imagePath.writeAsBytes(capturedImage);
      callback(imagePath.path);
    });
  }

  void getList() async {
    list = await SocialShare.checkInstalledAppsForShare();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getList();
    pixelRatio = MediaQuery.of(context).devicePixelRatio;

    var width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          width: 77,
          height: 3,
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          'Share Question',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      SocialShare.copyToClipboard(
                          "${curQuestion['text']}\n\nGenerated using Confab. Install now!\nhttps://confab.me");
                      widget.pc.close();
                      Timer(Duration(milliseconds: 500), () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(milliseconds: 1000),
                          backgroundColor: Colors.white,
                          content: Text(
                            'Copied to clipboard.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                color: bgColor),
                          ),
                        ));
                      });
                    },
                    child: const shareIcon(
                      string: "Copy to\nClipboard",
                      url: "images/copy.png",
                    )),
                SizedBox(
                  height: 30,
                ),
                // GestureDetector(
                //     onTap: () {
                //       if (list!['twitter']) {
                //         SocialShare.shareTwitter(
                //             "${curQuestion['text']}\n\nGenerated using Confab. Install now!",
                //             hashtags: ["confab"],
                //             url: "https://confab.com");
                //         widget.pc.close();
                //       } else {
                //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //           duration: Duration(milliseconds: 1000),
                //           content: Text(
                //             'App not installed',
                //             textAlign: TextAlign.center,
                //             style: TextStyle(
                //                 fontFamily: 'Lato',
                //                 fontSize: 16,
                //                 color: bgColor),
                //           ),
                //         ));
                //       }
                //     },
                //     child: shareIcon(
                //       string: "Twitter",
                //       url: "images/twitter.png",
                //     )),
                GestureDetector(
                  onTap: () {
                    if (list!['instagram']) {
                      _capturePng(20, (path) {
                        widget.call(false);
                        FlutterShareMe().shareToInstagram(imagePath: path);
                      });
                      widget.pc.close();
                      widget.call(true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(milliseconds: 1000),
                        content: Text(
                          'App not installed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Lato', fontSize: 16, color: bgColor),
                        ),
                      ));
                    }
                  },
                  child: shareIcon(
                    string: "Instagram",
                    url: "images/instagram.png",
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
            SizedBox(
              width: width > 380 ? width * 0.13 : width * 0.10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    onTap: () async {
                      if (list!['instagram']) {
                        _capturePng(20, (path) {
                          widget.call(false);
                          SocialShare.shareInstagramStory(
                            path,
                            backgroundTopColor:
                                '#${bgColor.value.toRadixString(16)}',
                            backgroundBottomColor:
                                '#${bgColor.value.toRadixString(16)}',
                          );
                        });
                        widget.pc.close();
                        widget.call(true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(milliseconds: 1000),
                          content: Text(
                            'App not installed',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                color: bgColor),
                          ),
                        ));
                      }
                    },
                    child: const shareIcon(
                      string: "Instagram\nStories",
                      url: "images/instagram.png",
                    )),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                    onTap: () {
                      _capturePng(20, (path) {
                        widget.call(false);
                        SocialShare.shareFacebookStory(
                                path,
                                '#${bgColor.value.toRadixString(16)}',
                                '#${bgColor.value.toRadixString(16)}',
                                "https://confab.me")
                            .then((status) {
                          if (status == "error") {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(milliseconds: 1000),
                              backgroundColor: Colors.white,
                              content: Text(
                                'App not installed',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 16,
                                    color: bgColor),
                              ),
                            ));
                          }
                        });
                      });
                      widget.pc.close();
                      widget.call(true);
                    },
                    child: shareIcon(
                      string: "Facebook\nStories",
                      url: "images/facebook.png",
                    )),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
            SizedBox(
              width: width > 380 ? width * 0.13 : width * 0.10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    if (list!['whatsapp']) {
                      _capturePng(0, (path) {
                        widget.call(false);
                        FlutterShareMe().shareToWhatsApp(
                            imagePath: path,
                            msg:
                                "${curQuestion['text']}\n\nGenerated using Confab. Install now!\nhttps://confab.me");
                      });
                      widget.pc.close();
                      widget.call(true);
                      // SocialShare.shareWhatsapp(
                      //     "${curQuestion['text']}\n\nGenerated using Confab. Install now!\nhttps://confab.com");
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(milliseconds: 1000),
                        content: Text(
                          'App not installed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Lato', fontSize: 16, color: bgColor),
                        ),
                      ));
                    }
                  },
                  child: shareIcon(
                    string: "Whatsapp\n",
                    url: "images/whatsapp.png",
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                // GestureDetector(
                //     onTap: () {
                //       SocialShare.shareSms(
                //           "${curQuestion['text']}\n\nGenerated using Confab. Install now!\n",
                //           url: "https://confab.com");
                //     },
                //     child: shareIcon(
                //       string: "SMS",
                //       url: "images/sms.png",
                //     )),
                GestureDetector(
                    onTap: () {
                      _capturePng(20, (path) async {
                        widget.call(false);
                        Share.shareFiles(['$path'],
                            text:
                                "${curQuestion['text']}\n\nGenerated using Confab. Install now!\nhttps://confab.me");
                        // SocialShare.shareOptions(
                        //   "${curQuestion['text']}\n\nGenerated using Confab. Install now!\nhttps://confab.com",
                        //   imagePath: path);
                      });
                      widget.call(true);
                      widget.pc.close();
                    },
                    child: shareIcon(
                      string: "More",
                      url: "images/more.png",
                    )),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class shareIcon extends StatelessWidget {
  final String string;
  final String url;
  const shareIcon({Key? key, required this.string, required this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 50,
          height: 50,
          child: Image(
            image: AssetImage(url),
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          string,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
