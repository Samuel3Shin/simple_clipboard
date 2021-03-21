import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _loadClipsFromSF();
  }

  @override
  void dispose() {
    _clipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Simple Clipboard'),
      ),
      body: Column(
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
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _displayTextInputDialog(context, null);
          }),
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
              // title: Text('Write here!'),
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
            title: Text('Are you sure?'),
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
            icon: Icon(Icons.edit),
            onPressed: () {
              _displayTextInputDialog(context, clip);
            },
          ),
          IconButton(
            // iconSize: 20.0,
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
      _items = (Clip.decode(prefs.getString('clips')));
      if (_items == null) {
        _items = List<Clip>();
      }
      print('items 개수: ${_items.length}');
    });
  }

  void _addStringToSF(String encodedItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('clips', encodedItems);
  }
}
