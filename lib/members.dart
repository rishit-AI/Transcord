import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class Members extends StatefulWidget {

  static const String id = 'members';
  final String group_name,group_id,admin_id;
  Members({Key key,this.group_id, this.group_name, this.admin_id}): super(key: key);

  @override
  _MembersState createState() => _MembersState();
}

class _MembersState extends State<Members> {

  bool showSpinner = false;
  double _edit_amt=0.0;
  String _search="";

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _firebase=FirebaseFirestore.instance;
  final _user=FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firebase.collection(widget.group_id).doc("_members").collection("_members_info").orderBy("_join_time").snapshots(),
        builder: (context, snapshot) {
        if (!snapshot.hasData) {
            return Scaffold(
            backgroundColor: Colors.deepPurpleAccent,
            body: Center(child: CircularProgressIndicator()));
         };

        final _members = snapshot.data.docs.where((element) {
          return  element["_name"].toString()
        .toUpperCase()
        .contains(_search.toUpperCase());
        });

        return SafeArea(
            child: Stack(
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
                    resizeToAvoidBottomInset: false,
                    key: _scaffoldKey,
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      backgroundColor: Colors.deepPurple,
                      title: Text('Members',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: MediaQuery
                              .of(context)
                              .size
                              .height * 0.025,
                        ),
                      ),
                    ),


                    body:  Column(
                      children: <Widget>[
                        Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.98,
                              margin: EdgeInsets.all(5),
                              padding: EdgeInsets.only(left: 20,right: 20,),
                              decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withOpacity(.9),
                              borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                     decoration: InputDecoration(
                                     border: InputBorder.none,
                                        hintText: "Search Member Name"
                                        ),
                                        onChanged: (value){
                                          setState(() {
                                           _search=value;
                                              });
                                          }
                               ),
                         ),

                        _members.isNotEmpty ?
                        Container(
                           height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.79,
                          child: ListView(
                           shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: _members.map((index) {
                              return
                                Column(
                                  children: [
                                    SizedBox(
                                      height: MediaQuery
                                          .of(context)
                                          .size
                                          .height * 0.010,
                                    ),
                                    Container(

                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurpleAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex : 3,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(index["_name"],
                                                      style: GoogleFonts.lato(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .height * 0.020,
                                                      ),
                                                    ),
                                                    Text(index.id)
                                                  ],
                                                ),
                                              ),
                                              (_user.currentUser.email == widget.admin_id && index.id != widget.admin_id) ? Expanded(
                                                flex: 1,
                                                child: FlatButton(
                                                  color: Colors.deepPurple,
                                                  onPressed: (){
                                                    showDialog<void>(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      // user must tap button!
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          backgroundColor: Colors.deepPurpleAccent,
                                                          title: Text('Choice Alert'),
                                                          content: SingleChildScrollView(
                                                            child: ListBody(
                                                              children: <Widget>[
                                                                Text(
                                                                    'Would you like to deduct amount also ?'),
                                                              ],
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: Text("Yes"),
                                                              onPressed:()async{

                                                                Navigator.of(context).pop();

                                                                try {
                                                                  setState(() {
                                                                    showSpinner = true;
                                                                  });

                                                                  await _firebase.runTransaction((transaction) async {
                                                                    CollectionReference accountsRef = _firebase
                                                                        .collection(widget.group_id);
                                                                    DocumentReference acc1Ref = accountsRef.doc("_info");
                                                                    DocumentSnapshot acc1snap = await transaction.get(acc1Ref);
                                                                    double amt = acc1snap['_amt'].toDouble();
                                                                    print(amt.roundToDouble());
                                                                    transaction.update(acc1Ref, {
                                                                      '_amt': (amt-(index['_member_amt'].toDouble())).roundToDouble()
                                                                    });
                                                                  });

                                                                  await _firebase.collection(widget.group_id)
                                                                      .doc("_members").collection("_members_info").doc(index.id).delete().then((value) {

                                                                    setState(() {
                                                                      showSpinner= false;
                                                                    });

                                                                  });

                                                                }catch(e){

                                                                  setState(() {
                                                                    showSpinner= false;
                                                                  });

                                                                  showDialog<void>(
                                                                    context: _scaffoldKey.currentContext,
                                                                    barrierDismissible: true,
                                                                    // user must tap button!
                                                                    builder: (BuildContext context) {
                                                                      return AlertDialog(
                                                                        backgroundColor: Colors.deepPurpleAccent,
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
                                                              } ,
                                                            ),

                                                            TextButton(
                                                              child: Text("No"),
                                                              onPressed: ()async{

                                                                Navigator.of(context).pop();

                                                                try{
                                                                  setState(() {
                                                                    showSpinner=true;
                                                                  });

                                                                  await _firebase.collection(widget.group_id)
                                                                      .doc("_members").collection("_members_info").doc(index.id).delete().then((value) {

                                                                        setState(() {
                                                                          showSpinner=false;
                                                                        });
                                                                  });

                                                                }catch(e){
                                                                  setState(() {
                                                                    showSpinner= false;
                                                                  });

                                                                  showDialog<void>(
                                                                    context: _scaffoldKey.currentContext,
                                                                    barrierDismissible: true,
                                                                    // user must tap button!
                                                                    builder: (BuildContext context) {
                                                                      return AlertDialog(
                                                                        backgroundColor: Colors.deepPurpleAccent,
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

                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );

                                                  },

                                                  child: Container(
                                                    child: Text("Kick Out"),
                                                  ),

                                                ),
                                              ): Expanded(flex : 1,child: Container())
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text("Deposit Amount :  "+index["_member_amt"].toString()),
                                              ),
                                              (_user.currentUser.email == widget.admin_id) ? Expanded(
                                                flex: 1,
                                                child: FlatButton(
                                                  color: Colors.deepPurple,
                                                  onPressed: (){
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            backgroundColor: Colors.deepPurpleAccent,
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
                                                                  key: _formKey,
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: <Widget>[

                                                                      Padding(
                                                                        padding: EdgeInsets.all(8.0),
                                                                        child: TextFormField(
                                                                          decoration: InputDecoration(
                                                                            hintText: 'Amount',
                                                                          ),
                                                                          validator: (value){
                                                                            if(value.trim().isEmpty || double.tryParse(value) == null){
                                                                              return "Numeric Value is required";
                                                                            }
                                                                            setState(() {
                                                                              _edit_amt=double.tryParse(value).toDouble();
                                                                            });
                                                                            return null;
                                                                          },
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: RaisedButton(
                                                                          color: Colors.deepPurple,
                                                                          child: Text("Continue"),
                                                                          onPressed: () async{
                                                                            if (_formKey.currentState.validate()) {
                                                                              _formKey.currentState.reset();
                                                                              Navigator.of(context).pop();
                                                                              try{
                                                                                setState(() {
                                                                                  showSpinner=true;
                                                                                });

                                                                                await _firebase.runTransaction((transaction) async {
                                                                                  CollectionReference accountsRef = _firebase
                                                                                      .collection(widget.group_id);
                                                                                  DocumentReference acc1Ref = accountsRef.doc("_info");
                                                                                  DocumentSnapshot acc1snap = await transaction.get(acc1Ref);
                                                                                  double amt = acc1snap['_amt'].toDouble();
                                                                                  print(amt.roundToDouble());
                                                                                  transaction.update(acc1Ref, {
                                                                                    '_amt': (amt+(_edit_amt-index['_member_amt'].toDouble())).roundToDouble()
                                                                                  });
                                                                                });

                                                                                await _firebase.collection(widget.group_id)
                                                                                    .doc("_members").collection("_members_info").doc(index.id).update(
                                                                                    {
                                                                                      "_member_amt" : _edit_amt.roundToDouble()
                                                                                    }
                                                                                );

                                                                                setState(() {
                                                                                  showSpinner= false;
                                                                                  _edit_amt=0.0;
                                                                                });

                                                                              }catch(e){

                                                                                print(e);

                                                                                setState(() {
                                                                                  showSpinner= false;
                                                                                  _edit_amt=0.0;
                                                                                });
                                                                                showDialog<void>(
                                                                                  context: _scaffoldKey.currentContext,
                                                                                  barrierDismissible: true,
                                                                                  // user must tap button!
                                                                                  builder: (BuildContext context) {
                                                                                    return AlertDialog(
                                                                                      backgroundColor: Colors.deepPurpleAccent,
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

                                                                            }
                                                                          },
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        });

                                                  },
                                                  child: Container(
                                                    child: Icon(Icons.edit),
                                                  ),

                                                ),
                                              ): Expanded(flex : 1,child: Container())
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                );
                            }).toList(),
                          ),
                        ) : Center(
                        child: Container(
                          child: Text("No Members"),
                        )
                    ),
                    ]
                  ),
                ),
              )
             ]
            )
        );
        }
    );
  }
}
