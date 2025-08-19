import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'homescreen.dart';


class GroupInfo extends StatefulWidget {

  static const String id = 'Group_info';
  final String group_id;

  GroupInfo({Key key,this.group_id }): super(key: key);

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {

  bool showSpinner = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _firebase=FirebaseFirestore.instance;
  final _user=FirebaseAuth.instance;
  Future<bool> _update;

  DateTime _createdAt;
  String admin_name,admin_id, _grp_name, _grp_id;

  Future<bool> _updategrp() async {
    await _firebase.collection(widget.group_id).doc("_info").get().then((value) {
      setState(() {
        _grp_id=widget.group_id;
        _grp_name=value.data()["_group_name"];
        _createdAt=value.data()["_time"].toDate();
        admin_id=value.data()["admin_id"];
        admin_name=value.data()["admin_name"];
      });
    }
    );
    return true;
  }

  @override
  void initState() {
    _update=_updategrp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: _update,
        builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.deepPurple,
            body: Center(child: CircularProgressIndicator()));
           }
            return SafeArea(
                child: Stack(
                    children: [
                      ShaderMask(
                        shaderCallback: (rect) =>
                            LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [Colors.deepPurple, Colors.transparent],
                            ).createShader(rect),
                        blendMode: BlendMode.darken,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/unnamed.jpg'),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.darken),
                            ),
                          ),
                        ),
                      ),
                      ModalProgressHUD(
                        inAsyncCall: showSpinner,
                        child: Scaffold(
                          backgroundColor: Colors.transparent,
                          appBar: AppBar(
                            backgroundColor: Colors.deepPurpleAccent,
                            title: Text("Transaction Info",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.025,
                              ),
                            ),
                          ),

                          body: Center(
                            child: Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.98,

                              margin: EdgeInsets.all(3),
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 12, bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  TransactionWidget(tag: "Group ID",
                                      value: _grp_id),
                                  TransactionWidget(tag: "Group Name",
                                      value: _grp_name),
                                  TransactionWidget(tag: "Admin",
                                      value: admin_name),

                                  TransactionWidget(tag: "Admin ID",
                                      value: admin_id),
                                  TransactionWidget(tag: "Created On",
                                      value: _createdAt.toString().substring(0,19)),
                                  (admin_id == _user.currentUser.email) ? Center(
                                    child: FlatButton(
                                      color: Colors.red,
                                      child: Text("Delete Group"),

                                      onPressed: () {
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible: true, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.deepPurple[200],
                                              title: Text('Alert'),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text('Are you sure ?\nThis will take a while.'),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Yes'),
                                                  onPressed: () async{

                                                      try {
                                                        Navigator.of(context).pop();
                                                        setState(() {
                                                          showSpinner = true;
                                                        });

                                                              await _firebase.collection(widget.group_id)
                                                                  .doc("_info").delete();
                                                        await _firebase.collection(widget.group_id)
                                                            .doc("_members").collection("_members_info")
                                                            .get().then((value) {
                                                          for(QueryDocumentSnapshot ds in value.docs){
                                                            ds.reference.delete();
                                                          }
                                                        });
                                                        await _firebase.collection(widget.group_id)
                                                            .doc("_transaction").collection("_transaction_info")
                                                            .get().then((value) {
                                                          for(QueryDocumentSnapshot ds in value.docs){
                                                            ds.reference.delete();
                                                          }
                                                        });
                                                        await _firebase.collection("_users")
                                                            .doc(_user.currentUser.email)
                                                            .collection("_groups")
                                                            .doc(widget.group_id).delete();

                                                        setState(() {
                                                              showSpinner=false;
                                                              Navigator.pushNamedAndRemoveUntil(this.context,
                                                                  HomeScreen.id,
                                                                      (Route<dynamic> route) => false);
                                                            });

                                                      } catch (e) {
                                                        print(e);
                                                        setState(() {
                                                          showSpinner = false;
                                                        });
                                                        showDialog<void>(
                                                          context: _scaffoldKey.currentContext,
                                                          barrierDismissible: true,
                                                          // user must tap button!
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              backgroundColor: Colors
                                                                  .deepPurpleAccent,
                                                              title: Text('Oops!!!'),
                                                              content: SingleChildScrollView(
                                                                child: ListBody(
                                                                  children: <Widget>[
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
                                      },
                                    ),
                                  )
                                      : SizedBox(height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.0005)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                )
            );
          }
    );
  }
}

class TransactionWidget extends StatefulWidget {
  final String tag,value;
  TransactionWidget({Key key,this.tag,this.value}): super(key: key);
  @override
  _TransactionWidgetState createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox( height: MediaQuery
            .of(context)
            .size
            .height * 0.012),

        Text(widget.tag,
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: MediaQuery
                .of(context)
                .size
                .height * 0.025,
          ),
        ),
        SizedBox( height: MediaQuery
            .of(context)
            .size
            .height * 0.0015),
        (widget.tag != "Group ID") ? Text(widget.value,
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery
                .of(context)
                .size
                .height * 0.032,
          ),
        ) : SelectableText(widget.value,
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: MediaQuery
                .of(context)
                .size
                .height * 0.032,
          ),
        ),
        SizedBox( height: MediaQuery
            .of(context)
            .size
            .height * 0.010),
        Container(
          color: Colors.black,
          height: MediaQuery
              .of(context)
              .size
              .height * 0.0010,
        )
      ],
    );
  }
}