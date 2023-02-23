import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confab/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:social_share/social_share.dart';

extension HexColor on Color {
  String _generateAlpha({required int alpha, required bool withAlpha}) {
    if (withAlpha) {
      return alpha.toRadixString(16).padLeft(2, '0');
    } else {
      return '';
    }
  }

  String toHex({bool leadingHashSign = false, bool withAlpha = false}) =>
      '${leadingHashSign ? '#' : ''}'
              '${_generateAlpha(alpha: alpha, withAlpha: withAlpha)}'
              '${red.toRadixString(16).padLeft(2, '0')}'
              '${green.toRadixString(16).padLeft(2, '0')}'
              '${blue.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
}

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
  Map<dynamic, dynamic>? list = {};
  Future<void> _capturePng(padding, mode, callback) async {
    screenshotController
        .captureFromWidget(
            Container(
                width: 250,
                // color: Colors.white,
                padding: EdgeInsets.all(padding),
                height: 250,
                child: Container(
                    padding:
                        const EdgeInsets.only(top: 10, left: 14, right: 14),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(mode == 1 ? 0.0 : 8.0),
                      border: Border.all(
                          color: Colors.white,
                          width: 2,
                          style: BorderStyle.solid),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(-11, 11),
                            blurRadius: 0,
                            spreadRadius: 0.3)
                      ],
                      color: bgColor,
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: AutoSizeText(
                              (curQuestion['text']),
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  height: 1.5,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 30,
                                  fontFamily: 'Nunito',
                                  color: Colors.white),
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                "Confab",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ))
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
    if (list!.isEmpty) list = await SocialShare.checkInstalledAppsForShare();
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
        const SizedBox(
          height: 5,
        ),
        Container(
          decoration: const BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          width: 77,
          height: 3,
        ),
        const SizedBox(
          height: 12,
        ),
        const Text(
          'Share Question',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
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
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(
                          text:
                              "${curQuestion['text']}\n\nGenerated using Confab.\nCheck it out at https://confab.me"));
                      widget.pc.close();
                      Timer(const Duration(milliseconds: 500), () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(milliseconds: 1000),
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
                        _capturePng(20.0, 0, (path) {
                          widget.call(false);
                          SocialShare.shareInstagramStory(
                            appId: "649871976189994",
                            imagePath: path,
                            attributionURL: "https://confab.me",
                            backgroundTopColor:
                                '#${bgColor.toHex(withAlpha: false, leadingHashSign: false)}',
                            backgroundBottomColor:
                                '#${bgColor.toHex(withAlpha: false, leadingHashSign: false)}',
                          );
                        });
                        widget.pc.close();
                        widget.call(true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(milliseconds: 1000),
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
                const SizedBox(
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
                    onTap: () {
                      _capturePng(0.0, 1, (path) async {
                        widget.call(false);
                        if (Platform.isIOS) {
                          Share.shareXFiles([XFile(path)]);
                        } else {
                          Share.shareXFiles([XFile(path)],
                              text:
                                  "${curQuestion['text']}\n\nGenerated using Confab.\nCheck it out at https://confab.me");
                        }
                      });
                      widget.call(true);
                      widget.pc.close();
                    },
                    child: const shareIcon(
                      string: "More",
                      url: "images/more.png",
                    ))
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
        const SizedBox(
          height: 10,
        ),
        Text(
          string,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
