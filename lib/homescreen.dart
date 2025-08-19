import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:uuid/uuid.dart';
import 'transaction.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {

  static const String id = 'HomeScreen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  DateTime ch;

  bool showSpinner = false;
  var admin_id=null;

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _create_grp="";
  String _join_grp="", _search="";

  final _firebase=FirebaseFirestore.instance;
  final _user=FirebaseAuth.instance;
  final _uuid =Uuid();

  @override
  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {


     return StreamBuilder<QuerySnapshot>(
      stream: _firebase.collection("_users").doc(_user.currentUser.email).collection("_groups").orderBy("_group_name").snapshots(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          final _grps = snapshot.data.docs.where((element) {
          return  element["_group_name"].toString()
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
                     title: Text('Transcord',
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
                                       child: Icon(Icons.person_sharp,size: 120,color: Colors.black,),
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
                                                           hintText: 'Group name',
                                                         ),
                                                         keyboardType: TextInputType.multiline,
                                                         maxLines: 2,
                                                         validator: (value){
                                                           if(value.trim().isEmpty){
                                                             return "Required field";
                                                           }
                                                           setState(() {
                                                             _create_grp=value;
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

                                                                 var v1 = _uuid.v1();
                                                                await _firebase.collection(v1).doc("_info").set(
                                                                 {
                                                                   "admin_id" : _user.currentUser.email,
                                                                   "admin_name" : _user.currentUser.displayName,
                                                                   "_amt": 0.0,
                                                                   "_group_name":_create_grp,
                                                                   "_time":Timestamp.now(),
                                                                 }
                                                               );
                                                                 await _firebase.collection(v1)
                                                                     .doc("_members").collection("_members_info").doc(_user.currentUser.email).set(
                                                                     {
                                                                       "_join_time" : Timestamp.now(),
                                                                       "_member_amt": 0.0,
                                                                       "_name":_user.currentUser.displayName
                                                                     }
                                                                 );
                                                               await _firebase.collection(v1).doc("_transaction").collection("_transaction_info").add(
                                                                   {
                                                                     "_party_id":"********",
                                                                     "_party" : "Transcod",
                                                                     "_tr_amt": 0.0,
                                                                     "_description":"Welcome",
                                                                     "_bal":0.0,
                                                                     "_tr_time" : Timestamp.now()
                                                                   }
                                                               );

                                                               await _firebase.collection("_users").doc(_user.currentUser.email)
                                                                   .collection("_groups").doc(v1).set(
                                                                 {
                                                                   "_group_name" : _create_grp,
                                                                   "admin_name" : _user.currentUser.displayName,
                                                                   "admin_id":_user.currentUser.email
                                                                 }
                                                               );


                                                                   setState(() {
                                                                     showSpinner = false;
                                                                     _create_grp = "";
                                                                   });


                                                             }catch(e){

                                                               print(e);

                                                               setState(() {
                                                                 showSpinner= false;
                                                                 _create_grp = "";
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
                                       child: Text('Create group',
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
                                                           hintText: 'Group ID',
                                                         ),
                                                         validator: (value){
                                                           if(value.trim().isEmpty){
                                                             return "Required field";
                                                           }
                                                           setState(() {
                                                             _join_grp=value;
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
                                                           if (_formKey1.currentState.validate()) {
                                                             _formKey1.currentState.reset();
                                                             Navigator.of(context).pop();
                                                             try{
                                                               setState(() {
                                                                 showSpinner=true;
                                                               });


                                                               await _firebase.collection(_join_grp).doc("_info").get().then((doc) async{
                                                                 print("all ok");

                                                                 if(doc.exists){

                                                                   String name = doc.data()["_group_name"];
                                                                   String admin = doc.data()["admin_name"];
                                                                   String admin_Id = doc.data()["admin_id"];
                                                                   print("all ok");
                                                                   await _firebase.collection(_join_grp).doc("_members")
                                                                       .collection("_members_info")
                                                                       .doc(_user.currentUser.email).get().then((value) async{

                                                                         if(! value.exists){
                                                                           await _firebase.collection(_join_grp)
                                                                               .doc("_members")
                                                                               .collection("_members_info")
                                                                               .doc(_user.currentUser.email)
                                                                               .set(
                                                                         {
                                                                           "_join_time" : Timestamp.now(),
                                                                           "_member_amt": 0.0,
                                                                           "_name":_user.currentUser.displayName
                                                                         }
                                                                         );
                                                                         }
                                                                   });



                                                                   await _firebase.collection("_users").doc(_user.currentUser.email)
                                                                       .collection("_groups").doc(_join_grp).set(
                                                                       {
                                                                         "_group_name" : name,
                                                                         "admin_name" : admin,
                                                                         "admin_id":admin_Id
                                                                       }
                                                                   );

                                                                   setState(() {
                                                                     showSpinner = false;
                                                                     _join_grp = "";
                                                                   });

                                                                 }else{
                                                                   setState(() {
                                                                     showSpinner = false;
                                                                     _join_grp = "";
                                                                   });
                                                                   print("all ok");
                                                                   showDialog<void>(
                                                                     context: _scaffoldKey.currentContext,
                                                                     barrierDismissible: true,
                                                                     builder: (BuildContext context) {
                                                                       return AlertDialog(
                                                                         backgroundColor: Colors.deepPurpleAccent,
                                                                         title: Text('Oops!!!'),
                                                                         content: SingleChildScrollView(
                                                                           child: ListBody(
                                                                             children: <Widget>[
                                                                               Text(
                                                                                   'Invalid Group ID'),
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
                                                                 _join_grp = "";
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
                                       child: Text('Join group',
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

                                 FlatButton(onPressed: ()async{
                                   await _user.signOut();
                                   Navigator.pushNamedAndRemoveUntil(context,LoginScreen.id,
                                           (Route<dynamic> route) => false);
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
                                       child: Text('Logout',
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

                   body:Column(
                     children: [
                       Container(
                         width: MediaQuery
                             .of(context)
                             .size
                             .width * 0.98,
                         margin: EdgeInsets.all(5),
                         padding: EdgeInsets.only(left: 20,right: 20,),
                         decoration: BoxDecoration(
                           color: Colors.deepPurple.withOpacity(.9),
                           borderRadius: BorderRadius.circular(10),
                         ),
                         child: TextField(
                           decoration: InputDecoration(
                              border: InputBorder.none,
                             hintText: "Search Group Name"
                           ),
                           onChanged: (value){
                             setState(() {
                               _search=value;
                             });
                           }
                         ),
                       ),

                       _grps.isNotEmpty ?
                       Container(
                         height: MediaQuery
                             .of(context)
                             .size
                             .height * 0.77,
                         child: ListView(
                           shrinkWrap: true,
                           scrollDirection: Axis.vertical,
                           children: _grps.map((index) {
                             print (index["_group_name"]);
                             return
                               Column(
                                 children: [
                                   SizedBox(
                                     height: MediaQuery
                                         .of(context)
                                         .size
                                         .height * 0.010,
                                   ),
                                   GestureDetector(
                                     onTap: () async{
                                       try {
                                         setState(() {
                                           showSpinner=true;
                                         });

                                         await _firebase.collection(index.id).doc("_info").get().then((value)async {
                                           if (value.exists) {
                                             setState(() {
                                               admin_id = value
                                                   .data()["admin_id"];
                                             });

                                             await _firebase.collection(index.id).doc("_members").collection("_members_info")
                                                 .doc(_user.currentUser.email).get().then((doc) {

                                               setState(() {
                                                 showSpinner=false;
                                               });

                                               if (doc.exists)
                                                 Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                                     Transactions(group_id : index.id, group_name: index["_group_name"], admin : admin_id)));
                                               else
                                                 showDialog<void>(
                                                   context: context,
                                                   barrierDismissible: true,
                                                   builder: (BuildContext context) {
                                                     return AlertDialog(
                                                       backgroundColor: Colors.deepPurpleAccent,
                                                       title: Text('Oops!!!'),
                                                       content: SingleChildScrollView(
                                                         child: ListBody(
                                                           children: <Widget>[
                                                             Text(
                                                                 'You are no longer the member of this group'),
                                                           ],
                                                         ),
                                                       ),
                                                     );
                                                   },
                                                 );
                                             });

                                           }
                                           else {
                                             setState(() {
                                               showSpinner=false;
                                             });
                                             showDialog<void>(
                                               context: context,
                                               barrierDismissible: true,
                                               builder: (BuildContext context) {
                                                 return AlertDialog(
                                                   backgroundColor: Colors.deepPurpleAccent,
                                                   title: Text('Oops!!!'),
                                                   content: SingleChildScrollView(
                                                     child: ListBody(
                                                       children: <Widget>[
                                                         Text(
                                                             'This group no longer exist.'),
                                                       ],
                                                     ),
                                                   ),
                                                 );
                                               },
                                             );
                                           }
                                         }
                                         );


                                       } catch (e) {
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
                                               title: Text('Failed'),
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
                                     child : Container(
                                       width: MediaQuery
                                           .of(context)
                                           .size
                                           .width * 0.98,
                                       margin: EdgeInsets.all(5),
                                       padding: EdgeInsets.all(5),
                                       decoration: BoxDecoration(
                                         color: Colors.deepPurpleAccent,
                                         borderRadius: BorderRadius.circular(10),
                                       ),
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                         children: [
                                           Center(
                                             child: Text(index["_group_name"],
                                               style: GoogleFonts.pacifico(
                                                 color: Colors.black,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .height * 0.030,
                                               ),
                                             ),
                                           ),
                                           SizedBox(
                                             height: MediaQuery.of(context)
                                             .size.height* 0.0050,
                                           ),
                                           Center(
                                             child: Text(index["admin_name"],
                                               style: GoogleFonts.lato(
                                                 color: Colors.black,
                                                 fontSize: MediaQuery
                                                     .of(context)
                                                     .size
                                                     .height * 0.018,
                                               ),
                                             ),
                                           ),
                                           Center(child: Row(
                                             mainAxisAlignment : MainAxisAlignment.center,
                                             children: [
                                               SelectableText(index.id),
                                               IconButton(icon: Icon(Icons.content_copy),
                                                   onPressed: (){
                                                    Clipboard.setData(new ClipboardData(text: index.id)).then((_){
                                                       _scaffoldKey.currentState.showSnackBar(
                                                           SnackBar(content:Text("Group ID copied to clipboard")));
                                                     });
                                                   })
                                             ],
                                           ),
                                           ),
                                           (index["admin_id"]!=_user.currentUser.email) ? Center(
                                             child: FlatButton(onPressed: ()async{
                                               try{
                                                 setState(() {
                                                   showSpinner=true;
                                                 });
                                                 await _firebase.collection("_users").doc(_user.currentUser.email)
                                                     .collection("_groups").doc(index.id).delete();

                                                 setState(() {
                                                   showSpinner=false;
                                                 });
                                               }

                                               catch(e){
                                                 setState(() {
                                                   showSpinner=false;
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
                                                 child: Container(
                                                   padding: EdgeInsets.only(top:5,bottom: 5,left: 15,right: 15),
                                                   decoration: BoxDecoration(
                                                     color: Colors.deepPurple,
                                                     borderRadius: BorderRadius.circular(4),
                                                   ),
                                                   child: Text("Leave"),
                                                 )
                                             ),
                                           ) : SizedBox(
                                             height:  MediaQuery
                                                 .of(context)
                                                 .size
                                                 .height * 0.0001,
                                           )
                                         ],
                                       ),
                                     ),
                                   ),
                                 ],
                               );
                           }).toList(),
                         ),
                       ) : Center(
                       child: Container(
                         margin: EdgeInsets.all(5),
                         padding: EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: Colors.deepPurpleAccent,
                           borderRadius: BorderRadius.circular(10),
                         ),
                         child: Text("No groups"),
                       ),
                       )
                     ]
                   ),

                   // floatingActionButton: FloatingActionButton(
                   //   onPressed: (){
                   //     List<Map<String,double>> lst= new List();
                   //
                   //     Map<String,double> m =new Map();
                   //     m["hbj"]=60.9;
                   //     m["fccgvj"]=60.8;
                   //     lst.add({"hgfjhj":50.9});
                   //     lst.add({"hgfjh":50.9});
                   //     print(m.entries);
                   //     print(lst.map((e) => null));
                   //
                   //
                   //
                   //    Navigator.pushNamed(context, Receipts.id);
                   //
                   //     // await _firebase.collection("1d49bdd0-46e1-11eb-8380-6928cab876c9")
                   //     //     .doc("_transaction").collection("_transaction_info").get().then((value) {
                   //     //       for(QueryDocumentSnapshot ds in value.docs){
                   //     //         ds.reference.delete();
                   //     //       }
                   //     // });
                   //  },
                   //
                   // ),



                 ),
               ),
             ],
           )
       );
      }else{
          return Scaffold(
              backgroundColor: Colors.deepPurpleAccent,
              body: Center(child: CircularProgressIndicator()));
          }
      }
    );
  }
}

