import 'package:blackbox/Modules/User.dart';
import 'package:blackbox/UI/Pages/%D1%81loud_storage_page.dart';
import 'package:blackbox/UI/Pages/main_page.dart';
import 'package:blackbox/UI/Pages/self_recorder_page.dart';
import 'package:blackbox/UI/Pages/storage_page.dart';
import 'package:flutter/material.dart';

class BottomNavigator extends StatefulWidget {

  @override
  _BottomNavigatorState createState() => _BottomNavigatorState();
}


class _BottomNavigatorState extends State<BottomNavigator> {

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MainPage(),
    SelfRecorderPage(),
    CloudStoragePage(),
    StoragePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.indigoAccent[400],
        unselectedItemColor: Colors.grey.withOpacity(.60),
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            title: Text('Main'),
            icon: Icon(Icons.mic),
          ),
          BottomNavigationBarItem(
            title: Text('Recorder'),
            icon: Icon(Icons.date_range),
          ),
          BottomNavigationBarItem(
            title: Text('Cloud'),
            icon: Icon(Icons.cloud_queue),
          ),
          BottomNavigationBarItem(
            title: Text('Storage'),
            icon: Icon(Icons.library_books),
          ),
        ],
      ),
    );
  }
}
