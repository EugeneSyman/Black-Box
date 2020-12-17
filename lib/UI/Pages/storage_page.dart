import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';

List<FileSystemEntity> items;

int counter = 0;

String _currentUser = "";
String _path = "";

class StoragePage extends StatefulWidget {
  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _init();
    });
  }

  Future _getCurrentUser() async {
    _currentUser = "";
    var methodChannel = MethodChannel("com.dartbase.blackbox");
    String data = await methodChannel.invokeMethod(
        "getCurrentUser");

    for (int i = 0; i < data.length; i++)
    {
      if(data[i] != "|"){
        _currentUser += data[i];
      }
      else if(data[i] == "|")
        break;
    }
    debugPrint("CurrentUser: " + _currentUser);
  }

  Future _init() async {
    _getCurrentUser();

    io.Directory appDocDirectory;
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }

    _path = appDocDirectory.path;

    setState(() {
      items = appDocDirectory.listSync(recursive: true, followLinks: false);

      for(int i = 0; i < items.length; i++){
        if (!items[i].path.contains(appDocDirectory.path + "/" + _currentUser)){
          items.removeAt(i);
        }
      }

      counter = items.length;
    });
  }

  void _showSnackBar(String str) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("$str")));
  }

  Future<void> _deleteItem(String filePath, int id) async {
    File file = new File(filePath);
    await file.delete();
    _showSnackBar("The entry has been deleted!");
    setState(() {
      items.removeAt(id);
    });
  }

  AudioPlayer player;

  void _play(FileSystemEntity item) {
    player = AudioPlayer();
    player.play(item.path, isLocal: true);
  }


  void _pause() {
    player.stop();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Storage"),
      ),
      body: counter > 0
          ? ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: Container(
              margin: const EdgeInsets.only(top: 0.5),
              color: Colors.black,
              child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigoAccent,
                    child: Text(
                      index.toString(),
                      style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  title: Text(
                    'Tile : ' + items[index].path.replaceFirst(_path + "/", ""),
                    style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.25),
                  ),
                  subtitle: Text('<< ------------------- Black Box ------------------- >>')
              ),
            ),
            actions: <Widget>[
              IconSlideAction(
                caption: 'Play',
                color: Colors.green,
                icon: Icons.play_arrow,
                onTap: () => _play(items[index]),
              ),
              IconSlideAction(
                caption: 'Pause',
                color: Colors.orangeAccent,
                icon: Icons.pause,
                onTap: () => _pause(),
              ),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'More',
                color: Colors.black45,
                icon: Icons.more_horiz,
                onTap: () => _showSnackBar('More'),
              ),
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => _deleteItem(items[index].path, index),
              ),
            ],
          );
        },
      )
          : Center(child: const Text('No items')),
    );
  }
}
