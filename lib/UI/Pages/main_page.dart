import 'package:blackbox/Modules/User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' as io;
import 'dart:async';

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blackbox/UI/Elements/navigation.dart';

class MainPage extends StatefulWidget {

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  String _currentUser = "";
  String _serviceState = "";

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

  Future<String> _setListeningService() async {
    _serviceState = "";
    var methodChannel = MethodChannel("com.dartbase.blackbox");
    String data = await methodChannel.invokeMethod(
        "setListeningService");

    for (int i = 0; i < data.length; i++)
    {
      if(data[i] != "|"){
        _serviceState += data[i];
      }
      else if(data[i] == "|")
        break;
    }
    debugPrint("ServiceState: " + _serviceState);
    return _serviceState;
  }

  Future<String> _getListeningService() async {
    _serviceState = "";
    var methodChannel = MethodChannel("com.dartbase.blackbox");
    String data = await methodChannel.invokeMethod(
        "getListeningService");

    for (int i = 0; i < data.length; i++)
    {
      if(data[i] != "|"){
        _serviceState += data[i];
      }
      else if(data[i] == "|")
        break;
    }
    debugPrint("Get Service State: " + _serviceState);
    return _serviceState;
  }


  /// Player ////////////////////////////////////////
  FlutterAudioRecorder _recorder;
  Recording _recording;
  Timer _t;
  Widget _buttonIcon = Icon(Icons.do_not_disturb_on);
  String _alert;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _prepare();
    });
  }

  void _optButton() async {

    await _setListeningService();

    if (_serviceState == 'false') {
      setState(() {
        color = Colors.red;
        scaffoldKey.currentState.showSnackBar(snackBarPayse);
      });
    }
    else {
      setState(() {
        color = Colors.green;
        scaffoldKey.currentState.showSnackBar(snackbarReady);
      });
    }
  }

  void _opt() async {

    switch (_recording.status) {
      case RecordingStatus.Initialized:
        {
          await _startRecording();
          visio = 0;
          break;
        }
      case RecordingStatus.Recording:
        {
          await _stopRecording();
          visio = 10;
          break;
        }
      case RecordingStatus.Stopped:
        {
          await _prepare();
          break;
        }

      default:
        break;
    }

    // 刷新按钮
    setState(() {
      _buttonIcon = _playerIcon(_recording.status);
    });
  }

  Future _init() async {
    String customPath = '/' + _currentUser + "- Black Box -";
    io.Directory appDocDirectory;
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }

    // can add extension like ".mp4" ".wav" ".m4a" ".aac"
    customPath = appDocDirectory.path +
        customPath +
        DateTime.now().millisecondsSinceEpoch.toString();

    // .wav <---> AudioFormat.WAV
    // .mp4 .m4a .aac <---> AudioFormat.AAC
    // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.

    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.AAC, sampleRate: 22050);
    await _recorder.initialized;
  }

  Future _prepare() async {
    await _getCurrentUser();
    await _getListeningService();
    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      await _init();
      var result = await _recorder.current();
      setState(() {
        _recording = result;
        _buttonIcon = _playerIcon(_recording.status);
        _alert = "";
      });
    } else {
      setState(() {
        _alert = "Permission Required.";
      });
    }
  }

  Future _startRecording() async {
    await _recorder.start();
    var current = await _recorder.current();
    setState(() {
      _recording = current;
    });

    _t = Timer.periodic(Duration(milliseconds: 10), (Timer t) async {
      var current = await _recorder.current();
      setState(() {
        _recording = current;
        _power = _GetPower();
        _t = t;
      });
    });
  }

  Future _stopRecording() async {
    var result = await _recorder.stop();
    _t.cancel();

    setState(() {
      _recording = result;
    });
  }

  AudioPlayer player;

  void _play() {
    player = AudioPlayer();
    player.play(_recording.path, isLocal: true);
  }


  Widget _playerIcon(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.Initialized:
        {
          return Icon(Icons.fiber_manual_record);
        }
      case RecordingStatus.Recording:
        {
          return Icon(Icons.stop);
        }
      case RecordingStatus.Stopped:
        {
          return Icon(Icons.replay);
        }
      default:
        return Icon(Icons.do_not_disturb_on);
    }
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbarReady = const SnackBar(content: Text('Keystroke сapture Enabled'));
  final SnackBar snackBarPayse = const SnackBar(content: Text('Keystroke capture Disabled!'));
  Color color = Colors.red;
  int visio = 10;

  double _GetPower(){
    double rez = _recording.metering.averagePower * (-0.01);
    return  rez + visio;
  }

  double _power = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Main'),
        actions: <Widget>[
          IconButton(
            icon: new Icon(
                Icons.album,
                color: color
            ),
            tooltip: 'Key entry',
            onPressed: _optButton,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 0.10,left: 0.10, right:0.10, bottom: 10),
              child: LinearProgressIndicator(
                value: _power,
                backgroundColor: Colors.blue,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Text(
                    'File',
                    style: Theme
                        .of(context)
                        .textTheme
                        .title,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${_recording?.path ?? "-"}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body1,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Duration',
                    style: Theme
                        .of(context)
                        .textTheme
                        .title,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${_recording?.duration ?? "-"}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body1,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Metering Level - Average Power',
                    style: Theme
                        .of(context)
                        .textTheme
                        .title,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${_recording?.metering?.averagePower ?? "-"}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body1,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Status',
                    style: Theme
                        .of(context)
                        .textTheme
                        .title,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${_recording?.status ?? "-"}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body1,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    child: Text('Play'),
                    disabledTextColor: Colors.white,
                    disabledColor: Colors.grey.withOpacity(0.5),
                    onPressed: _recording?.status == RecordingStatus.Stopped
                        ? _play
                        : null,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    '${_alert ?? ""}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .title
                        .copyWith(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: _opt,
          child: _buttonIcon
      ),
    );
  }
}
