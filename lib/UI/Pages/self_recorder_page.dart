import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class SelfRecorderPage extends StatefulWidget {
  @override
  _SelfRecorderPageState createState() => _SelfRecorderPageState();
}

class _SelfRecorderPageState extends State<SelfRecorderPage> {

  String _currentUser = "";

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

  void _BackgroundChannel() async {
    DateTime _timeStart = new DateTime(
        _dateTime.year
        , _dateTime.month
        , _dateTime.day
        , _timeOfDay.hour
        , _timeOfDay.minute
    );

    DateTime difTime = new DateTime(_currentTime.year,_currentTime.month,_currentTime.day);

    DateTime periodRange = new DateTime(_currentTime.year,_currentTime.month,_currentTime.day,_period.hour,_period.minute);

    Duration differenceDate = _timeStart.difference(_currentTime);
    Duration differencePeriod = periodRange.difference(difTime);

    debugPrint(differenceDate.inMinutes.toString());
    debugPrint(differencePeriod.inMinutes.toString());

    String TimeStart = differenceDate.inMinutes.toString();
    String Period = differencePeriod.inMinutes.toString();

    await _getCurrentUser();

    String customPath = '/' + _currentUser + "-Black Box-selfRecorder";
    io.Directory appDocDirectory;
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }

    // can add extension like ".mp4" ".wav" ".m4a" ".aac"
    customPath = appDocDirectory.path +
        customPath +
        DateTime.now().millisecondsSinceEpoch.toString() + ".m4a";

    var methodChannel = MethodChannel("com.dartbase.blackbox");
    String data = await methodChannel.invokeMethod(
        "createBackgroundWorker",
        <String, dynamic>{
          'TimeStart': TimeStart,
          'Period': Period,
          'Path': customPath,
        });
    debugPrint(data);
  }

  ///
  DateTime _dateTime = new DateTime.now();
  TimeOfDay _timeOfDay = new TimeOfDay.now();
  TimeOfDay _period = new TimeOfDay.now();

  DateTime _currentTime = new DateTime.now();

  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat _timeFormat = DateFormat('HH:MM');
  ///


  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picker = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: new DateTime.now(),
        lastDate: new DateTime(DateTime.now().year + 1));

    if (picker != null && picker != _dateTime) {
      print("Date selected: ${_dateTime.toString()}");
      setState(() {
        _dateTime = picker;
      });
    }
  }

  Future<Null> _selectTime(BuildContext context) async {

    final TimeOfDay picker = await showTimePicker(
        context: context,
        initialTime: _timeOfDay
    );

    if (picker != null && picker != _timeOfDay) {
      print("Date selected: ${_timeOfDay.toString()}");
      setState(() {
        _timeOfDay = picker;
      });
    }
  }

  Future<Null> _selectPeriod(BuildContext context) async {
    DateTime defTime = new DateTime(_currentTime.year,_currentTime.month,_currentTime.day);
    TimeOfDay defPeriod = new TimeOfDay.fromDateTime(defTime);

    final TimeOfDay picker = await showTimePicker(
        context: context,
        initialTime: defPeriod,
    );

    if (picker != null && picker != _period) {
      print("Date selected: ${_period.toString()}");
      setState(() {
        _period = picker;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recorder"),
      ),
      body: new Center(
        child: Column(

          children: [
            FlatButton(
              minWidth: 400,
              color: Colors.blue,
              onPressed: () {
                _selectDate(context);
              },
              child: Text(
                'Start Date ${_dateFormat.format(_dateTime)}',
                style: Theme
                    .of(context)
                    .textTheme
                    .title,
              ),
            ),
            FlatButton(
              minWidth: 400,
              color: Colors.blue,
              onPressed: () {
                _selectTime(context);
              },
              child: Text(
                'Start time - ${_timeOfDay.hour}:${_timeOfDay.minute}',
                style: Theme
                    .of(context)
                    .textTheme
                    .title,
              ),
            ),
            FlatButton(
              minWidth: 400,
              color: Colors.blue,
              onPressed: () {
                _selectPeriod(context);
              },
              child: Text(
                'Period - ${_period.hour}:${_period.minute}',
                style: Theme
                    .of(context)
                    .textTheme
                    .title,
              ),
            ),
            FlatButton(
              minWidth: 400,
              color: Colors.blue,
              onPressed: () {
                _BackgroundChannel();
              },
              child: Text(
                'Set record',
                style: Theme
                    .of(context)
                    .textTheme
                    .title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
