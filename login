import 'package:adimn_go/screens/home_screen.dart';
import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_services.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final _formKey = GlobalKey<FormState>();
  FirebaseServices _services = FirebaseServices();
  var _usernameTextController = TextEditingController();
  var _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ArsProgressDialog progressDialog = ArsProgressDialog(context,
        blur: 2,
        backgroundColor: Colors.amberAccent.withOpacity(.9),
        animationDuration: Duration(milliseconds: 500));
    _login({username, password}) async {
      progressDialog.show();
      _services.getAdminCrendtials(username).then((value) async {
        if (value.exists) {
          if(value.data()['username'] == username){
            if(value.data()['password'] == password){

              try{
                UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
                if(userCredential!=null){
                  progressDialog.dismiss();
                  Navigator.pushReplacementNamed(context, HomeScreen.id);
                }

              }catch(e) {
                progressDialog.dismiss();
                _showMyDialog(title: 'Login', message: '${e.toString()}');
              }

              return;
            }
            progressDialog.dismiss();
            _showMyDialog(
                title: 'Incorrect Password',
                message: 'Username you have entered is incorrect');
            return;
          }
          progressDialog.dismiss();
          _showMyDialog(
              title: 'Invalid Username',
              message: 'Username you have entered is incorrect');
        }



      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('N-Go'),
      ),
      body: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Center(child: Text('Connection Failed'));
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.black54, Colors.amberAccent])),
              child: Center(
                child: Container(
                  width: 300,
                  height: 400,
                  child: Card(
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/logo1.png',
                                    height: 91,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'N-Go App Admin',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: _usernameTextController,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter User Name';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'User Name',
                                      hintText: 'User Name',
                                      icon: Icon(Icons.person),
                                      contentPadding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.amberAccent),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.amberAccent,
                                            width: 2),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: _passwordTextController,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter Password';
                                      }
                                      if (value.length < 6) {
                                        return 'Minimum 6 characters';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Minimum 6 characters',
                                      hintText: 'Password',
                                      icon: Icon(Icons.vpn_key_rounded),
                                      contentPadding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.amberAccent),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.amberAccent,
                                            width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: FlatButton(
                                      onPressed: () async {
                                        if (_formKey.currentState.validate()) {
                                          _login(
                                            username: _usernameTextController.text,
                                            password: _passwordTextController.text,
                                          );
                                        }
                                      },
                                      color: Colors.amberAccent,
                                      child: Text('LOGIN')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _showMyDialog({message, title}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
