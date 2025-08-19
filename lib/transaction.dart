import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'trans_info.dart';
import 'members.dart';
import 'group_info.dart';
import 'receipt.dart';

class Transactions extends StatefulWidget {

  static const String id = 'Transaction';
  final String group_name,group_id,admin;
  Transactions({Key key,this.group_id, this.group_name, this.admin}): super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {

  bool showSpinner = false;
  bool showSpinner1 = false;

  TextEditingController _frdateController = TextEditingController();
  TextEditingController _todateController = TextEditingController();
  DateTime fromDate = DateTime(2010), toDate=DateTime(2030), selectedDate=DateTime.now();


  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _firebase=FirebaseFirestore.instance;
  final _user=FirebaseAuth.instance;

  Future<bool> _update;
  double _amt= 0.0;

  double _trans_amt=0.0;
  String _trans_desc="";


  Future<bool> _amount() async {
    await _firebase.collection(widget.group_id).doc("_info").get().then((value) {
      double _temp =  value.data()["_amt"].toDouble();
      setState(() {
        _amt=_temp;
      });
     }
    );
    return true;
  }

  @override
  void initState() {
    _update=_amount();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firebase.collection(widget.group_id)
            .doc("_transaction").collection("_transaction_info")
            .orderBy("_tr_time").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                backgroundColor: Colors.deepPurple,
                body: Center(child: CircularProgressIndicator()));
          }
          final _transaction = snapshot.data.docs.reversed.where((element){
           return element["_tr_time"].toDate().isAfter(fromDate) &&
            element["_tr_time"].toDate().isBefore(toDate);
          });
          return SafeArea(
              child: ModalProgressHUD(
                inAsyncCall: showSpinner,
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
                      resizeToAvoidBottomInset: false,
                      key: _scaffoldKey,
                      backgroundColor: Colors.transparent,
                      appBar: AppBar(
                        backgroundColor: Colors.deepPurple,
                        title: Text(widget.group_name,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.pacifico(
                            color: Colors.black,
                            fontSize: MediaQuery
                                .of(context)
                                .size
                                .height * 0.025,
                          ),
                        ),
                        actions: [
                          FlatButton(
                            color: Colors.deepPurpleAccent,
                              onPressed: () async{
                                try{
                                  setState(() {
                                    showSpinner=true;
                                  });
                                  print("heloooo");
                                  await _firebase.collection(widget.group_id).doc("_info").get().then((value) {
                                    print (value["_amt"]);
                                    double _temp =  value["_amt"].toDouble();
                                    print (_temp);
                                    setState(() {
                                      _amt=_temp;
                                    });
                                  }
                                  );
                                  setState(() {
                                    showSpinner=false;
                                  });
                                }catch(e){
                                  print(e);
                                  setState(() {
                                    showSpinner=false;
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
                              child: FutureBuilder<Object>(
                              future: _update,
                              builder: (context, snapshot){
                              if(snapshot.hasData){
                                return Container(
                                    child: Row(
                                      children: [
                                        Text(_amt.toString()+" ",
                                          style: GoogleFonts.mcLaren(
                                            color: _amt>0 ? Colors.black : Colors.red[800],
                                            fontWeight: FontWeight.w900,
                                            fontSize: MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.018,
                                          ),
                                        ),
                                        Text("↻",
                                          style: GoogleFonts.mcLaren(
                                            fontWeight: FontWeight.w900,
                                            fontSize: MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.023,
                                          ),
                                        )
                                      ],
                                    ));
                             }else{
                                return Container(
                                  child: Center(child: CircularProgressIndicator(),),
                                );
                              }
                            }
                           )
                          )
                        ],
                      ),

                      drawer: Drawer(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.deepPurpleAccent,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          child: Icon(Icons.person_outline_outlined,size: 120,color: Colors.black,),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [Text('Hi',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .height * 0.021,
                                              ),
                                            ),
                                              Text(_user.currentUser.displayName,
                                                style: GoogleFonts.pacifico(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .height * 0.028,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    FlatButton(onPressed: (){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                          GroupInfo(group_id : widget.group_id)));
                                    },
                                      child: Container(
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 1,
                                        padding: EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                          child: Text('Group Info',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height * 0.023,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    FlatButton(onPressed: (){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                          Members(group_id : widget.group_id,
                                              group_name: widget.group_name,
                                              admin_id : widget.admin)));
                                    },
                                      child: Container(
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 1,
                                        padding: EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                          child: Text('Members Info',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height * 0.023,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Container(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 1,
                                      padding: EdgeInsets.all(7),
                                      child: Text('Filter by date',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: MediaQuery
                                              .of(context)
                                              .size
                                              .height * 0.023,
                                        ),
                                      ),
                                    ),

                                  Form(
                                    key: _formKey,
                                    child:Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _selectDate(context, "From"),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              controller: _frdateController,
                                              decoration: InputDecoration(
                                                labelText: "From",
                                                icon: Icon(Icons.calendar_today),
                                              ),
                                              validator: (value) {
                                                if (value.isEmpty)
                                                  return "Please enter a date for your task";
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _selectDate(context, "To"),
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              controller: _todateController,
                                              decoration: InputDecoration(
                                                labelText: "To",
                                                icon: Icon(Icons.calendar_today),
                                              ),
                                              validator: (value) {
                                                if (value.isEmpty)
                                                  return "Please enter a date for your task";
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                  ],

                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      color: Colors.deepPurpleAccent,
                                      child: Center(child: Text(" © Transcod",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: MediaQuery
                                              .of(context)
                                              .size
                                              .height * 0.022,
                                        ),
                                      ))
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      body: _transaction.isNotEmpty ? Column(
                        children: [
                          Flexible(
                            child: SizedBox(
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.005,
                            ),
                          ),

                          Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.98,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.04,
                            margin: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),

                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    color: Colors.deepPurpleAccent,
                                    padding: EdgeInsets.all(3.0),
                                    child: Center(child: Text("Date")),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    color: Colors.deepPurpleAccent,
                                    padding: EdgeInsets.all(3.0),
                                    child: Center(child: Text("Party : Description")),

                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    color: Colors.deepPurpleAccent,
                                    padding: EdgeInsets.all(3.0),
                                    child: Center(child: Text("Amount")),

                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.80,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: _transaction.map((index) {
                                return
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .height * 0.005,
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                              TransInfo(group_id : widget.group_id,
                                                  group_name: widget.group_name,
                                                  admin : widget.admin,
                                                  trans_info: index)));
                                        },
                                        child : Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.98,
                                          height: MediaQuery
                                              .of(context)
                                              .size
                                              .height * 0.06,
                                          margin: EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  padding: EdgeInsets.all(3.0),
                                                  color: Colors.deepPurple[400],
                                                  child: Center(child: Text(index['_tr_time'].toDate().toString().substring(0,10),
                                                    style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .height * 0.018,
                                                    ),
                                                  )),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Container(
                                                  padding: EdgeInsets.all(3.0),
                                                  color: Colors.deepPurple[400],
                                                  child: Center(child: Text(
                                                    index["_party"].toString() + " : " + index['_description']
                                                        .toString(),
                                                    style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .height * 0.018,
                                                    ),
                                                  )),

                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding: EdgeInsets.all(3.0),
                                                  color: Colors.deepPurple[400],
                                                  child: Center(child: Text(index['_tr_amt'].toString(),
                                                    style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .height * 0.020,
                                                    ),
                                                  )),

                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                              }).toList(),
                            ),
                          ),
                        ],
                      ) : Center(
                          child: Container(
                            child: Text("No transactions"),
                          )
                      ),

                      floatingActionButton: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            heroTag: "scan",
                              child: Icon(Icons.receipt_rounded),
                              backgroundColor: Colors.deepPurple[400],
                              onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                    Receipts(group_id : widget.group_id)));
                              },
                          ),
                          FloatingActionButton(
                            heroTag: "add",
                            child: Icon(Icons.add),
                            backgroundColor: Colors.deepPurple[400],
                            onPressed: (){
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
                                            key: _formKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: 'Description',
                                                    ),
                                                    keyboardType: TextInputType.multiline,
                                                    maxLines: 2,
                                                    validator: (value){
                                                      if(value.trim().isEmpty){
                                                        return "Required field";
                                                      }
                                                      setState(() {
                                                        _trans_desc=value;
                                                      });
                                                      return null;
                                                    },
                                                  ),
                                                ),
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
                                                        _trans_amt=double.tryParse(value).toDouble();
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

                                                          await _firebase.collection(widget.group_id)
                                                              .doc("_members").collection("_members_info")
                                                              .doc(_user.currentUser.email).get().then((doc)async {

                                                           if(doc.exists) {
                                                             await _firebase
                                                                 .runTransaction((
                                                                 transaction) async {
                                                               CollectionReference accountsRef = _firebase
                                                                   .collection(
                                                                   widget.group_id);
                                                               DocumentReference acc1Ref = accountsRef
                                                                   .doc("_info");
                                                               DocumentSnapshot acc1snap = await transaction
                                                                   .get(acc1Ref);
                                                               double amt = acc1snap['_amt']
                                                                   .toDouble();
                                                               print(amt
                                                                   .roundToDouble());
                                                               transaction.update(
                                                                   acc1Ref, {
                                                                 '_amt': (amt -
                                                                     _trans_amt)
                                                                     .roundToDouble()
                                                               });
                                                             });

                                                             await _firebase
                                                                 .collection(
                                                                 widget.group_id)
                                                                 .doc(
                                                                 "_transaction")
                                                                 .collection(
                                                                 "_transaction_info")
                                                                 .add(
                                                                 {
                                                                   "_party_id": _user
                                                                       .currentUser
                                                                       .email,
                                                                   "_party": _user
                                                                       .currentUser
                                                                       .displayName,
                                                                   "_tr_amt": _trans_amt,
                                                                   "_description": _trans_desc,
                                                                   "_tr_time": Timestamp
                                                                       .now()
                                                                 }
                                                             );

                                                             setState(() {
                                                               showSpinner = false;
                                                               _trans_desc = "";
                                                               _trans_amt = 0.0;
                                                             });
                                                           }
                                                           else{
                                                             setState(() {
                                                               showSpinner = false;
                                                               _trans_desc = "";
                                                               _trans_amt = 0.0;
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
                                                            _trans_desc="";
                                                            _trans_amt=0.0;
                                                            _formKey.currentState.reset();
                                                          });
                                                          showDialog<void>(
                                                            context: _scaffoldKey.currentContext,
                                                            barrierDismissible: true,
                                                            // user must tap button!
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
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
                          ),
                        ],
                      ),

                    ),
                  ],
                ),
              )
          );
      }
    );
  }

  _selectDate(BuildContext context, String fr_to) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2010),
        lastDate: DateTime(2030),
       builder: (context, child) {
        return Theme(
          data: ThemeData.dark(), // This will change to light theme.
          child: child,
        );
      },
    );
    if (picked != null && fr_to == "From")
      setState(() {
        fromDate = picked;
        var date =
            "${picked.toLocal().day}/${picked.toLocal().month}/${picked.toLocal().year}";
        _frdateController.text = date;
      });
    else if (picked != null && fr_to == "To")
      setState(() {
        toDate = DateTime(picked.year,picked.month,picked.day+1);
        var date =
            "${picked.toLocal().day}/${picked.toLocal().month}/${picked.toLocal().year}";
        _todateController.text = date;
      });
  }
}
