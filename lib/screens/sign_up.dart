import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe/models/homepage_provider.dart';
import 'package:shoe/screens/homepage.dart';
import 'package:shoe/screens/loading.dart';
import 'package:shoe/screens/sign_in.dart';

class SignUpUserScreen extends StatefulWidget {
  @override
  _SignUpUserScreenState createState() => _SignUpUserScreenState();
}

class _SignUpUserScreenState extends State<SignUpUserScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: loading
          ? LoadingScreen()
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/logo.png',
                                      height: height * (0.180),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Heaven for shoes lovers !',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Roboto',
                                        letterSpacing: 3,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: height * (0.080),
                              ),
                              getTextField(
                                  height, 'Name', _nameController, false),
                              getTextField(
                                  height, 'Email', _emailController, false),
                              getTextField(height, 'Password',
                                  _passwordController, true),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already registered ? ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: height * (0.019),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SignInUserScreen()));
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(7),
                                        child: Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: height * (0.019),
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                        Ink(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (_validateInformation()) {
                                _signUpUser(context);
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'Please enter valid details',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              }
                            },
                            child: Container(
                              height: height * 0.062,
                              width: width * 0.8,
                              child: Center(
                                child: Text('Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 1,
                                      fontSize: height * 0.018,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget getTextField(double height, String labelText,
      TextEditingController controller, bool obsecureText) {
    return Container(
      margin: EdgeInsets.only(top: height * 0.015, bottom: height * 0.015),
      height: height * (0.068),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          color: Colors.black,
          letterSpacing: 2,
        ),
        cursorColor: Colors.black54,
        obscureText: obsecureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.black54,
              width: 2.0,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: TextStyle(
            color: Colors.black54,
            letterSpacing: 2,
          ),
          labelText: labelText,
        ),
      ),
    );
  }

  bool _validateInformation() {
    if (_nameController.text.trim().length <= 2 ||
        !_emailController.text.trim().contains('@gmail.com') ||
        _passwordController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  _signUpUser(BuildContext context) async {
    try {
      if (mounted) {
        setState(() {
          loading = true;
        });
      }
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim())
          .then((value) async {
        DocumentReference users = FirebaseFirestore.instance
            .collection('users')
            .doc(_emailController.text.trim());
        await users.set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim()
        }).then((value) async {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString('name', _nameController.text.trim());
          pref.setString('email', _emailController.text.trim());
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                        create: (context) => HomepageProvider(),
                        child: HomePageScreen(),
                      )),
              (route) => false);
        });
      }).catchError((e) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      });
    } catch (FirebaseAuthException) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      Fluttertoast.showToast(
        msg: FirebaseAuthException.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
