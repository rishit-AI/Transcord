import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';




class Receipts extends StatefulWidget {

  static const String id = 'Receipts';
  final String group_id;
  Receipts({Key key,this.group_id}): super(key: key);
  @override
  _ReceiptsState createState() => _ReceiptsState();
}

class _ReceiptsState extends State<Receipts> {

  PickedFile _pickedImage;
  bool isImageLoaded = false;
  bool showSpinner = false;

  List<String> list_desc= new List();
  List<double> list_amt= new List();

  List<int> desc_list = List<int>();
  List<int> select_list = List<int>();

  RegExp regEx =new RegExp(r"\d{1,3}(?:[,]\d{2,3})*(?:[.]\d{2})");

  TextEditingController _DescController = TextEditingController();
  TextEditingController _AmtController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _firebase=FirebaseFirestore.instance;
  final _user=FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();


 Future pickImageCamera() async {
    var image = await _picker.getImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _pickedImage = image;
      isImageLoaded = true;
      showSpinner=true;
    });

    readText(image);

  }

  Future pickImageGallery() async {
    var image = await _picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _pickedImage = image;
      isImageLoaded = true;
      showSpinner=true;
    });

    readText(image);

  }


  Future readText(PickedFile image) async {

    List<String> receipt_desc= new List();
    List<double> receipt_amt= new List();
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(File(image.path));
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

     int i=0;
    for (TextBlock block in readText.blocks) {
      i++;
      print(block.text);
      print(i);
      for (TextLine line in block.lines) {
        if (regEx.hasMatch(line.text)) {
          String desc="";
          double amount=0.0;
          int onoff = 0;
          line.elements.forEach((element) {
            if(regEx.hasMatch(element.text)){
              onoff = 1;
              amount = double.tryParse((regEx.stringMatch(element.text)).replaceAll(RegExp(','), '')).toDouble();
              print(amount);
            }
            else if(onoff == 0)
              desc=desc+element.text;
          });
          receipt_desc.add(desc.trim().isEmpty ? "Undefined" : desc);
          receipt_amt.add(amount);
        }
      }
    }
    setState(() {
      select_list=new List();
      list_desc=receipt_desc;
      list_amt=receipt_amt;
      desc_list = Iterable<int>.generate(receipt_desc.length).toList();
      showSpinner=false;
    });
    print(receipt_amt);
  }


  @override
  Widget build(BuildContext context) {
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
                title: Text("Scan Receipt",
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

              body: isImageLoaded ? desc_list.isNotEmpty ?

                  Column(
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
                        margin: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),

                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                color: Colors.deepPurpleAccent,
                                padding: EdgeInsets.all(3.0),
                                child: Center(child: Text("Description")),

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
                            .height * 0.74,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: desc_list.map((index) {
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
                                    onTap:(){
                                      select_list.contains(index) ?
                                      setState(() {
                                        select_list.remove(index);
                                      }) : setState(() {
                                        select_list.add(index);
                                      });
                                    },
                                    onLongPress:(){

                                      setState(() {
                                        _AmtController.text=list_amt[index].toString();
                                        _DescController.text=list_desc[index];
                                      });

                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.deepPurpleAccent[100],
                                              content: Form(
                                                key: _formKey,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: TextFormField(
                                                        controller:_DescController,
                                                        decoration: InputDecoration(
                                                          labelText: "Description",
                                                          icon: Icon(Icons.description_outlined),
                                                        ),
                                                        keyboardType: TextInputType.multiline,
                                                        maxLines: 2,
                                                        validator: (value){
                                                          if(value.trim().isEmpty){
                                                            return "Required field";
                                                          }
                                                          setState(() {
                                                            list_desc[index]=value;
                                                          });
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: TextFormField(
                                                        controller:_AmtController,
                                                        decoration: InputDecoration(
                                                          labelText: "Amount",
                                                          icon: Icon(Icons.description_outlined),
                                                        ),
                                                        validator: (value){
                                                          if(value.trim().isEmpty || double.tryParse(value) == null){
                                                            return "Numeric Value is required";
                                                          }
                                                          setState(() {
                                                            list_amt[index]=double.tryParse(value).toDouble();
                                                          });
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: RaisedButton(
                                                        color: Colors.deepPurple,
                                                        child: Text("Save Changes"),
                                                        onPressed: () async{
                                                          if (_formKey.currentState.validate()) {
                                                            _formKey.currentState.reset();
                                                            Navigator.of(context).pop();
                                                          }
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
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
                                        color: select_list.contains(index) ? Colors.deepPurple[400] : Colors.white10,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Row(
                                        children: [

                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: EdgeInsets.all(3.0),
                                              child: Center(child: Text(
                                                list_desc[index],
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
                                              child: Center(child: Text(list_amt[index].toString(),
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

                      RaisedButton(
                        onPressed: ()async{
                          if (select_list.isNotEmpty){
                            setState(() {
                              showSpinner=true;
                            });

                              try{

                                await _firebase.collection(widget.group_id)
                                    .doc("_members").collection("_members_info")
                                    .doc(_user.currentUser.email).get().then((doc) async{


                                  if(doc.exists) {
                                    print(list_amt);

                                    for(int index in select_list) {

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
                                            list_amt[index])
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
                                          "_tr_amt": list_amt[index],
                                          "_description": list_desc[index],
                                          "_tr_time": Timestamp
                                              .now()
                                        }
                                    );
                                  }

                                    setState(() {
                                      showSpinner = false;
                                      Navigator.of(this.context).pop();
                                    });
                                  }
                                  else{
                                    setState(() {
                                      showSpinner = false;
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
                          else{
                            _scaffoldKey.currentState.showSnackBar(
                                SnackBar(content:Text("No Transaction Selected")));
                          }

                        },

                        color: Colors.greenAccent,
                        child: Container(
                          child: Text("Start Transaction",
                          style: TextStyle(
                            color: Colors.black
                          ),
                          ),
                        ),
                      )

                    ],
                  )

                  : Center(
                child: Text("No product found"),
              )
                  : Center(
                child: Text("Tap button to scan receipt"),
              ) ,

              floatingActionButton: SpeedDial(
                backgroundColor: Colors.deepPurple[400],
                foregroundColor: Colors.white,
                animationSpeed: 200,
                curve: Curves.bounceInOut,
                overlayColor: Colors.deepPurple[100],
                animatedIcon: AnimatedIcons.list_view,
                children: [
                  SpeedDialChild(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: Icon(Icons.image),
                    label: 'Pick from gallery',
                    onTap: pickImageGallery,
                  ),
                  SpeedDialChild(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: Icon(Icons.add_a_photo),
                    label: 'Scan from camera',
                    onTap: pickImageCamera,
                  ),
                ],
              ),
            )

          ],
        ),
      ),

    );
  }
}
