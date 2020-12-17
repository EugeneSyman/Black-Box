import 'package:blackbox/Modules/User.dart';
import 'package:blackbox/UI/Elements/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/poly/v1.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

CurrentUser currentUser;
int codeReturn = 0;
String CodeReturn  = "";

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  String _nikeName = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Card(
          color: Colors.black26,
          child: Column(
            children: <Widget>[
              Image.asset('image/logo.png'),
              Padding(
                padding: EdgeInsets.only(
                    top: 4, bottom: 105, left: 10, right: 10),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        maxLength: 20,
                        decoration: InputDecoration(
                            labelText: 'NikeName:'
                        ),
                        onSaved: (input) => _nikeName = input,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Password:'
                        ),
                        onSaved: (input) => _password = input,
                        validator: (input) => codeReturn == 2 ? "Incorrect Password or Nikename" : null,
                        obscureText: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: RaisedButton(
                              color: Colors.white,
                              onPressed: _submit,
                              child: Text(
                                  'Sign in',
                                  style: TextStyle(color: Colors.black)
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],),
        ),
      ),);
  }

  void _submit() {
    formKey.currentState.save();
    print(_nikeName);
    print(_password);
    _login();
  }

  Future<void> _login() async {
    var methodChannel = MethodChannel("com.dartbase.blackbox");
    String data = await methodChannel.invokeMethod(
        "startBackgroundLogin",
        <String, dynamic>{
          'NikeName': _nikeName,
          'Password': _password
        });
    debugPrint(data);

    for (int i = 0; i < data.length; i++)
    {
      if(data[i] == '|'){
        CodeReturn = data[i+1];
        break;
      }
    }

    if(CodeReturn == '1'){
      debugPrint("Good");
      codeReturn = 1;
      CurrentUser(_nikeName, _password);
      Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNavigator()));
      formKey.currentState.validate();
    }
    else if (CodeReturn == '2'){
      debugPrint("Bad password");
      codeReturn = 2;
      formKey.currentState.validate();
    }
    else if (CodeReturn == '3'){
      codeReturn = 3;
      debugPrint("Insert");
    }
    else if (CodeReturn == '4'){
      debugPrint("Crash");
    }
  }
}