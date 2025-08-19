import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterScreen extends StatefulWidget {
  static const String id ='register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {


  bool showSpinner = false;

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _auth = FirebaseAuth.instance;
  final _firebase=FirebaseFirestore.instance;
  String _name;
  String _email;
  String _password;
  String errormess;

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
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: Column(
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
                                      Icons.person_sharp,
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
                                          _name=value;
                                        });
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Name',
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
                        width:MediaQuery.of(context). size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),

                        ),
                        child: RaisedButton(
                        color: Colors.deepPurple,
                          onPressed: () async{

                            if(_formKey.currentState.validate()){
                              _formKey.currentState.reset();
                              setState(() {
                                showSpinner = true;
                              });

                              try {
                                final user = await _auth
                                    .createUserWithEmailAndPassword(
                                    email: _email, password: _password);
                                await _auth.currentUser.updateProfile(
                                  displayName: _name,
                                );
                                setState(() {
                                  _name='';
                                  _email='';
                                  _password='';
                                });

                                if (user != null) {
                                  print(_auth.currentUser);
                                  try {
                                    await _auth.currentUser
                                        .sendEmailVerification();
                                    await _firebase.collection("_users").doc(_auth.currentUser.email)
                                        .collection("_groups").add(
                                        {
                                      "_Welcome":Timestamp.now()
                                    }
                                    );
                                    setState(() {
                                      showSpinner = false;
                                    });
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible: true, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.deepPurpleAccent,
                                          title: Text('Success'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text('Verification link sent'),
                                                Text('\nVerify and login'),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                  catch(e){
                                    setState(() {
                                      showSpinner = false;
                                    });
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible: true, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.deepPurpleAccent,
                                          title: Text('Oops'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text('Couldn\'t send verification link'),
                                                Text('\nTry login'),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                }
                              }
                              catch (e) {
                                setState(() {
                                  _name='';
                                  _email='';
                                  _password='';
                                  showSpinner = false;
                                });
                                String errorMessage;
                                print(e.toString());
                                if(e.toString().contains('email != null') || e.toString().contains('password != null') ||
                                    e.toString().contains('Given String is empty or null')){
                                  errorMessage='Fill all the fields.';
                                }
                                else if(e.toString().contains('The email address is badly formatted')){
                                  errorMessage='The email address is badly formatted';
                                }
                                else if(e.toString().contains('email-already-in-use')){
                                  errorMessage='Email is already registered';
                                }
                                else{
                                  errorMessage='Something went wrong';
                                }
                                setState(() {
                                  errormess=errorMessage;
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
                                            Text(errormess),
                                            Text(
                                                'Please try again'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }
                          },

                          child: Text(
                            'SignUp',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                          ),
                         ]
                        ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context,LoginScreen.id,(Route<dynamic> route) => false),
                  child: Container(
                    child: Text(
                      'Already a User? Signin ',
                      style: TextStyle(fontSize: 22, color: Colors.white, height: 1.5),
                    ),
                    decoration: BoxDecoration(
                        border:
                        Border(bottom: BorderSide(width: 1, color: Colors.white))),
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


