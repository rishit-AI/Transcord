import 'package:flutter/material.dart';
import 'register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homescreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id='login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;


  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  final _auth = FirebaseAuth.instance;
  String _name;
  String _email;
  String _password;
  String pass_reset;
  String errorMess;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.deepPurple, Colors.transparent],
          ).createShader(rect),
          blendMode: BlendMode.darken,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/unnamed.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.darken),
              ),
            ),
          ),
        ),
        ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                Flexible(
                  child: Center(
                    child: Text(
                      'Transcord',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width:MediaQuery.of(context). size.width * 0.8,
                              decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Icon(
                                      Icons.mail_outlined,
                                      size: 28,
                                      color:Colors.white,
                                    ),
                                  ),
                                  Container(
                                    width:MediaQuery.of(context). size.width * 0.6,
                                    child: TextFormField(
                                      validator: (value){
                                        if(value.trim().isEmpty){
                                          return "Required field";
                                        }
                                        setState(() {
                                          _email=value;
                                        });
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Email',
                                      ),
                                      style: TextStyle(fontSize: 19, color: Colors.black, height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width:MediaQuery.of(context). size.width * 0.8,
                              decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Icon(
                                      Icons.lock_rounded,
                                      size: 28,
                                      color:Colors.white,
                                    ),
                                  ),
                                  Container(
                                    width:MediaQuery.of(context). size.width * 0.6,
                                    child: TextFormField(
                                      obscureText: true,
                                      validator: (value){
                                        if(value.trim().isEmpty){
                                          return "Required field";
                                        }
                                        setState(() {
                                          _password=value;
                                        });
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Password',
                                      ),
                                      style: TextStyle(fontSize: 19, color: Colors.black, height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.08,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: RaisedButton(
                                color: Colors.deepPurple,
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.reset();
                                  setState(() {
                                    showSpinner = true;
                                  });
                                  try {
                                    final user = await _auth
                                        .signInWithEmailAndPassword(
                                        email: _email, password: _password);
                                    if (user != null) {
                                      if (_auth.currentUser.emailVerified) {
                                        print(user);
                                        setState(() {
                                          showSpinner=false;
                                          _email = '';
                                          _password = '';
                                        });
                                        Navigator.pushNamedAndRemoveUntil(context,
                                            HomeScreen.id,
                                                (Route<dynamic> route) => false);
                                      } else {
                                        setState(() {
                                          showSpinner = false;
                                        });

                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible: true,
                                          // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Oops !!!'),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text(
                                                        'Please verify your email'),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                      'Send verification link'),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      showSpinner = true;
                                                    });
                                                    try {
                                                      await _auth.currentUser
                                                          .sendEmailVerification();
                                                      setState(() {
                                                        showSpinner = false;
                                                      });
                                                      showDialog<void>(
                                                        context: _scaffoldKey.currentContext,
                                                        barrierDismissible: true,
                                                        // user must tap button!
                                                        builder:
                                                            (
                                                            BuildContext context) {
                                                          return AlertDialog(
                                                            backgroundColor: Colors.deepPurpleAccent,
                                                            title: Text(
                                                                'Success'),
                                                            content:
                                                            SingleChildScrollView(
                                                              child: ListBody(
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      'Verification link sent'),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    } catch (e) {
                                                      setState(() {
                                                        showSpinner = false;
                                                      });
                                                      showDialog<void>(
                                                        context: context,
                                                        barrierDismissible: true,
                                                        // user must tap button!
                                                        builder:
                                                            (
                                                            BuildContext context) {
                                                          return AlertDialog(
                                                            backgroundColor: Colors.deepPurpleAccent,
                                                            title: Text(
                                                                'Failed'),
                                                            content:
                                                            SingleChildScrollView(
                                                              child: ListBody(
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      'Something went wrong. Try again'),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    setState(() {
                                      showSpinner = false;
                                    });
                                    String errorMessage;
                                    print(e.toString());
                                    if (e.toString().contains(
                                        'email != null') ||
                                        e.toString().contains(
                                            'password != null')) {
                                      errorMessage = 'Fill all the fields.';
                                    } else if (e.toString().contains(
                                        'The email address is badly formatted')) {
                                      errorMessage =
                                      'The email address is badly formatted';
                                    } else if (e
                                        .toString()
                                        .contains('wrong-password') ||
                                        e.toString().contains(
                                            'user-not-found')) {
                                      errorMessage = 'Invalid Email/Password';
                                    } else {
                                      errorMessage = 'Something went wrong';
                                    }
                                    // switch (e.toString().toUpperCase()) {
                                    //   case "INVALID-EMAIL":
                                    //     errorMessage = "Your email address appears to be malformed.";
                                    //     break;
                                    //   case "WRONG-PASSWORD":
                                    //     errorMessage = "Your password is wrong.";
                                    //     break;
                                    //   case "USER-NOT-FOUND":
                                    //     errorMessage = "User with this email doesn't exist.";
                                    //     break;
                                    //   case "USER-DISABLED":
                                    //     errorMessage = "User with this email has been disabled.";
                                    //     break;
                                    //   case "TOO-MANY-REQUESTS":
                                    //     errorMessage = "Too many requests. Try again later.";
                                    //     break;
                                    //   case "OPERATION-NOT-ALLOWED":
                                    //     errorMessage = "Signing in with Email and Password is not enabled.";
                                    //     break;
                                    //   default:
                                    //     errorMessage = "Something went wrong";
                                    // }
                                    setState(() {
                                      errorMess = errorMessage;
                                    });
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible: true,
                                      // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.deepPurpleAccent,
                                          title: Text('Oops !!!'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text(errorMess),
                                                Text('Please try again.'),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                }
                              },

                                  child:Text(
                                    'Login',
                                    style:
                                    TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                          fontSize: 22, color: Colors.white, height: 1.5),
                    ),
                    onTap: () => {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.deepPurpleAccent[100],
                                  content: Stack(
                                      overflow: Overflow.visible,
                                      children: <Widget>[
                                        Positioned(
                                          right: -40.0,
                                          top: -40.0,
                                          child: InkResponse(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: CircleAvatar(
                                              child: Icon(Icons.close),
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                        ),
                                        Form(
                                          key: _formKey1,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Registered Email',
                                                    ),
                                                    validator: (value) {
                                                      if (value
                                                          .trim()
                                                          .isEmpty) {
                                                        return "Required field";
                                                      }
                                                      setState(() {
                                                        pass_reset = value;
                                                      });
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: RaisedButton(
                                                      color: Colors.deepPurple,
                                                      child: Text(
                                                          "Send Password Reset link"),
                                                      onPressed: () async {
                                                        if (_formKey1
                                                            .currentState
                                                            .validate()) {
                                                          _formKey1.currentState
                                                              .reset();
                                                          Navigator.of(context)
                                                              .pop();
                                                          setState(() {
                                                            showSpinner = true;
                                                          });
                                                          try {
                                                            await _auth
                                                                .sendPasswordResetEmail(
                                                                    email:
                                                                        pass_reset);
                                                            setState(() {
                                                              pass_reset = '';
                                                              showSpinner =
                                                                  false;
                                                            });
                                                            showDialog<void>(
                                                              context: _scaffoldKey.currentContext,
                                                              barrierDismissible:
                                                                  true,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  backgroundColor: Colors.deepPurpleAccent,
                                                                  title: Text(
                                                                      'Success'),
                                                                  content:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        ListBody(
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                            'Password reset link sent to your email'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          } catch (e) {
                                                            setState(() {
                                                              showSpinner =
                                                                  false;
                                                            });
                                                            showDialog<void>(
                                                              context: _scaffoldKey.currentContext,
                                                              barrierDismissible:
                                                                  true,
                                                              // user must tap button!
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  backgroundColor: Colors.deepPurpleAccent,
                                                                  title: Text(
                                                                      'Failed'),
                                                                  content:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        ListBody(
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                            'Something went wrong. Try again'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          }
                                                        }
                                                      }),
                                                ),
                                              ]),
                                        ),
                                      ]),
                                );
                              }),
                        }),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, RegisterScreen.id),
                  child: Container(
                    child: Text(
                      'Create New Account',
                      style: TextStyle(fontSize: 22, color: Colors.white, height: 1.5),
                    ),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(width: 1, color: Colors.white))),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}