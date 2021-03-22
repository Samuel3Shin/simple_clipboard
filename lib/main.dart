import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:simple_clipboard/ad_manager.dart';
import 'package:firebase_admob/firebase_admob.dart';

void main() {
  runApp(MyApp());
}

class Clip {
  String title;
  Clip(this.title);

  factory Clip.fromJson(Map<String, dynamic> jsonData) {
    return Clip(jsonData['title']);
  }

  static Map<String, dynamic> toMap(Clip clip) => {
        'title': clip.title,
      };

  static String encode(List<Clip> clips) => json.encode(
        clips.map<Map<String, dynamic>>((clip) => Clip.toMap(clip)).toList(),
      );

  static List<Clip> decode(String encodedItems) =>
      (json.decode(encodedItems) as List<dynamic>)
          .map<Clip>((item) => Clip.fromJson(item))
          .toList();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: ClipListPage(),
    );
  }
}

class ClipListPage extends StatefulWidget {
  @override
  _ClipListPageState createState() => _ClipListPageState();
}

class _ClipListPageState extends State<ClipListPage> {
  var _items = List<Clip>();
  var _clipController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  BannerAd _bannerAd;

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  @override
  void initState() {
    _loadClipsFromSF();
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.fullBanner,
    );

    _loadBannerAd();
  }

  @override
  void dispose() {
    _clipController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Simple Clipboard'),
        // trailing: CupertinoButton(
        //   child: Icon(CupertinoIcons.add),
        //   onPressed: () {},
        //   padding: EdgeInsets.zero,
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: ListTile.divideTiles(
                  context: context,
                  tiles: _items.map((clip) => _buildItemWidget(clip)).toList(),
                ).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _displayTextInputDialog(context, null);
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context, Clip clip) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Form(
            key: _formKey,
            child: AlertDialog(
              title: clip == null ? Text('Add') : Text('Edit'),
              content: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  // border: OutlineInputBorder(),
                  hintText: 'Write here!',
                ),
                controller: _clipController
                  ..text = clip == null ? "" : clip.title,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Value Can\'t be Empty';
                  }
                  return null;
                },
              ),
              actions: <Widget>[
                FlatButton(
                  // color: Colors.red,
                  textColor: Colors.black,
                  child: Text('CANCEL'),
                  onPressed: () {
                    _clipController.text = "";
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  // color: Colors.green,
                  textColor: Colors.black,
                  child: Text('OK'),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      if (clip == null) {
                        _addClip(Clip(_clipController.text.trimLeft()));
                      } else {
                        _editClip(clip, _clipController.text.trimLeft());
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _displayDeleteConfirmDialog(
      BuildContext context, Clip clip) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete'),
            content: Text('${clip.title}'),
            actions: <Widget>[
              FlatButton(
                // color: Colors.red,
                textColor: Colors.black,
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                // color: Colors.green,
                textColor: Colors.black,
                child: Text('OK'),
                onPressed: () {
                  _deleteClip(clip);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget _buildItemWidget(Clip clip) {
    return ListTile(
      onTap: () {
        Clipboard.setData(new ClipboardData(text: "${clip.title}"));
        Fluttertoast.showToast(
            msg: "Copied",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black45,
            textColor: Colors.white,
            fontSize: 16.0);
      },
      title: Text(
        clip.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Wrap(
        children: <Widget>[
          IconButton(
            iconSize: 16.0,
            alignment: Alignment.centerRight,
            icon: Icon(Icons.edit),
            onPressed: () {
              _displayTextInputDialog(context, clip);
            },
          ),
          IconButton(
            iconSize: 16.0,
            alignment: Alignment.centerRight,
            icon: Icon(Icons.delete),
            onPressed: () {
              _displayDeleteConfirmDialog(context, clip);
            },
          ),
        ],
      ),
    );
  }

  void _addClip(Clip clip) {
    setState(() {
      _items.add(clip);
      _clipController.text = "";
      _addStringToSF(Clip.encode(_items));
      // _loadClipsFromSF();
    });
  }

  void _editClip(Clip clip, String str) {
    setState(() {
      clip.title = str;
      _clipController.text = "";
      _addStringToSF(Clip.encode(_items));
      // _loadClipsFromSF();
    });
  }

  void _deleteClip(Clip clip) {
    setState(() {
      _items.remove(clip);
      _addStringToSF(Clip.encode(_items));
      // _loadClipsFromSF();
    });
  }

  void _loadClipsFromSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _items = prefs.getString('clips') == null
          ? List<Clip>()
          : Clip.decode(prefs.getString('clips'));
      // _items = (Clip.decode(prefs.getString('clips')));
      // if (_items == null) {
      //   _items = List<Clip>();
      // }
      print('items 개수: ${_items.length}');
    });
  }

  void _addStringToSF(String encodedItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('clips', encodedItems);
  }

  double _getSmartBannerHeight() {
    return 200.0;
    // MediaQueryData mediaScreen = MediaQuery.of(context);
    // double dpHeight = mediaScreen.orientation == Orientation.portrait
    //     ? mediaScreen.size.height
    //     : mediaScreen.size.width;
    // print("Device height: $dpHeight");
    // if (dpHeight <= 400.0) {
    //   return 32.0;
    // }
    // if (dpHeight > 720.0) {
    //   return 90.0;
    // }
    // return 50.0;
  }
}
