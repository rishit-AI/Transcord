import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class TransInfo extends StatefulWidget {

  static const String id = 'Trans_info';
  final String group_name,group_id,admin;
  QueryDocumentSnapshot trans_info;

  TransInfo({Key key,this.group_id, this.group_name, this.trans_info, this.admin}): super(key: key);

  @override
  _TransInfoState createState() => _TransInfoState();
}

class _TransInfoState extends State<TransInfo> {

  bool showSpinner = false;

  final _firebase=FirebaseFirestore.instance;
  final _user=FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
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
            Scaffold(
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

            body: ModalProgressHUD(
              inAsyncCall: showSpinner,
              child: Center(
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.98,

                  margin: EdgeInsets.all(3),
                  padding: EdgeInsets.only(left: 8, right: 8,top: 12,bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TransactionWidget(tag :"Transaction ID", value: widget.trans_info.id),
                      TransactionWidget(tag :"Time", value: widget.trans_info["_tr_time"].toDate().toString().substring(0,19)),
                      TransactionWidget(tag :"Party", value: widget.trans_info["_party"]),
                      TransactionWidget(tag :"Party ID", value: widget.trans_info["_party_id"]),
                      TransactionWidget(tag :"Description", value: widget.trans_info["_description"]),
                      TransactionWidget(tag :"Amount", value: widget.trans_info["_tr_amt"].toString()),
                      (_user.currentUser.email == widget.trans_info["_party_id"] || (widget.admin == _user.currentUser.email) &&
                          (widget.trans_info["_party_id"] != "********")) ? Center(
                        child: FlatButton(
                          color: Colors.red,
                          child: Text("Undo"),

                          onPressed: ()async{
                            try{
                              setState(() {
                                showSpinner=true;
                              });


                            await _firebase.collection(widget.group_id)
                                .doc("_members").collection("_members_info")
                                .doc(_user.currentUser.email).get().then((doc)async {
                              if (doc.exists) {

                                await _firebase.runTransaction((
                                    transaction) async {
                                  CollectionReference accountsRef = _firebase
                                      .collection(widget.group_id);
                                  DocumentReference acc1Ref = accountsRef.doc(
                                      "_info");
                                  DocumentSnapshot acc1snap = await transaction
                                      .get(acc1Ref);
                                  double amt = acc1snap['_amt']
                                      .toDouble();
                                  print(amt.roundToDouble());
                                  transaction.update(acc1Ref, {
                                    '_amt': (amt +
                                        (widget.trans_info["_tr_amt"]
                                            .toDouble())).roundToDouble()
                                  });
                                });

                                await _firebase.collection(widget.group_id)
                                    .doc("_transaction").collection(
                                    "_transaction_info").doc(
                                    widget.trans_info.id).delete().then((
                                    value) {
                                  setState(() {
                                    showSpinner = false;
                                    Navigator.of(context).pop();
                                  });
                                });
                              }
                              else{

                                setState(() {
                                  showSpinner = false;
                                });
                                showDialog<void>(
                                  context: context,
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
                                                "You are no longer the member of this group"),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                              }

                            });


                            }catch(e){

                              print(e);

                              setState(() {
                                showSpinner= false;
                              });
                              showDialog<void>(
                                context: context,
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
                        ),
                      ) : SizedBox( height: MediaQuery
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
        (widget.tag != "Transaction ID") ? Text(widget.value,
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

